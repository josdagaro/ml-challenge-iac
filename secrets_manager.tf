resource "aws_secretsmanager_secret" "db_credentials_secret" {
  #checkov:skip=CKV2_AWS_57:This Secret Manager is for testing purposes
  name        = "rds-db-credentials"
  description = "RDS database credentials"
  kms_key_id  = aws_kms_key.secrets_key.arn

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
