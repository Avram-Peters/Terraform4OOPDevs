locals {
  standard_naming_convention = "${var.application_name}-${var.environment}"
}



locals {
  cluster_identifier = "${var.application_name}-${var.environment}-aurora-cluster"
  final_snapshot_identifier = "${local.cluster_identifier}-finalsnapshot"
}