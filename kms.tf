resource "aws_kms_key" "aurora_key" {
  description             = "KMS CMK for Aurora MySQL Serverless v2"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "aurora_key"
  }
}

resource "aws_kms_alias" "aurora_alias" {
  name          = "alias/aurora_key"
  target_key_id = aws_kms_key.aurora_key.id
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS CMK for Secrets Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "secrets_key"
  }
}

resource "aws_kms_alias" "secrets_alias" {
  name          = "alias/secrets_key"
  target_key_id = aws_kms_key.secrets_key.id
}
