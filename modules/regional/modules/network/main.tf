# modules/regional/modules/network/main.tf
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = cidrsubnet(var.region_cidr_blocks[var.region], 2, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.subnet_name}-${count.index}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route" "tgw_routes" {
  count = length([
    for route in var.tgw_routes :
    route if route.destination_cidr_block != var.region_cidr_blocks[var.region]
  ])

  route_table_id         = aws_route_table.main.id
  destination_cidr_block = var.tgw_routes[count.index].destination_cidr_block
  transit_gateway_id     = var.tgw_routes[count.index].transit_gateway_id
}

resource "aws_route_table_association" "main" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.main.*.id, count.index)
  route_table_id = aws_route_table.main.id
}

data "aws_security_group" "ecs_service" {
  name   = var.ecs_sg_name
  vpc_id = data.aws_vpc.selected.id
}

data "aws_availability_zones" "available" {}
