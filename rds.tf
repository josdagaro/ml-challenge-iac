resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-serverless-v2-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.03.0"
  database_name           = "mydatabase"
  master_username         = var.db_credentials_username
  master_password         = var.db_credentials_password
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.aurora_key.arn
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  apply_immediately       = true
  skip_final_snapshot     = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name

  tags = {
    Name = "aurora-serverless-v2-cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count                = 1
  identifier           = "aurora-serverless-v2-instance"
  cluster_identifier   = aws_rds_cluster.aurora_cluster.id
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.aurora_cluster.engine
  engine_version       = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name

  tags = {
    Name = "aurora-serverless-v2-instance"
  }
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "aurora-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow traffic to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      aws_security_group.ecs_sg_customers_mngr.id,
      aws_security_group.ecs_sg_synchronizer.id,
      aws_security_group.bastion_sg.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = [
      aws_security_group.ecs_sg_customers_mngr.id,
      aws_security_group.ecs_sg_synchronizer.id,
      aws_security_group.bastion_sg.id
    ]
  }
}
