variable "stage" {
  description = "The stage of the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "allowed_account_ids" {
  description = "List of allowed AWS account IDs"
  type        = list(string)
  default     = ["AWS_ACCOUNT_ID"]
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
  description = "Predefined CIDR blocks for each region's VPC"
}

variable "first_create" {
  description = "Whether this is the first time you are creating the infrastructure"
  type        = bool
  default     = false
}
