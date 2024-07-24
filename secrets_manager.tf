resource "aws_secretsmanager_secret" "db_credentials_secret" {
  name        = "rds-db-credentials"
  description = "RDS database credentials"

  tags = {
    Name = "rds-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_secret" {
  secret_id = aws_secretsmanager_secret.db_credentials_secret.id

  secret_string = jsonencode({
    username = var.db_credentials_username
    password = var.db_credentials_password
  })
}
