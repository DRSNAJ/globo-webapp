locals {
  host_list_ssm_name = "/${local.name_prefix}/host-list"
  site_name_ssm_name = "/${local.name_prefix}/site-name"
}

resource "aws_ssm_parameter" "host_names" {
  name  = local.host_list_ssm_name
  type  = "StringList"
  value = join(",", aws_instance.main.*.private_dns)

}

resource "aws_ssm_parameter" "site_name" {
  name  = local.site_name_ssm_name
  type  = "String"
  value = "${local.name_prefix}-taco-wagon"

}

data "aws_iam_policy_document" "ssm_access" {
  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameter"]

    resources = [
      aws_ssm_parameter.host_names.arn,
      aws_ssm_parameter.site_name.arn
    ]
  }

}

resource "aws_iam_policy" "ssm_access" {
  name        = "${local.name_prefix}-ssm-access"
  description = "Policy to allow access to SSM parameters for ${local.name_prefix}"
  policy      = data.aws_iam_policy_document.ssm_access.json

}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  policy_arn = aws_iam_policy.ssm_access.arn
  role       = var.ec2_role_name

}