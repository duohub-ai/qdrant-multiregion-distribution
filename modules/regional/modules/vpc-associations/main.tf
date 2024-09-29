# modules/regional/modules/vpc-associations/main.tf

data "aws_vpc" "current" {
  filter {
    name   = "tag:Name"
    values = ["${var.organisation}-vpc-${var.region}"]
  }
}

data "aws_route53_zone" "current" {
  name         = "${var.organisation}.${var.region}.internal"
  private_zone = true
  vpc_id       = data.aws_vpc.current.id
}

resource "aws_route53_zone_association" "cross_region" {
  for_each = var.vpc_ids
  vpc_id   = each.value
  zone_id  = data.aws_route53_zone.current.zone_id
}

