resource "aws_acm_certificate" "cert" {
  domain_name       = local.alb_domain
  validation_method = "DNS"

  tags = {
    Name = local.alb_domain
  }

  lifecycle {
    create_before_destroy = true
  }

  validation_option {
    domain_name       = local.alb_domain
    validation_domain = var.r53_public_domain
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.public.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}
