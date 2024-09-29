variable "organisation" {
  type        = string
  description = "The name of the organisation"
}

variable "region" {
  type        = string
  description = "The current AWS region"
}

variable "other_regions" {
  type        = set(string)
  description = "Set of other regions to associate with this namespace"
  default     = ["us-east-1", "us-west-1", "eu-west-2"]
}

variable "vpc_ids" {
  description = "Map of region names to VPC IDs for cross-region associations"
  type        = map(string)
}