resource "aws_kms_key" "aurora_key" {
  description             = "KMS CMK for Aurora MySQL Serverless v2"
  deletion_window_in_days = 30

  tags = {
    Name = "aurora_key"
  }
}

resource "aws_kms_alias" "aurora_alias" {
  name          = "alias/aurora_key"
  target_key_id = aws_kms_key.aurora_key.id
}
