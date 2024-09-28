variable "stage" {
  description = "The stage of the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "allowed_account_ids" {
  description = "List of allowed AWS account IDs"
  type        = list(string)
  default     = ["488432361986"]
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