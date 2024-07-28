resource "aws_ecs_cluster" "main" {
  #checkov:skip=CKV_AWS_65:This ECS cluster is for testing purposes
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "dummy_task" {
  family                   = "dummy_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "dummy-container",
    "image": "amazon/amazon-ecs-sample",
    "essential": true,
    "memory": 256,
    "cpu": 256,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "readonlyRootFilesystem": true
  }
]
DEFINITION
}

resource "aws_ecs_service" "synchronizer" {
  name            = "synchronizer"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.dummy_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups = [aws_security_group.ecs_sg_synchronizer.id]
  }
}

resource "aws_ecs_service" "customers_mngr" {
  name            = "customers-mngr"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.dummy_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups = [aws_security_group.ecs_sg_customers_mngr.id]
  }
}

resource "aws_ecr_repository" "synchronizer" {
  #checkov:skip=CKV_AWS_136:This private ECR is for testing purposes
  name                 = "synchronizer"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "customers_mngr" {
  #checkov:skip=CKV_AWS_136:This private ECR is for testing purposes
  name                 = "customers-mngr"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "read_secrets_policy" {
  name        = "read_secrets_policy"
  description = "Policy to allow ECS tasks to read secrets from Secrets Manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "${aws_secretsmanager_secret.db_credentials_secret.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_read_secrets_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.read_secrets_policy.arn
}

resource "aws_security_group" "ecs_sg_synchronizer" {
  name        = "ecs_sg_synchronizer"
  description = "Allow traffic for synchronizer ECS service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "This is for testing purposes"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg_customers_mngr" {
  name        = "ecs_sg_customers_mngr"
  description = "Allow traffic from ALB to customers_mngr ECS service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "For testing purposes"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ecs_sg_customers_mngr_ingress_0" {
  description              = "For testing purposes"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg_customers_mngr.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_sg_customers_mngr_ingress_1" {
  description              = "For testing purposes"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg_customers_mngr.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_cloudwatch_log_group" "syncer_log_group" {
  #checkov:skip=CKV_AWS_338:This CloudWatch log group is for testing purposes
  #checkov:skip=CKV_AWS_158:This CloudWatch log group is for testing purposes
  name              = "/ecs/syncer"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "customers_mngr_log_group" {
  #checkov:skip=CKV_AWS_338:This CloudWatch log group is for testing purposes
  #checkov:skip=CKV_AWS_158:This CloudWatch log group is for testing purposes
  name              = "/ecs/customers-mngr"
  retention_in_days = 7
}
