# modules/regional/modules/transit-gateway/variables.tf

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

variable "tgw_peering_attachment_ids" {
  description = "Map of regions to their TGW peering attachment IDs"
  type        = map(string)
}

variable "region_cidr_blocks" {
  type = map(string)
  default = {
    us-east-1      = "10.0.0.0/16"
    us-west-1      = "10.1.0.0/16"
    eu-west-2      = "10.3.0.0/16"
  }
  description = "CIDR blocks for each region's VPC"
}

variable "first_create" {
  description = "Whether this is the first region to be created"
  type        = bool
  default     = false
}