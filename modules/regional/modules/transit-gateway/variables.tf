variable "region" {
  description = "AWS Region"
  type        = string
}

variable "organisation" {
  description = "The organisation name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to attach to the Transit Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to use for the Transit Gateway attachment"
  type        = list(string)
}