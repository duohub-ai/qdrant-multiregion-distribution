# modules/regional/variables.tf

variable "region" {
  description = "AWS Region"
  type        = string
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

variable "tgw_peering_attachment_ids" {
  description = "Map of region names to their TGW peering attachment IDs"
  type        = map(string)
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
}

variable "task_policy_arn" {
  description = "ARN of the task policy"
  type        = string
}

variable "first_create" {
  description = "Whether this is the first region to be created"
  type        = bool
  default     = false
}
