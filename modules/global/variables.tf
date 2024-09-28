variable "stage" {
  description = "The stage of the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "organisation" {
  description = "The organisation name"
  type        = string
  default     = "qdrant-test"
}