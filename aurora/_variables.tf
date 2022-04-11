#### Workload-level variables
variable region {
  type = string
  description = "Deployment region"
  default = "us-east-1"
}
variable application_name {
  type = string
  description = "Name of the application"
}
variable environment {
  type = string
  description = "Deployment Environment (dev/qa/prod)"
  validation {
    condition = contains(["demo", "dev", "qa", "test", "prod"], var.environment)
    error_message = "Environment must be in [demo, dev, qa, test, prod]."
  }
}


#### Database Configuration Variables
variable database_name {
  type = string
  description = "Name of the database"
}
variable root_user {
  type = string
  description = "Name of the root-user on setup. This will change at first-rotation"
}
variable root_password {
  type = string
  description = "Password of the root-user on setup. This will change at first-rotation"
  sensitive = true
}
variable aurora_port {
  type = number
  description = "Port assigned to the database for connection"
  default = 5432
}
variable engine {
  type = string
  description = "Database engine selected for this database"
  default = "aurora-postgresql"
}
variable engine_version {
  type = string
  description = "Database engine version selected for this database"
  default= "12.6"
}
variable deletion_protection {
  type = bool
  description = "Enable deletion protection? true=enabled/false=disabled. Default=false. Production should be true."
  default = false
}
variable apply_immediately {
  type = bool
  description = "Apply changes immediately? true=yes/false=do at next maintenance window"
  default = true
}
variable preferred_backup_window {
  type = string
  description = "Preferred time-box to run backups"
  default = "04:00-09:00"
}
variable skip_final_snapshot {
  type = bool
  description = "Upon deletion, skip the final snapshot? true=yes/false=create snapshot. Default=false. Production should be false."
  default = false
}
variable cluster_instance_class {
  type = string
  description = "Size of the instances for the aurora cluster"
  default = "db.t3.medium"
}
variable auto_minor_version_upgrade {
  type =bool
  description = "Automatically set minor version upgrades"
  default = true
}

variable number_of_instances {
  type = number
  description = "Number of instances to deploy in the cluster."
  default = 1
}


#### Tagging
variable required_tags {
  type = map(string)
  description = "Required tags for ALL RESOURCES."
}

variable data-at-rest-tags {
  type = map(string)
  description = "Required tags for DATA AT REST resources."
}


#### Secretsmanager Variables
variable secret_recovery_window_in_days {
  type = number
  description = "Once deleted, a secret is recoverable. How long until it's no longer recoverable?"
  default = 7
  validation {
    condition = (var.secret_recovery_window_in_days >=7 && var.secret_recovery_window_in_days <= 30)
    error_message = "Recovery Window must be between 7 and 30 days (inclusive)."
  }
}