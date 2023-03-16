resource "aws_vpc" "main" {
  cidr_block = var.vpc_var
  tags = {
    Name : "${var.env_perfix}-vpc" 
  }
}

module "my-app-subnet" {
  source = "./modules/subnet"
  subnet_var = var.subnet_var
  AZ = var.AZ
  env_perfix = var.env_perfix
  vpc_id = aws_vpc.main.id
  default_route_table_id = aws_vpc.main.default_route_table_id
}

module "my-app-web-server" {
  source = "./modules/web-server"
  instance_type = var.instance_type
  AZ = var.AZ
  env_perfix = var.env_perfix
  vpc_id = aws_vpc.main.id
  my_ip = var.my_ip
  public_key_location = var.public_key_location
  subnet_id = module.my-app-subnet.subnet.id 
}




 