output "ec2-instance-public-ip" {
  value = module.my-app-web-server.instance.public_ip
}


/*output "aws_ami_id" {
  value  = data.aws_ami.latest-amazon-linux-image.id 
}*/