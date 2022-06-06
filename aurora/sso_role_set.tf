provider "aws" {
  alias = "sso"
  profile = var.sso_profile
  region = "us-east-1"
}

data aws_ssoadmin_instances sso_admin {
  provider = aws.sso
}

#### READONLY
data aws_iam_roles readonly_roles {
  path_prefix = "/aws-reserved/sso.amazonaws.com"
  name_regex = "RDS-IAMRO"
  depends_on = [aws_ssoadmin_account_assignment.sso_readonly]
}
data aws_iam_role readonly_role {
  name = tolist( data.aws_iam_roles.readonly_roles.names)[0]
}
resource aws_ssoadmin_permission_set readonly {
  provider = aws.sso
  name = "RDS-IAMRO"
  description = "ReadOnly access Permission Set"
  instance_arn = tolist(data.aws_ssoadmin_instances.sso_admin.arns)[0]
}
data aws_iam_policy_document sso_readonly {
#  statement {
#    sid = "readonly"
#    effect = "Allow"
#    actions = [
#      "rds-db:connect"
#    ]
#    resources = ["arn:${data.aws_partition.current.partition}:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora_cluster.cluster_resource_id}/*"]
#  }

  statement {
    sid = "secretsmanagerreadonly"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_iam_role.readonly_role.unique_id}*"]
    condition {
      test     = "StringLike"
      values   = ["${data.aws_iam_role.readonly_role.unique_id}"]
      variable = "aws:userid"
    }
  }
}
resource aws_ssoadmin_permission_set_inline_policy sso_readonly {
  provider = aws.sso
  inline_policy      = data.aws_iam_policy_document.sso_readonly.json
  instance_arn       = aws_ssoadmin_permission_set.readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
}
data aws_identitystore_group sso_readonly {
  provider = aws.sso
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_admin.identity_store_ids)[0]
  filter {
    attribute_path  = "DisplayName"
    attribute_value = "RDSRO"
  }
}
resource aws_ssoadmin_account_assignment sso_readonly {
  provider = aws.sso
  instance_arn       = aws_ssoadmin_permission_set.readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn

  principal_id = data.aws_identitystore_group.sso_readonly.group_id
  principal_type = "GROUP"
  target_id = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

#### READWRITE
data aws_iam_roles readwrite_roles {
  path_prefix = "/aws-reserved/sso.amazonaws.com"
  name_regex = "RDS-IAMRW"
  depends_on = [aws_ssoadmin_account_assignment.sso_readwrite]
}
data aws_iam_role readwrite_role {
  name = tolist( data.aws_iam_roles.readwrite_roles.names)[0]
}
resource aws_ssoadmin_permission_set readwrite {
  provider = aws.sso
  name = "RDS-IAMRW"
  description = "ReadWrite access Permission Set"
  instance_arn = tolist(data.aws_ssoadmin_instances.sso_admin.arns)[0]
}
data aws_iam_policy_document sso_readwrite {
#  statement {
#    sid = "readwrite"
#    effect = "Allow"
#    actions = [
#      "rds-db:connect"
#    ]
#    resources = ["arn:${data.aws_partition.current.partition}:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora_cluster.cluster_resource_id}/rw_{aws:userid}"]
#  }
  statement {
    sid = "secretsmanagerreadwrite"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_iam_role.readwrite_role.unique_id}*"]
  }
}
resource aws_ssoadmin_permission_set_inline_policy sso_readwrite {
  provider = aws.sso
  inline_policy      = data.aws_iam_policy_document.sso_readwrite.json
  instance_arn       = aws_ssoadmin_permission_set.readwrite.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readwrite.arn
}
data aws_identitystore_group sso_readwrite {
  provider = aws.sso
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_admin.identity_store_ids)[0]
  filter {
    attribute_path  = "DisplayName"
    attribute_value = "RDSRW"
  }
}
resource aws_ssoadmin_account_assignment sso_readwrite {
  provider = aws.sso
  instance_arn = aws_ssoadmin_permission_set.readwrite.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readwrite.arn

  principal_id = data.aws_identitystore_group.sso_readwrite.group_id
  principal_type = "GROUP"
  target_id = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

// SQLPad
// Fargate for SQLPad
