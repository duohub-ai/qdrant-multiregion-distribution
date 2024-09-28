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
  default     = ["488432361986"]
}

variable "organisation" {
  description = "The organisation name"
  type        = string
  default     = "qdrant-test"
}
