# modules/regional/main.tf

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.organisation}-vpc-${var.region}"]
  }
}

data "aws_security_group" "security-group" {
  name   = "allow_all_outbound_inbound"
  vpc_id = data.aws_vpc.selected.id
}

module "network" {
  source = "./modules/network"
  region = var.region
  vpc_name = "${var.organisation}-vpc-${var.region}"
  subnet_count = 2
  subnet_name = "${var.organisation}-subnet"
  igw_name = "${var.organisation}-igw"
  route_table_name = "${var.organisation}-route-table"
  ecs_sg_name = "allow_all_outbound_inbound"
  region_cidr_blocks = var.region_cidr_blocks
  transit_gateway_id = module.transit_gateway.transit_gateway_id
}

module "transit_gateway" {
  source       = "./modules/transit-gateway"
  region       = var.region
  organisation = var.organisation
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.subnet_ids
  other_region_cidr_blocks     = var.other_region_cidr_blocks
  tgw_peering_attachment_ids   = var.tgw_peering_attachment_ids
}

module "service_discovery" {
  source         = "./modules/service-discovery"
  organisation   = var.organisation
  region         = var.region
  namespace_id = module.namespace.namespace_id
  service_name = "${var.organisation}-service-${var.region}"
}

module "namespace" {
  source       = "./modules/namespace"
  organisation = var.organisation
  region       = var.region
}

# module "vpc_associations" {
#   source         = "./modules/vpc-associations"
#   organisation   = var.organisation
#   region         = var.region
#   vpc_ids      = var.vpc_ids
#   depends_on = [module.namespace, module.transit_gateway, module.service_discovery]
# }