provider "aws" {

}

variable AZ {}

variable "cider_blocks_var" {
  description = "cider.block"
   default     = ["10.0.1.0/24","10.0.0.0/16"]
   type        = list
}

#variable "subnet_var" {
 # description = "subnet.cider.block"
 #  default     = "10.0.1.0/24"
 #  type        = string
#}

#variable "vpc_var" {
  #description = "vpc.cider.block"
#}


resource "aws_vpc" "main" {
  #cidr_block = "10.0.0.0/16"
  cidr_block = var.cider_blocks_var[1]
  tags = {
    Name : "dev_vpc"
    #vpc_env : "dev"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  #cidr_block = "10.0.1.0/24"
  cidr_block = var.cider_blocks_var[0]
  availability_zone = var.AZ 
  tags = {
    Name : "dev_subnet"
  }
}

#data "aws_vpc" "existing_vpc" {
    #default = true 
#}

#resource "aws_subnet" "main-2" {
  #vpc_id     = data.aws_vpc.existing_vpc.id
  #cidr_block = "172.31.96.0/20"
  #availability_zone = "us-east-1a"
#}

output "vpc-dev-op" {
  value       = "aws_vpc.main.id"
}

output "subnet-dev-op" {
  value       = "aws_subnet.main.id"
}