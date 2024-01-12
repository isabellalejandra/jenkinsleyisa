resource "aws_key_pair" "autodeploy" {
  #key_name   = "autodeploy"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.autodeploy.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = var.name_tag,
  }
  
  #key_name = aws_key_pair.autodeploy.key_name  # Link the key pair to the instance
}
#creating security groups to allow my teams IP's
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-02005d49d099e87b4"

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["96.90.192.54/32", "76.210.139.68/32"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
#adding additional EBS volume to EC2 instance using terraform
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.aws_ebs_volume.example.id
  instance_id = aws_instance.public_instance.id
}
#create the EBS volume
resource "aws_ebs_volume" "add_disk" {
  availability_zone = "aws_instance.public_instance.availability_zone"
  size              = 10
}
#creating a vcp with terraform 
resource "aws_vpc" "main" {
 cidr_block = "10.10.10.0/24"
 
 tags = {
   Name = "Purple team vcp"
 }
}