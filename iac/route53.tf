data "aws_route53_zone" "hosted_zone" {
  name = "andrelopes.tech"
}

resource "aws_route53_record" "example" {
  for_each = {
    for validationOptions in aws_acm_certificate.root.domain_validation_options : validationOptions.domain_name => {
      name   = validationOptions.resource_record_name
      record = validationOptions.resource_record_value
      type   = validationOptions.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.root.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}

resource "aws_route53_record" "root" {
  name    = "andrelopes.tech"
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
