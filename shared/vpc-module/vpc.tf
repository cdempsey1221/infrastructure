# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public-subnets" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.dev.id
  cidr_block        = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = element(var.aws_availability_zones, count.index)

  tags = {
    Name = "${var.environment}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private-subnets" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.dev.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.aws_availability_zones, count.index)

  tags = {
    Name = "${var.environment}-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${var.environment}-vpc-igw"
  }
}

resource "aws_route_table" "dev-route-table" {
  depends_on = [aws_vpc.dev, aws_internet_gateway.igw]

  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = var.cidr_allow_all_traffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-route-table"
  }
}

resource "aws_route_table_association" "associate-public-subnets" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = element(aws_subnet.public-subnets[*].id, count.index)
  route_table_id = aws_route_table.dev-route-table.id
}
