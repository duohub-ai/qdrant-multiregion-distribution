# modules/regional/outputs.tf

output "vpc_id" {
  value = data.aws_vpc.selected.id
}

output "transit_gateway_id" {
  value = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_route_table_id" {
  value = module.transit_gateway.transit_gateway_route_table_id
}

output "qdrant_hosted_zone_id" {
  value = module.qdrant.service_discovery_namespace_hosted_zone_id
}