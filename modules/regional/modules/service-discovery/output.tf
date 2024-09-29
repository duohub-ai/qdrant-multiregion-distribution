output "service_id" {
  value       = aws_service_discovery_service.internal.id
  description = "The ID of the service discovery service"
}

output "service_arn" {
  value       = aws_service_discovery_service.internal.arn
  description = "The ARN of the service discovery service"
}