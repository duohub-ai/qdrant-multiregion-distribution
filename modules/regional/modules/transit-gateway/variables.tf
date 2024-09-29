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

variable "other_region_cidr_blocks" {
  description = "Map of other regions to their CIDR blocks"
  type        = map(string)
}

variable "tgw_peering_attachment_ids" {
  description = "Map of regions to their TGW peering attachment IDs"
  type        = map(string)
}