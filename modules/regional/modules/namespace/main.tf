# modules/regional/modules/namespace/main.tf

data "aws_vpc" "current" {
  filter {
    name   = "tag:Name"
    values = ["${var.organisation}-vpc-${var.region}"]
  }
}

resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "${var.organisation}.${var.region}.internal"
  description = "Private DNS namespace for ${var.organisation} in ${var.region}"
  vpc         = data.aws_vpc.current.id

  tags = {
    Name         = "${var.organisation}-namespace-${var.region}"
    Organisation = var.organisation
    Region       = var.region
    Terraform    = "true"
  }
}