output "vpc_id" {
  value = module.network.vpc_id
}


output "subnet_ids" {
  value = module.network.subnet_ids
}

output "transit_gateway_id" {
  value = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_route_table_id" {
  value = module.transit_gateway.transit_gateway_route_table_id
}

