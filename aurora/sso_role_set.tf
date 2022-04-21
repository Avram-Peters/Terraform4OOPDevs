provider "aws" {
  alias = "sso"
  profile = var.sso_profile
  region = "us-east-1"
}

data aws_ssoadmin_instances sso_admin {
  provider = aws.sso
}

#### READONLY
resource aws_ssoadmin_permission_set readonly {
  provider = aws.sso
  name = "RDS-IAMRO"
  description = "ReadOnly access Permission Set"
  instance_arn = tolist(data.aws_ssoadmin_instances.sso_admin.arns)[0]
}
data aws_iam_policy_document sso_readonly {
  statement {
    sid = "readonly"
    effect = "Allow"
    actions = [
      "rds-db:connect"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora_cluster.cluster_resource_id}/ro_{aws:userid}"]
  }
  statement {
    sid = "readonly"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
  }
}
resource aws_ssoadmin_permission_set_inline_policy sso_readonly {
  provider = aws.sso
  inline_policy      = data.aws_iam_policy_document.sso_readonly.json
  instance_arn       = aws_ssoadmin_permission_set.readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
}
resource aws_ssoadmin_account_assignment sso_readonly {
  provider = aws.sso
  instance_arn       = aws_ssoadmin_permission_set.readonly.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn

  principal_id = aws_ssoadmin_permission_set.readonly.id //data.aws_identitystore_group.sso_admin.group_id
  principal_type = "GROUP"
  target_id = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

#### READWRITE
resource aws_ssoadmin_permission_set readwrite {
  provider = aws.sso
  name = "RDS-IAMRW"
  description = "ReadWrite access Permission Set"
  instance_arn = tolist(data.aws_ssoadmin_instances.sso_admin.arns)[0]
}
data aws_iam_policy_document sso_readwrite {
  statement {
    sid = "readwrite"
    effect = "Allow"
    actions = [
      "rds-db:connect"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora_cluster.cluster_resource_id}/rw_{aws:userid}"]
  }
  statement {
    sid = "readwrite"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
  }
}
resource aws_ssoadmin_permission_set_inline_policy sso_readwrite {
  provider = aws.sso
  inline_policy      = data.aws_iam_policy_document.sso_readonly.json
  instance_arn       = aws_ssoadmin_permission_set.readwrite.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readwrite.arn
}
resource aws_ssoadmin_account_assignment sso_readwrite {
  provider = aws.sso
  instance_arn = aws_ssoadmin_permission_set.readwrite.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readwrite.arn

  principal_id =  aws_ssoadmin_permission_set.readwrite.id //data.aws_identitystore_group.sso_admin.group_id
  principal_type = "GROUP"
  target_id = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

// SQLPad
// Fargate for SQLPad
