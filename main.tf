# main.tf
module "global" {
  source                 = "./modules/global"
  stage                  = var.stage
  organisation           = var.organisation
}

data "aws_s3_bucket" "state_bucket" {
  bucket = "${var.organisation}-terraform-bucket-${var.stage}"
}

data "aws_dynamodb_table" "lock_table" {
  name = "${var.organisation}-terraform-lock-table-${var.stage}"
}


# Providers

provider "aws" {
  region              = "eu-west-2"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids
  assume_role {
    role_arn = "arn:aws:iam::${local.account}:role/${var.organisation}-terraform-assumed-role-${var.stage}"
  }
}

provider "aws" {
  region              = "eu-west-2"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids
  assume_role {
    role_arn = "arn:aws:iam::${local.account}:role/${var.organisation}-terraform-assumed-role-${var.stage}"
  }
  alias = "eu-west-2"
}

provider "aws" {
  region              = "us-east-1"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids
  assume_role {
    role_arn = "arn:aws:iam::${local.account}:role/${var.organisation}-terraform-assumed-role-${var.stage}"
  }
  alias = "us-east-1"
}

provider "aws" {
  region              = "us-west-1"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids
  assume_role {
    role_arn = "arn:aws:iam::${local.account}:role/${var.organisation}-terraform-assumed-role-${var.stage}"
  }
  alias = "us-west-1"
}

# Regional Stacks 

module "eu-west-2" {
  providers = {
    aws = aws.eu-west-2
  }
  source       = "./modules/regional"
  organisation = var.organisation
  region       = "eu-west-2"
  task_role_arn = module.global.ecs_task_role_arn
  task_policy_arn = module.global.ecs_task_policy_arn
  first_create = var.first_create
  region_cidr_blocks = var.region_cidr_blocks
  vpc_peering_connection_ids = {
    us-east-1 = aws_vpc_peering_connection.eu_west_2_to_us_east_1.id,
    us-west-1 = aws_vpc_peering_connection.eu_west_2_to_us_west_1.id
  }
}

module "us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source       = "./modules/regional"
  organisation = var.organisation
  region       = "us-east-1"
  task_role_arn = module.global.ecs_task_role_arn
  task_policy_arn = module.global.ecs_task_policy_arn
  first_create = var.first_create
  region_cidr_blocks = var.region_cidr_blocks
  vpc_peering_connection_ids = {
    eu-west-2 = aws_vpc_peering_connection.eu_west_2_to_us_east_1.id,
    us-west-1 = aws_vpc_peering_connection.us_east_1_to_us_west_1.id
  }
}

module "us-west-1" {
  providers = {
    aws = aws.us-west-1
  }
  source       = "./modules/regional"
  organisation = var.organisation
  region       = "us-west-1"
  task_role_arn = module.global.ecs_task_role_arn
  task_policy_arn = module.global.ecs_task_policy_arn
  first_create = var.first_create
  region_cidr_blocks = var.region_cidr_blocks
  vpc_peering_connection_ids = {
    eu-west-2 = aws_vpc_peering_connection.eu_west_2_to_us_west_1.id,
    us-east-1 = aws_vpc_peering_connection.us_east_1_to_us_west_1.id
  }
}

# VPC Peering Connections
resource "aws_vpc_peering_connection" "eu_west_2_to_us_east_1" {
  provider    = aws.eu-west-2
  vpc_id      = module.eu-west-2.vpc_id
  peer_vpc_id = module.us-east-1.vpc_id
  peer_region = "us-east-1"

  tags = {
    Name = "${var.organisation}-vpc-peering-eu-west-2-to-us-east-1"
  }
}

resource "aws_vpc_peering_connection_accepter" "us_east_1_accept_eu_west_2" {
  provider                  = aws.us-east-1
  vpc_peering_connection_id = aws_vpc_peering_connection.eu_west_2_to_us_east_1.id
  auto_accept               = true

  tags = {
    Name = "${var.organisation}-vpc-peering-us-east-1-accept-eu-west-2"
  }
}

resource "aws_vpc_peering_connection" "eu_west_2_to_us_west_1" {
  provider    = aws.eu-west-2
  vpc_id      = module.eu-west-2.vpc_id
  peer_vpc_id = module.us-west-1.vpc_id
  peer_region = "us-west-1"

  tags = {
    Name = "${var.organisation}-vpc-peering-eu-west-2-to-us-west-1"
  }
}

resource "aws_vpc_peering_connection_accepter" "us_west_1_accept_eu_west_2" {
  provider                  = aws.us-west-1
  vpc_peering_connection_id = aws_vpc_peering_connection.eu_west_2_to_us_west_1.id
  auto_accept               = true

  tags = {
    Name = "${var.organisation}-vpc-peering-us-west-1-accept-eu-west-2"
  }
}

resource "aws_vpc_peering_connection" "us_east_1_to_us_west_1" {
  provider    = aws.us-east-1
  vpc_id      = module.us-east-1.vpc_id
  peer_vpc_id = module.us-west-1.vpc_id
  peer_region = "us-west-1"

  tags = {
    Name = "${var.organisation}-vpc-peering-us-east-1-to-us-west-1"
  }
}

resource "aws_vpc_peering_connection_accepter" "us_west_1_accept_us_east_1" {
  provider                  = aws.us-west-1
  vpc_peering_connection_id = aws_vpc_peering_connection.us_east_1_to_us_west_1.id
  auto_accept               = true

  tags = {
    Name = "${var.organisation}-vpc-peering-us-west-1-accept-us-east-1"
  }
}

resource "aws_route53_zone_association" "cross_region_eu_west_2" {
  for_each = {
    for k, v in local.cross_region_associations : k => v
    if v.target_region == "eu-west-2"
  }

  provider = aws.eu-west-2
  vpc_id   = local.vpc_ids["eu-west-2"]
  zone_id  = local.hosted_zone_ids[each.value.source_region]
}

resource "aws_route53_zone_association" "cross_region_us_east_1" {
  for_each = {
    for k, v in local.cross_region_associations : k => v
    if v.target_region == "us-east-1"
  }

  provider = aws.us-east-1
  vpc_id   = local.vpc_ids["us-east-1"]
  zone_id  = local.hosted_zone_ids[each.value.source_region]
}

resource "aws_route53_zone_association" "cross_region_us_west_1" {
  for_each = {
    for k, v in local.cross_region_associations : k => v
    if v.target_region == "us-west-1"
  }

  provider = aws.us-west-1
  vpc_id   = local.vpc_ids["us-west-1"]
  zone_id  = local.hosted_zone_ids[each.value.source_region]
}

data "aws_caller_identity" "current" {}


