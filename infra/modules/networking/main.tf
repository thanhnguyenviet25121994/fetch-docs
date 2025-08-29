terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "app_env" {
  type = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "available_zones" {
  description = "The list of available zones"
  type        = list(string)
  default     = ["ap-southeast-1b", "ap-southeast-1c"]
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  enable_dns_hostnames = true

  tags = {
    Name        = var.app_env
    Environment = var.app_env
  }
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.app_env}-IGW"
    Environment = var.app_env
  }
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.this.id
  availability_zone = var.available_zones[0]
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 3)

  tags = {
    Name        = "${var.app_env}-public-1"
    Environment = var.app_env
  }

  depends_on = [
    aws_internet_gateway.this
  ]
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.this.id
  availability_zone = var.available_zones[1]
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 4)

  tags = {
    Name        = "${var.app_env}-public-2"
    Environment = var.app_env
  }

  depends_on = [
    aws_internet_gateway.this
  ]
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.this.id
  availability_zone = var.available_zones[0]
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 6)

  tags = {
    Name        = "${var.app_env}-private-1"
    Environment = var.app_env
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this.id
  availability_zone = var.available_zones[1]
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 4, 7)

  tags = {
    Name        = "${var.app_env}-private-2"
    Environment = var.app_env
  }
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "natgw-ip" {
  tags = {
    Name = "${var.app_env}-NATGW-IP"
  }
}

resource "aws_nat_gateway" "this" {
  connectivity_type = "public"
  allocation_id     = aws_eip.natgw-ip.id
  subnet_id         = aws_subnet.public_1.id

  tags = {
    Name = "${var.app_env}-NATGW"
  }

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.app_env}-private-rtb"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.app_env}-public-rtb"
    Environment = var.app_env
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

output "vpc" {
  value = aws_vpc.this
}

output "subnet_private_1" {
  value = aws_subnet.private_1
}

output "subnet_private_2" {
  value = aws_subnet.private_2
}

output "subnet_public_1" {
  value = aws_subnet.public_1
}

output "subnet_public_2" {
  value = aws_subnet.public_2
}
