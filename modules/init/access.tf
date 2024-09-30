data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sts" {
  statement {
    effect    = "Allow"
    actions   = ["sts:TagSession"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sts" {
  name        = "${var.organisation}-terraform-sts-policy-${var.stage}"
  policy      = data.aws_iam_policy_document.sts.json
  description = "Policy for accessing the STS service"
}

resource "aws_iam_user_policy_attachment" "terraform_sts" {
  user       = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.sts.arn
}

resource "aws_iam_user" "terraform" {
  name = "${var.organisation}-terraform-user-${var.stage}"
}

resource "aws_iam_access_key" "terraform_user_key" {
  user = aws_iam_user.terraform.name
}

output "terraform_access_key_id" {
  value     = aws_iam_access_key.terraform_user_key.id
  sensitive = true
}

output "terraform_access_key_secret" {
  value     = aws_iam_access_key.terraform_user_key.secret
  sensitive = true
}

data "aws_iam_policy_document" "role-trust-policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_iam_role" "assumed_role" {
  name               = "${var.organisation}-terraform-assumed-role-${var.stage}"
  assume_role_policy = data.aws_iam_policy_document.role-trust-policy.json
}

output "assumed_role_arn" {
  value = aws_iam_role.assumed_role.arn
}

data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "assumed_role_admin" {
  role       = aws_iam_role.assumed_role.name
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

data "aws_iam_policy_document" "route53_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "route53:*",
      "ec2:DescribeVpcs",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "route53_policy" {
  name        = "${var.organisation}-route53-policy-${var.stage}"
  description = "IAM policy for Route 53 permissions"
  policy      = data.aws_iam_policy_document.route53_permissions.json
}

resource "aws_iam_role_policy_attachment" "assumed_role_route53" {
  role       = aws_iam_role.assumed_role.name
  policy_arn = aws_iam_policy.route53_policy.arn
}

data "aws_iam_policy_document" "ec2_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.organisation}-ec2-policy-${var.stage}"
  description = "IAM policy for EC2 permissions"
  policy      = data.aws_iam_policy_document.ec2_permissions.json
}

resource "aws_iam_role_policy_attachment" "assumed_role_ec2" {
  role       = aws_iam_role.assumed_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}
