resource aws_security_group aurora_security_group {
  vpc_id = data.aws_vpc.deployable_vpc.id
  name = "${var.application_name}-${var.environment}-sg"

  ingress {
    from_port = var.aurora_port
    protocol  = "tcp"
    to_port   = var.aurora_port
  }
}

  resource aws_security_group_rule aurora_egress {
    from_port         = var.aurora_port
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = var.aurora_port
    type              = "egress"
    cidr_blocks = [data.aws_vpc.deployable_vpc.cidr_block]
  }

  resource aws_security_group_rule aurora_ingress {
    from_port         = var.aurora_port
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = var.aurora_port
    type              = "ingress"
    cidr_blocks = [data.aws_vpc.deployable_vpc.cidr_block]
  }

  resource aws_security_group_rule aurora_ingress_from_public {
    from_port         = var.aurora_port
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = var.aurora_port
    type              = "ingress"
    cidr_blocks = ["0.0.0.0/0"]
  }

  resource aws_security_group_rule sg_recursive_ingress {
    from_port         = 0
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = 65535
    type              = "ingress"
    source_security_group_id = aws_security_group.aurora_security_group.id
  }

  resource aws_security_group_rule sg_recursive_egress {
    from_port         = 0
    protocol          = "TCP"
    security_group_id = aws_security_group.aurora_security_group.id
    to_port           = 65535
    type              = "egress"
    source_security_group_id = aws_security_group.aurora_security_group.id
  }




data aws_iam_policy_document rds-service {
  statement {
    sid= "RDSPolicy"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithSAML",
      "sts:TagSession"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

##### READ_ONLY SSO Role
resource aws_iam_role ro_rds_iam_auth_role {
  assume_role_policy = data.aws_iam_policy_document.rds-service.json
  name = "RDS_IAM_AUTH_RO"

}
data aws_iam_policy_document ro_rds_iam_auth_policy {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["rds-db:connect"]
    resources = ["arn:${data.aws_partition.current.partition}:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora_cluster.cluster_resource_id}/ro_{aws:userid}"]
  }
}
resource aws_iam_role_policy ro_rds_policy {
  name = "RdsIamAuthRolePolicy_ro"
  role       = aws_iam_role.ro_rds_iam_auth_role.id
  policy     = data.aws_iam_policy_document.ro_rds_iam_auth_policy.json
}

##### READ_WRITE SSO Role
resource aws_iam_role rw_rds_iam_auth_role {
  assume_role_policy = data.aws_iam_policy_document.rds-service.json
  name = "RDS_IAM_AUTH_RW"

}
data aws_iam_policy_document rw_rds_iam_auth_policy {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["rds-db:connect"]
    resources = ["arn:${data.aws_partition.current.partition}:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.aurora_cluster.cluster_resource_id}/rw_{aws:userid}"]
  }
}
resource aws_iam_role_policy rds_policy {
  name = "RdsIamAuthRolePolicy_rw"
  role       = aws_iam_role.rw_rds_iam_auth_role.id
  policy     = data.aws_iam_policy_document.rw_rds_iam_auth_policy.json
}

