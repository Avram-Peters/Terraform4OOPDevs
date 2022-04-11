terraform init --backend-config envs/ca-central-1/dev/backend.config
terraform plan --var-file envs/ca-central-1/dev/dev.tfvars
terraform apply --var-file envs/ca-central-1/dev/dev.tfvars
terraform init --backend-config envs/ca-central-1/qa/backend.config
terraform plan --var-file envs/ca-central-1/qa/qa.tfvars
terraform apply --var-file envs/ca-central-1/qa/qa.tfvars
terraform init --backend-config envs/ca-central-1/prod/backend.config
terraform plan --var-file envs/ca-central-1/prod/prod.tfvars
terraform apply --var-file envs/ca-central-1/prod/prod.tfvars


