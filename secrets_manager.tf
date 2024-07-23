resource "aws_secretsmanager_secret" "db_credentials_secret" {
  name        = "rds-db-credentials"
  description = "RDS database credentials"

  secret_string = jsonencode({
    username = var.db_credentials_username
    password = var.db_credentials_password
  })

  tags = {
    Name = "rds-db-credentials"
  }
}
