data "aws_iam_policy_document" "odr" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "odr" {
  name   = "odr-${var.nuon_id}"
  policy = data.aws_iam_policy_document.odr.json
}

module "odr_iam_role" {
  # NOTE: the iam role requires the cluster be created, but you can not reference the cluster module in the for_each
  # loop that the eks module uses to iterate over cluster_service_accounts

  source      = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version     = ">= 5.1.0"
  create_role = true

  role_name = "odr-${var.nuon_id}"
  role_path = "/nuon/"

  cluster_service_accounts = {
    (module.eks.cluster_name) = ["${var.waypoint_odr_namespace}:${var.waypoint_odr_service_account_name}"]
  }

  role_policy_arns = {
    custom = aws_iam_policy.odr.arn
  }

  depends_on = [
    aws_iam_policy.odr,
    module.eks,
  ]

  tags = local.tags
}
