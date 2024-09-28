
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region              = "eu-west-2"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge({
      }, {
      for key, value in var.custom_tags
      : replace("${var.organisation}:${key}", "_", ":") => value
    })
  }
}

provider "aws" {
  region              = "eu-west-2"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids
  alias               = "eu-west-2"

  default_tags {
    tags = merge({
      }, {
      for key, value in var.custom_tags
      : replace("${var.organisation}:${key}", "_", ":") => value
    })
  }
}

module "eu_west_2" {
  source = "./region"
  providers = {
    aws = aws.eu-west-2
  }
  region     = "eu-west-2"
  stage      = var.stage
  create_vpc = true
  organisation = var.organisation
}

provider "aws" {
  region              = "us-east-1"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids
  alias               = "us-east-1"

  default_tags {
    tags = merge({
      }, {
      for key, value in var.custom_tags
      : replace("${var.organisation}:${key}", "_", ":") => value
    })
  }
}

module "us_east_1" {
  source = "./region"
  providers = {
    aws = aws.us-east-1
  }
  region     = "us-east-1"
  stage      = var.stage
  create_vpc = true
  organisation = var.organisation
}


provider "aws" {
  region              = "us-west-1"
  profile             = local.profile
  allowed_account_ids = var.allowed_account_ids
  alias               = "us-west-1"

  default_tags {
    tags = merge({
      }, {
      for key, value in var.custom_tags
      : replace("${var.organisation}:${key}", "_", ":") => value
    })
  }
}

module "us_west_1" {
  source = "./region"
  providers = {
    aws = aws.us-west-1
  }
  region     = "us-west-1"
  stage      = var.stage
  create_vpc = true
  organisation = var.organisation
}





