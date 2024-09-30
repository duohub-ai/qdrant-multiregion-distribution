# modules/regional/outputs.tf

output "vpc_id" {
  value = data.aws_vpc.selected.id
}

output "vpc_cidr_block" {
  value = data.aws_vpc.selected.cidr_block
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

output "qdrant_service_id" {
  value       = module.service_discovery_qdrant.service_id
  description = "The ID of the service discovery service"
}

output "qdrant_service_arn" {
  value       = module.service_discovery_qdrant.service_arn
  description = "The ARN of the service discovery service"
}
