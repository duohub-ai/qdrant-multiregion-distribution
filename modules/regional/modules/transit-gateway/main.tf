# modules/regional/modules/transit-gateway/main.tf

resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway for ${var.region}"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "${var.organisation}-tgw-${var.region}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_id

  depends_on = [
    aws_ec2_transit_gateway.tgw
  ]

  tags = {
    Name = "${var.organisation}-tgw-attachment-${var.region}"
  }
}

data "aws_ec2_transit_gateway_route_table" "default" {
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.tgw.id]
  }

  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
}

resource "aws_ec2_tag" "tgw_route_table_name" {
  resource_id = data.aws_ec2_transit_gateway_route_table.default.id
  key         = "Name"
  value       = "${var.organisation}-tgw-rt-${var.region}"
}


locals {
  other_region_cidr_blocks = {
    for region, cidr in var.region_cidr_blocks :
    region => cidr
    if region != var.region
  }
}

resource "aws_ec2_transit_gateway_route" "tgw_routes" {
  for_each = var.first_create ? {} : local.other_region_cidr_blocks

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = var.tgw_peering_attachment_ids[each.key]
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.default.id
}