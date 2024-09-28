
resource "aws_vpc" "main_vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.region_cidr_blocks[var.region]
  tags = {
    Name        = "${var.organisation}-vpc-${var.region}"
    Environment = var.stage
    Region      = var.region
  }
}

# Create a security group within the determined VPC.
resource "aws_security_group" "ecs" {
  name        = "allow_all_outbound_inbound"
  description = "Allow all outbound traffic and EFS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = values(var.region_cidr_blocks)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_outbound_inbound"
  }
}
