resource "aws_cloudwatch_event_rule" "synchronizer_schedule" {
  name                = "synchronizer-schedule"
  description         = "Run synchronizer task every day at 8 AM"
  schedule_expression = "cron(0 3 * * ? *)" # Every day at 8 AM - Colombian time (3h + 5h = 8h)
}

resource "aws_cloudwatch_event_target" "synchronizer_target" {
  rule      = aws_cloudwatch_event_rule.synchronizer_schedule.name
  target_id = "synchronizer-target"
  arn       = aws_ecs_cluster.main.arn
  role_arn  = aws_iam_role.eventbridge_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.dummy_task.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
      security_groups = [aws_security_group.ecs_sg_synchronizer.id]
    }
  }

  lifecycle {
    ignore_changes = [
      ecs_target,
    ]
  }
}

resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy" {
  role       = aws_iam_role.eventbridge_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
}
