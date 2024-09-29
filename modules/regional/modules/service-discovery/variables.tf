variable "namespace_id" {
  type        = string
  description = "The ID of the namespace to use for service discovery"
}

variable "organisation" {
  type        = string
  description = "The organisation name"
}

variable "region" {
  type        = string
  description = "The current region"
}

variable "service_name" {
  type        = string
  description = "The name of the service to create"
}