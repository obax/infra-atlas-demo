
################################################################################
# NETWORKING
################################################################################
resource "aws_vpc" "this" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id     = aws_vpc.this.id
  depends_on = [aws_vpc.this]
  tags = {
    Name = "${var.project}-${var.environment}-vpc-ig"
    }
}
# resource "aws_main_route_table_association" "this" {
# }

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id = aws_vpc.this.id
  availability_zone = var.zone_ids[ count.index %  2]
  cidr_block = cidrsubnet(var.cidr_block_public_cidr_block, 4, count.index)
  tags = {
    Name = "${var.project}-vpc-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.this.id
  depends_on = [
    aws_vpc.this
  ]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.project}-vpc-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[ count.index %  2].id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_subnet" "intra_subnet" {
  count = 2
  vpc_id = aws_vpc.this.id
  availability_zone = var.zone_ids[ count.index %  2]
  cidr_block = cidrsubnet(var.cidr_block_private_cidr_block, 4, count.index)
  tags = {
    Name = "${var.project}-vpc-intra-subnet-${count.index + 1}"
  }
}