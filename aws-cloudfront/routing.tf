resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  tags = { component = "network" }

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.secondary # us-east-1
}

resource "aws_route53_record" "cert_dns" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

### route53.tf
resource "aws_route53_record" "cdn_dns" {
  depends_on      = [aws_cloudfront_distribution.cdn]
  for_each        = toset(["${var.domain_name}", "www.${var.domain_name}"])
  allow_overwrite = true
  name            = each.key
  type            = "A"
  zone_id         = var.zone_id

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }
}