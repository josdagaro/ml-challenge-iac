resource "aws_ecs_cluster" "main" {
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
    ]
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
  name                 = "synchronizer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "customers_mngr" {
  name                 = "customers-mngr"
  image_tag_mutability = "MUTABLE"

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

resource "aws_security_group" "ecs_sg_synchronizer" {
  name        = "ecs_sg_synchronizer"
  description = "Allow traffic for synchronizer ECS service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg_customers_mngr" {
  name        = "ecs_sg_customers_mngr"
  description = "Allow traffic from ALB to customers_mngr ECS service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
