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

output "namespace_id" {
  value       = module.namespace.namespace_id
  description = "The ID of the service discovery namespace"
}

output "namespace_arn" {
  value       = module.namespace.namespace_arn
  description = "The ARN of the service discovery namespace"
}

output "hosted_zone_id" {
  value       = module.namespace.hosted_zone_id
  description = "The ID of the hosted zone created by the service discovery namespace"
}

output "service_id" {
  value       = module.service_discovery.service_id
  description = "The ID of the service discovery service"
}

output "service_arn" {
  value       = module.service_discovery.service_arn
  description = "The ARN of the service discovery service"
}
