variable "stage" {
  type    = string
  default = "dev"
}

variable "custom_tags" {
  default = {

  }
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
