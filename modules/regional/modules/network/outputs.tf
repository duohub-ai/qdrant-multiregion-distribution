# modules/regional/modules/network/outputs.tf
output "subnet_ids" {
  value = aws_subnet.main[*].id
}


output "vpc_id" {
  value = data.aws_vpc.selected.id
}