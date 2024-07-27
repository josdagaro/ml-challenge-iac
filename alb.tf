locals {
  alb_domain = "alb.${var.r53_private_domain}"
}

resource "aws_lb" "main" {
  name                       = "alb-0"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "customers_mngr_tg" {
  name        = "customers-mngr-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customers_mngr_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  #checkov:skip=CKV_AWS_131:This internal ALB is for testing purposes
  #checkov:skip=CKV_AWS_150:This internal ALB is for testing purposes
  #checkov:skip=CKV_AWS_91:This internal ALB is for testing purposes
  name        = "alb_sg"
  description = "Allow HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "For testing purposes"
    cidr_blocks = concat([var.vpc_cidr], var.allowed_customers_mngr_consumers)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "For testing purposes"
    cidr_blocks = concat([var.vpc_cidr], var.allowed_customers_mngr_consumers)
  }
}
