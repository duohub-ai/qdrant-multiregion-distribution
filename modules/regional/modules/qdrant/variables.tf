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
  description = "The ARN of the IAM role that allows ECS to pull container images and publish logs to CloudWatch"
  type        = string
}

variable "namespace" {
  description = "The namespace for the Service Discovery private DNS"
  type        = string
}

variable "service_discovery_name" {
  description = "The name for the Service Discovery service"
  type        = string
}

variable "organisation" {
  description = "The organisation name"
  type        = string
  default     = "qdrant-test"
}