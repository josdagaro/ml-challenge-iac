data "aws_route53_zone" "public" {
  name         = var.r53_public_domain
  private_zone = false
}

resource "aws_route53_zone" "private" {
  name = var.r53_private_domain
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.private.zone_id
  name    = local.alb_domain
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
