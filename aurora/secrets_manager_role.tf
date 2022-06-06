/*
resource aws_iam_role secret_rotator_role {
  name = "${var.application_name}-${var.environment}-rota-role"
  assume_role_policy = data.aws_iam_policy_document.service.json
  tags = var.required_tags
}


resource aws_iam_role_policy_attachment lambda_basic {
  role = aws_iam_role.secret_rotator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource aws_iam_role_policy_attachment lambda_vpc {
  role = aws_iam_role.secret_rotator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource aws_iam_role_policy secretsmanager_userpolicy0 {
  name = "SecretsManagerUserRolePolicy0"
  role = aws_iam_role.secret_rotator_role.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSPostgresRotation0.json
}
resource aws_iam_role_policy secretsmanager_userpolicy1 {
  name = "SecretsManagerUserRolePolicy1"
  role = aws_iam_role.secret_rotator_role.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSPostgresRotation1.json
}
resource aws_iam_role_policy secretsmanager_userpolicy2 {
  name = "SecretsManagerUserRolePolicy2"
  role = aws_iam_role.secret_rotator_role.name
  policy = data.aws_iam_policy_document.SecretsmanagerRDSPostgresRotation2.json
}






/*
resource aws_lambda_permission rotate_permission {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotator.function_name
  principal = "secretsmanager.amazonaws.com"
  statement_id = "AllowExecutionSecretManager"
}
*/
data aws_iam_policy_document service {
  statement {
    sid = "RotatorPolicy"
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}
data aws_iam_policy_document SecretsManagerRDSPostgresRotation0 {
  statement {
    actions= [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterface",
      "ec2:DetachNetworkInterface"
    ]
    resources = ["*"]
  }
}
/*
data aws_iam_policy_document SecretsManagerRDSPostgresRotation1 {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage"
    ]
    condition {
      test     = "StringEquals"
      values   = ["arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.rotator.function_name}"]
      variable = "secretsmanager:resource/AllowRotationLambdaArn"
    }
    resources = ["arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*"]
  }
  statement {
    actions = ["secretsmanager:GetRandomPassword"]
    resources = ["*"]
  }
}
*/
data aws_iam_policy_document SecretsmanagerRDSPostgresRotation2 {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = [aws_kms_key.secrets_manager_kms_key.arn]
  }
}
