# modules/regional/modules/qdrant/variables.tf
variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}


variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the Qdrant service will be deployed"
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the Qdrant service"
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the IAM role that the ECS task will assume"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the IAM role that the ECS task will assume"
  type        = string
}

variable "organisation" {
  description = "The organisation name"
  type        = string
  default     = "qdrant-test"
}

variable "service_discovery_service_arn" {
  description = "The ARN of the Service Discovery service"
  type        = string
}

variable "service_discovery_name" {
  description = "The name of the service discovery service"
  type        = string
}

variable "namespace_name" {
  description = "The name of the service discovery namespace"
  type        = string
}

variable "primary_service_discovery_name" {
  description = "The name of the primary region's service discovery service"
  type        = string
  default     = "qdrant-test-service-eu-west-2"
}

variable "primary_namespace_name" {
  description = "The name of the primary region's service discovery namespace"
  type        = string
  default     = "qdrant-test.eu-west-2.internal"
}