output id { value = aws_rds_cluster.aurora_cluster.id}
output arn { value = aws_rds_cluster.aurora_cluster.arn}
output database_name { value = aws_rds_cluster.aurora_cluster.database_name}
output engine { value = aws_rds_cluster.aurora_cluster.engine}
output cluster_identifier { value = local.cluster_identifier}

output aws_sso_ro { value = data.aws_identitystore_group.sso_readonly}
output aws_sso_rw { value = data.aws_identitystore_group.sso_readwrite}
output role_unique_id_rw { value = data.aws_iam_role.readwrite_role.unique_id }
output role_unique_id_ro { value = data.aws_iam_role.readonly_role.unique_id }
output secrets_policy { value = data.aws_iam_policy_document.aurora_secret_ro_policy.json}
