variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "stage" {
  description = "The deployment stage (e.g., dev, prod)"
  type        = string
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

variable "create_vpc" {
  description = "Whether to create a new VPC or use an existing one"
  type        = bool
  default     = true
}

variable "organisation" {
  description = "The organisation name"
  type        = string
}
