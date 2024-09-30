output "assumed_role_name" {
  value = aws_iam_role.assumed_role.name
}

output "assumed_role_unique_id" {
  value = aws_iam_role.assumed_role.unique_id
}
