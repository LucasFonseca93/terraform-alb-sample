
# Main vpc creation
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_data["cidr"]
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-vpc"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
}

# -----------------------------------------------------------------------------------------------
# Public subnets
# 1 - creates a set of subnets iterating the cidr's present in the public_subnet_data variable
# 2 - creates an internet gateway for web communications
# 3 - create a public route table
# 4 - associates public subnets with the public route table
# -----------------------------------------------------------------------------------------------
resource "aws_subnet" "main_vpc_public_subnets" {
  count             = length(var.public_subnet_data["cidr"])
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = element(var.public_subnet_data["cidr"], count.index)
  availability_zone = element(var.public_subnet_data["zones"], count.index)
  tags = {
    Name = "${var.basic_data["name_prefix"]}-${format("%04s", count.index)}-pbl-subnet"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc
  ]
}

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.basic_data["name_prefix"]}-internet-gateway"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc
  ]
}

resource "aws_route_table" "public_subnet_route" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_internet_gateway.id
  }
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-public-route-table"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc,
    aws_internet_gateway.main_internet_gateway
  ]
}

resource "aws_route_table_association" "public_route_assoc" {
  count          = length(var.public_subnet_data["cidr"])
  subnet_id      = element(aws_subnet.main_vpc_public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_subnet_route.id
}

# -----------------------------------------------------------------------------------------------
# Private subnets
# 1 - allocates an elasticip to be used by the nat gateway
# 2 - attach the nat gateway to a public subnet
# 3 - creates a set of subnets iterating the cidr's present in the private_subnet_data variable
# 4 - create a private route table
# 5 - associates private subnets with the private route table
# -----------------------------------------------------------------------------------------------
resource "aws_eip" "nat_gateway_ip" {
  vpc = true
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-nat-elastic-ip"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
      aws_vpc.main_vpc
  ]
}

resource "aws_nat_gateway" "main_nat_gateway" {
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id     = element(aws_subnet.main_vpc_public_subnets.*.id, 0)
  tags = {
    Name  = "${var.basic_data["name_prefix"]}-nat-gateway"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_eip.nat_gateway_ip,
    aws_subnet.main_vpc_public_subnets
  ]
}

resource "aws_subnet" "main_vpc_private_subnets" {
  count             = length(var.private_subnet_data["cidr"])
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = element(var.private_subnet_data["cidr"], count.index)
  availability_zone = element(var.private_subnet_data["zones"], count.index)
  tags = {
    Name = "${var.basic_data["name_prefix"]}-${format("%04s", count.index)}-pvt-subnet"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc
  ]
}

resource "aws_route_table" "private_subnet_route" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_nat_gateway.id
  }
  tags = {
    Name = "${var.basic_data["name_prefix"]}-private-route-table"
    squad = var.basic_data["squad"]
    Owner = var.basic_data["owner"]
  }
  depends_on = [
    aws_vpc.main_vpc,
    aws_nat_gateway.main_nat_gateway
  ]
}

resource "aws_route_table_association" "sympla_intranet_private_routes_assoc" {
  count          = length(var.private_subnet_data["cidr"])
  subnet_id      = element(aws_subnet.main_vpc_private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_subnet_route.id
}

# -----------------------------------------------------------------------------------------------
# Outputs section
# -----------------------------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}
