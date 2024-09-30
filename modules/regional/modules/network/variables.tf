# modules/regional/modules/network/variables.tf
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnet_count" {
  description = "The number of subnets to create"
  type        = number
  default     = 2
}

variable "subnet_name" {
  description = "The name prefix for the subnets"
  type        = string
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
}

variable "ecs_sg_name" {
  description = "The name of the ECS service security group"
  type        = string
  default     = "allow_all_outbound_inbound"
}

variable "region" {
  description = "AWS Region"
  type        = string
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

variable "vpc_peering_connection_ids" {
  description = "Map of region names to VPC peering connection IDs"
  type        = map(string)
}

variable "igw_name" {
  description = "The name of the internet gateway"
  type        = string
}
