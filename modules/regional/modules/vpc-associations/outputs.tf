output "association_ids" {
  value = {
    for region, association in aws_route53_zone_association.cross_region :
    region => association.id
  }
  description = "Map of regions to their association IDs"
}
