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
  tgw_routes = [
    for region, cidr in var.other_region_cidr_blocks : {
      destination_cidr_block = cidr
      transit_gateway_id     = module.transit_gateway.transit_gateway_id
    }
  ]
}

module "transit_gateway" {
  source       = "./modules/transit-gateway"
  region       = var.region
  organisation = var.organisation
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.subnet_ids
}


 resource "aws_ec2_transit_gateway_route" "tgw_routes" {
   for_each = {
     for region, cidr in var.other_region_cidr_blocks : 
     region => cidr if region != var.region
   }
   
   depends_on = [
     module.transit_gateway
   ]
 
   destination_cidr_block         = each.value
   transit_gateway_attachment_id  = var.tgw_peering_attachment_ids[each.key]
   transit_gateway_route_table_id = module.transit_gateway.transit_gateway_route_table_id
 }