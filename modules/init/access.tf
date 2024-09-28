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
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_user.terraform.arn,
      ]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/*"]
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
