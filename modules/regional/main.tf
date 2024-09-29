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
  tgw_peering_attachment_ids   = var.tgw_peering_attachment_ids
  first_create = var.first_create
  region_cidr_blocks = var.region_cidr_blocks
}

module "namespace" {
  source       = "./modules/namespace"
  organisation = var.organisation
  region       = var.region
}

module "service_discovery_qdrant" {
  source         = "./modules/service-discovery"
  organisation   = var.organisation
  region         = var.region
  namespace_id = module.namespace.namespace_id
  service_name = "${var.organisation}-qdrant-${var.region}"
}

module "qdrant" {
  source = "./modules/qdrant"
  count = var.first_create ? 0 : 1
  region                        = var.region
  organisation                  = var.organisation
  vpc_id                        = module.network.vpc_id
  subnet_ids                    = module.network.subnet_ids
  security_group_id             = data.aws_security_group.security-group.id
  task_role_arn                 = var.task_role_arn
  execution_role_arn            = var.task_role_arn
  service_discovery_service_arn = module.service_discovery_qdrant.service_arn
  service_discovery_name        = module.service_discovery_qdrant.service_name
  namespace_name                = module.namespace.namespace_name
  primary_service_discovery_name = "qdrant-test-qdrant-eu-west-2"
  primary_namespace_name        = "qdrant-test.eu-west-2.internal"
}

