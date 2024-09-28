# modules/regional/modules/transit-gateway/outputs.tf

output "transit_gateway_route_table_id" {
  value = data.aws_ec2_transit_gateway_route_table.default.id
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.tgw.id
}

output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
}