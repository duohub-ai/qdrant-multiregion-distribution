# modules/regional/variables.tf
variable "stage" {
  type    = string
  default = "dev"
}



variable "region" {
  description = "AWS Region"
  type        = string
}

variable "desired_count" {
  description = "The desired number of ECS tasks for each service"
  default     = 1
}

variable "primary" {
  description = "Whether this region hosts the primary clusters"
  type        = bool
  default     = false
}

variable "organisation" {
  description = "The organisation name"
  type        = string
  default     = "qdrant-test"
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


variable "other_region_cidr_blocks" {
  description = "Map of other regions' CIDR blocks"
  type        = map(string)
  default     = {}
}

variable "tgw_peering_attachment_ids" {
  description = "Map of region names to their TGW peering attachment IDs"
  type        = map(string)
}