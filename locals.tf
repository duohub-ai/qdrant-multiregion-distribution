
locals {
  account     = "AWS_ACCOUNT_ID"
  profile     =  "AWS_PROFILE_NAME"
  all_regions = ["eu-west-2", "us-east-1", "us-west-1"]
   hosted_zone_ids = {
    "eu-west-2" = module.eu-west-2.hosted_zone_id
    "us-east-1" = module.us-east-1.hosted_zone_id
    "us-west-1" = module.us-west-1.hosted_zone_id
  }
  vpc_ids = {
    "eu-west-2" = module.eu-west-2.vpc_id
    "us-east-1" = module.us-east-1.vpc_id
    "us-west-1" = module.us-west-1.vpc_id
  }
  cross_region_associations = {
    for pair in setproduct(local.all_regions, local.all_regions) : "${pair[0]}-${pair[1]}" => {
      source_region = pair[0]
      target_region = pair[1]
    } if pair[0] != pair[1]
  }
  vpc_peering_connections = {
    "eu-west-2" = {
      "us-east-1" = aws_vpc_peering_connection.eu_west_2_to_us_east_1.id,
      "us-west-1" = aws_vpc_peering_connection.eu_west_2_to_us_west_1.id
    },
    "us-east-1" = {
      "eu-west-2" = aws_vpc_peering_connection.eu_west_2_to_us_east_1.id,
      "us-west-1" = aws_vpc_peering_connection.us_east_1_to_us_west_1.id
    },
    "us-west-1" = {
      "eu-west-2" = aws_vpc_peering_connection.eu_west_2_to_us_west_1.id,
      "us-east-1" = aws_vpc_peering_connection.us_east_1_to_us_west_1.id
    }
  }
}