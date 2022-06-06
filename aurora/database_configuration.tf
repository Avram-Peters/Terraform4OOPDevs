resource null_resource database_role_setup {
  depends_on = [aws_rds_cluster_instance.aurora_instance]

  provisioner "local-exec" {
    command = "psql -f ${path.module}/database_configuration_ssm.sql;"
    environment = {
      PGHOST = aws_rds_cluster.aurora_cluster.endpoint
      PGPORT = var.aurora_port
      PGDATABASE = var.database_name
      PGUSER = var.root_user
      PGPASSWORD = var.root_password
    }
  }

  provisioner  "local-exec"{
    command = "pg_restore -d ${var.database_name} ${path.module}/artifacts/dvdrental.tar;"
    environment = {
      PGHOST = aws_rds_cluster.aurora_cluster.endpoint
      PGPORT = var.aurora_port
      PGDATABASE = var.database_name
      PGUSER = var.root_user
      PGPASSWORD = var.root_password
    }
  }
}

/*
{
  "dbname": "aurorademo",
  "engine": "postgres",
  "host": "demo-aurora-demo-aurora-cluster.cluster-cg1m06qmf5bm.us-east-1.rds.amazonaws.com",
  "password": "e%3]M,&J6xUH?F,wg;HlNH.0-~++mi6A",
  "port": 10924,
  "username": "thisisalongusername1234"
}
*/