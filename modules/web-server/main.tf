resource "aws_default_security_group" "default-sg" {
 # name        = "my-app-sg"
  vpc_id      = var.vpc_id 

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
}*/

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}


resource "aws_instance" "my-app-instance" {
  #ami = data.aws_ami.latest-ami.id 
  ami = "ami-005f9685cb30f234b" 
  instance_type = var.instance_type

  subnet_id = var.subnet_id
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