provider "aws" {}

variable AZ {}

variable env_perfix {}

variable "subnet_var" {}

variable "vpc_var" {}

variable "my_ip" {}

variable "instance_type" {} 
variable "public_key_location" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_var
  tags = {
    Name : "${var.env_perfix}-vpc" 
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_var
  availability_zone = var.AZ  
  tags = {
    Name : "${var.env_perfix}-subnet"
  }
}

resource "aws_internet_gateway" "my_app_igw" {
  vpc_id = aws_vpc.main.id
   tags = {
    Name : "${var.env_perfix}-igw"
  }
}

/*resource "aws_route_table" "my_app_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_igw.id
  }
  tags = {
    Name : "${var.env_perfix}-rtb"
  } 
}*/

/*resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.my_app_rtb.id
}*/

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_igw.id
  }
  tags = {
    Name : "${var.env_perfix}-main-rtb"
  } 
}

resource "aws_default_security_group" "default-sg" {
 # name        = "my-app-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }  

   ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  } 

   ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }   
  
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids = []
  } 
   tags = {
    Name : "${var.env_perfix}-default-sg"
  }  
}

/*data "aws_ami" "latest-amazon-linux-image"  {
  most_recent      = true
  owners           = ["amazon"]

 filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value  = data.aws_ami.latest-amazon-linux-image.id 
}*/

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}


resource "aws_instance" "my-app-instance" {
  #ami = data.aws_ami.latest-ami.id 
  ami = "ami-005f9685cb30f234b" 
  instance_type = var.instance_type

  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.AZ

  associate_public_ip_address = true

  key_name = aws_key_pair.ssh-key.key_name

  user_data = <<EOF
                #!/bin/bash 
                sudo yum update -y && sudo yum install -y docker
                sudo systemctl start docker
                sudo usermod -aG docker ec2-user
                docker run -p 8080:80 nginx
              EOF  
  #user_data = file = ("shell-script.sh")

   tags = {
    Name : "${var.env_perfix}-server"
  } 
} 

 