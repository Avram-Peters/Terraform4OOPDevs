application_name = "demo-aurora"
environment = "demo"
region = "us-east-1"

database_name = "postgres"
root_user = "postgres"
root_password = "abc123ghi" // the secretsmanager auto-rotation feature will rotate this password immediately upon start.
aurora_port = "10924"
skip_final_snapshot = true
number_of_instances = 1

required_tags = {
  costcenter: "abc123"
  manager: "George"
  backupmanager: "Jolene"
  arch_approval_id: "arch1234"
}

data-at-rest-tags = {
  streaming: "YES"
  analytics: "YES"
  nameyourown: "Maybe"
}