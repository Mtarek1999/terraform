
resource "aws_subnet" "main" {
  vpc_id     = var.vpc_id 
  cidr_block = var.subnet_var
  availability_zone = var.AZ  
  tags = {
    Name : "${var.env_perfix}-subnet"
  }
}

resource "aws_internet_gateway" "my_app_igw" {
  vpc_id = var.vpc_id  
   tags = {
    Name : "${var.env_perfix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_igw.id
  }
  tags = {
    Name : "${var.env_perfix}-main-rtb"
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