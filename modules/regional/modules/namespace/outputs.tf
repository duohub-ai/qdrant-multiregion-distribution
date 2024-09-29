output "namespace_id" {
  value       = aws_service_discovery_private_dns_namespace.internal.id
  description = "The ID of the service discovery namespace"
}

output "namespace_arn" {
  value       = aws_service_discovery_private_dns_namespace.internal.arn
  description = "The ARN of the service discovery namespace"
}

output "hosted_zone_id" {
  value       = aws_service_discovery_private_dns_namespace.internal.hosted_zone
  description = "The ID of the hosted zone created by the service discovery namespace"
}

output "namespace_name" {
  value       = aws_service_discovery_private_dns_namespace.internal.name
  description = "The name of the service discovery namespace"
}
