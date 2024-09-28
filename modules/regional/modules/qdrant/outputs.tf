

output "ecs_cluster_id" {
  value = aws_ecs_cluster.qdrant.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.qdrant.name
}

output "service_discovery_namespace_hosted_zone_id" {
  value = aws_service_discovery_private_dns_namespace.qdrant.hosted_zone
}

output "service_discovery_namespace_name" {
  value = aws_service_discovery_private_dns_namespace.qdrant.name
}

