
resource aws_kms_key aurora_key {
  deletion_window_in_days = 7
  description = "CMK for the ${var.application_name} aurora cluster"
  enable_key_rotation = true
  is_enabled = true
  policy = data.aws_iam_policy_document.aurora_kms_policy.json
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  tags = var.required_tags
}

data aws_iam_policy_document aurora_kms_policy {
  policy_id = "kms_policy_id"
  statement {
    sid    = "UserPermissions"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = ["*"]
    actions   = ["kms:*"]
  }
}

resource aws_vpc_endpoint kms_endpoint {
  service_name = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_id = data.aws_vpc.deployable_vpc.id
  private_dns_enabled = true
  vpc_endpoint_type = "Interface"
  subnet_ids = data.aws_subnets.secured_subnets.ids
  security_group_ids = [aws_security_group.aurora_security_group.id]
  tags = var.required_tags
  depends_on = [aws_security_group.aurora_security_group]
}