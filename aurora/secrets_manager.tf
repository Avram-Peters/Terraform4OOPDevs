resource random_string serial_number {
  length = 5
  lower = true
  upper = false
  special = false
  number = false
}

resource aws_kms_key secrets_manager_kms_key {
  deletion_window_in_days = 7
  description = "CMK for the ${var.application_name} secretsmanager"
  enable_key_rotation = true
  is_enabled = true
  policy = data.aws_iam_policy_document.aurora_kms_policy.json
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  tags = var.required_tags
}

resource aws_secretsmanager_secret aurora_secret {
  name = "${var.application_name}-${var.environment}-${random_string.serial_number.result}"
  description = "Secret for root-user on ${local.cluster_identifier}"
  recovery_window_in_days = var.secret_recovery_window_in_days
  kms_key_id = aws_kms_key.secrets_manager_kms_key.id
}

resource aws_secretsmanager_secret_version secret {
  secret_id = aws_secretsmanager_secret.aurora_secret.id
  secret_string = jsonencode({
    engine = "postgres"
    username = var.root_user
    password = var.root_password
    host = aws_rds_cluster.aurora_cluster.endpoint
    port = var.aurora_port
    dbname = var.database_name
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource aws_secretsmanager_secret_rotation secret_rotation {
  rotation_lambda_arn = aws_lambda_function.rotator.arn
  secret_id           = aws_secretsmanager_secret.aurora_secret.id
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

resource aws_lambda_function rotator {
  function_name = "${var.application_name}-${var.environment}-rotator"
  handler = "lambda_function.lambda_handler"
  role = aws_iam_role.secret_rotator_role.arn
  timeout = 15


  filename = "artifacts/Archive.zip"
  source_code_hash = filebase64sha256("artifacts/Archive.zip")

  vpc_config {
    security_group_ids = [aws_security_group.aurora_security_group.id]
    subnet_ids         = data.aws_subnets.secured_subnets.ids

  }
  runtime = "python3.7"
  kms_key_arn = aws_kms_key.secrets_manager_kms_key.arn

  environment {
    variables = {
      EXCLUDE_CHARACTERS = ":/@\"\\"
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
  tags = var.required_tags
}

resource aws_vpc_endpoint secrets_manager_endpoint {

  service_name = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_id = data.aws_vpc.deployable_vpc.id
  private_dns_enabled = true
  vpc_endpoint_type = "Interface"
  subnet_ids = data.aws_subnets.secured_subnets.ids
  security_group_ids = [aws_security_group.aurora_security_group.id]
  tags = var.required_tags
  depends_on = [aws_security_group.aurora_security_group]
  route_table_ids = []

}