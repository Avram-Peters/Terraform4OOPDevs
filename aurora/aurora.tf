resource aws_rds_cluster aurora_cluster {

  cluster_identifier = local.cluster_identifier
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aurora_security_group.id]

  database_name = var.database_name
  master_username = var.root_user
  master_password = var.root_password
  port = var.aurora_port

  iam_database_authentication_enabled = length(var.iam_users) > 0 ? true : false

  engine = var.engine
  engine_version = var.engine_version
  storage_encrypted = "true"
  kms_key_id = aws_kms_key.aurora_key.arn
  deletion_protection = var.deletion_protection
  apply_immediately = var.apply_immediately

  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier

  tags = merge(var.required_tags, var.data-at-rest-tags)
  copy_tags_to_snapshot = "true"
}

resource aws_rds_cluster_instance aurora_instance {
  count = var.number_of_instances
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  identifier = "${local.cluster_identifier}-${count.index}"
  instance_class     = var.cluster_instance_class
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  engine = var.engine
  engine_version = var.engine_version
  apply_immediately = var.apply_immediately
  copy_tags_to_snapshot = "true"
  performance_insights_enabled = "false"
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible = "true"

  tags = merge(var.required_tags, var.data-at-rest-tags, {"Name": "${local.cluster_identifier}-${count.index}"})
}


resource aws_db_subnet_group aurora_subnet_group {

  name = "${local.standard_naming_convention}-subnet-group"

#  name = "${var.application_name}-${var.environment}-subnet-group"

  subnet_ids = data.aws_subnets.secured_subnets.ids
  tags = merge(var.required_tags, var.data-at-rest-tags)
}

