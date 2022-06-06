resource random_string serial_number_ro {
  length = 5
  lower = true
  upper = false
  special = false
  number = false
}

data aws_iam_policy_document aurora_secret_ro_policy {
  statement {
    effect = "Allow"
    actions = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    principals {
      identifiers = ["arn:aws:sts::077602761468:assumed-role/AWSReservedSSO_RDS-IAMRO_02bbf458e3e75a64/abepeters"]
      type        = "AWS"
    }
    resources = ["*"]
  }
}

resource aws_secretsmanager_secret aurora_secret_ro {
  name = "${data.aws_iam_role.readonly_role.unique_id}/abepeters/${random_string.serial_number_ro.result}"
  description = "Secret for ro-user on ${local.cluster_identifier}"
  recovery_window_in_days = var.secret_recovery_window_in_days
  kms_key_id = aws_kms_key.secrets_manager_kms_key.id
  policy = data.aws_iam_policy_document.aurora_secret_ro_policy.json
}

resource aws_secretsmanager_secret_version secret_ro {
  secret_id = aws_secretsmanager_secret.aurora_secret_ro.id
  secret_string = jsonencode({
    engine = "postgres"
    username = "abepeters_ro"
    password = "tempP@$$word"
    host = aws_rds_cluster.aurora_cluster.endpoint
    port = var.aurora_port
    dbname = var.database_name
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}

/*
resource aws_secretsmanager_secret_rotation secret_rotation_ro {
  rotation_lambda_arn = aws_lambda_function.rotator.arn
  secret_id           = aws_secretsmanager_secret.aurora_secret_ro.id
  rotation_rules {
    automatically_after_days = 30
  }
  tags = var.required_tags
  depends_on = [
    aws_lambda_function.rotator,
    aws_lambda_permission.rotate_permission,
    null_resource.database_role_setup // This will keep the rotator from running before the database is configured.
  ]
}
*/
resource random_string serial_number_rw {
  length = 5
  lower = true
  upper = false
  special = false
  number = false
}

resource aws_secretsmanager_secret aurora_secret_rw {
  name = "${data.aws_iam_role.readwrite_role.unique_id}/abepeters/${random_string.serial_number_rw.result}"
  description = "Secret for rw-user on ${local.cluster_identifier}"
  recovery_window_in_days = var.secret_recovery_window_in_days
  kms_key_id = aws_kms_key.secrets_manager_kms_key.id
}

resource aws_secretsmanager_secret_version secret_rw {
  secret_id = aws_secretsmanager_secret.aurora_secret_rw.id
  secret_string = jsonencode({
    engine = "postgres"
    username = "abepeters_rw"
    password = "tempP@$$word"
    host = aws_rds_cluster.aurora_cluster.endpoint
    port = var.aurora_port
    dbname = var.database_name
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}

/*
resource aws_secretsmanager_secret_rotation secret_rotation_rw {
  rotation_lambda_arn = aws_lambda_function.rotator.arn
  secret_id           = aws_secretsmanager_secret.aurora_secret_rw.id
  rotation_rules {
    automatically_after_days = 30
  }
  tags = var.required_tags
  depends_on = [
    aws_lambda_function.rotator,
    aws_lambda_permission.rotate_permission,
    null_resource.database_role_setup // This will keep the rotator from running before the database is configured.
  ]
}
*/