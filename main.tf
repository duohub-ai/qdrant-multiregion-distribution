# main.tf
module "global" {
  source                 = "./modules/global"
  stage                  = var.stage
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
  source                    = "./modules/regional"
  stage                     = var.stage
  region                    = "eu-west-2"
  organisation              = var.organisation
  primary                   = true
  other_region_cidr_blocks  = {
    for region, cidr in var.region_cidr_blocks : region => cidr if region != "eu-west-2"
  }
  tgw_peering_attachment_ids = {
    "us-east-1" = aws_ec2_transit_gateway_peering_attachment.eu_west_2_to_us_east_1.id,
    "us-west-1" = aws_ec2_transit_gateway_peering_attachment.eu_west_2_to_us_west_1.id
  }
}

module "us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source                    = "./modules/regional"
  stage                     = var.stage
  region                    = "us-east-1"
  organisation              = var.organisation
  primary                   = false
  other_region_cidr_blocks  = {
    for region, cidr in var.region_cidr_blocks : region => cidr if region != "us-east-1"
  }
  tgw_peering_attachment_ids = {
    "eu-west-2" = aws_ec2_transit_gateway_peering_attachment.eu_west_2_to_us_east_1.id,
    "us-west-1" = aws_ec2_transit_gateway_peering_attachment.us_east_1_to_us_west_1.id
  }
}

module "us-west-1" {
  providers = {
    aws = aws.us-west-1
  }
  source                    = "./modules/regional"
  stage                     = var.stage
  region                    = "us-west-1"
  organisation              = var.organisation
  primary                   = false
  other_region_cidr_blocks  = {
    for region, cidr in var.region_cidr_blocks : region => cidr if region != "us-west-1"
  }
  tgw_peering_attachment_ids = {
    "eu-west-2" = aws_ec2_transit_gateway_peering_attachment.eu_west_2_to_us_west_1.id,
    "us-east-1" = aws_ec2_transit_gateway_peering_attachment.us_east_1_to_us_west_1.id
  }
}

# Transit Gateway Peering Attachments
resource "aws_ec2_transit_gateway_peering_attachment" "eu_west_2_to_us_east_1" {
  provider                = aws.eu-west-2
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "us-east-1"
  transit_gateway_id      = module.eu-west-2.transit_gateway_id
  peer_transit_gateway_id = module.us-east-1.transit_gateway_id

  tags = {
    Name = "${var.organisation}-tgw-peering-eu-west-2-to-us-east-1"
  }
}


resource "aws_ec2_transit_gateway_peering_attachment" "eu_west_2_to_us_west_1" {
  provider                = aws.eu-west-2
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "us-west-1"
  transit_gateway_id      = module.eu-west-2.transit_gateway_id
  peer_transit_gateway_id = module.us-west-1.transit_gateway_id

  tags = {
    Name = "${var.organisation}-tgw-peering-eu-west-2-to-us-west-1"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "us_east_1_to_us_west_1" {
  provider                = aws.us-east-1
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "us-west-1"
  transit_gateway_id      = module.us-east-1.transit_gateway_id
  peer_transit_gateway_id = module.us-west-1.transit_gateway_id

  tags = {
    Name = "${var.organisation}-tgw-peering-us-east-1-to-us-west-1"
  }
}

# Transit Gateway Peering Attachment Accepters

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "us_east_1_to_eu_west_2" {
  provider                      = aws.us-east-1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.eu_west_2_to_us_east_1.id

  tags = {
    Name = "${var.organisation}-tgw-peering-accepter-us-east-1-to-eu-west-2"
  }
}


resource "aws_ec2_transit_gateway_peering_attachment_accepter" "us_west_1_to_eu_west_2" {
  provider                      = aws.us-west-1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.eu_west_2_to_us_west_1.id

  tags = {
    Name = "${var.organisation}-tgw-peering-accepter-us-west-1-to-eu-west-2"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "us_west_1_to_us_east_1" {
  provider                      = aws.us-west-1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.us_east_1_to_us_west_1.id

  tags = {
    Name = "${var.organisation}-tgw-peering-accepter-us-west-1-to-us-east-1"
  }
}

data "aws_caller_identity" "current" {}