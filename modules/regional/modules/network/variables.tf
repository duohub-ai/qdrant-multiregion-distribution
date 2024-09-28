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

variable "igw_name" {
  description = "The name of the internet gateway"
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

variable "tgw_routes" {
  description = "List of routes to add to the route table for Transit Gateway"
  type = list(object({
    destination_cidr_block = string
    transit_gateway_id     = string
  }))
  default = []
}

variable "region_cidr_blocks" {
  type = map(string)
  description = "CIDR blocks for each region's VPC"
}