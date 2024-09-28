# modules/regional/modules/transit-gateway/outputs.tf

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.tgw.id
}

output "transit_gateway_route_table_id" {
  value = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}