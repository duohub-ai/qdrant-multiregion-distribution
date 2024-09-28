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

  tags = {
    Name = "${var.organisation}-tgw-attachment-${var.region}"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "${var.organisation}-tgw-rt-${var.region}"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}