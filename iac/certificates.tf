resource "aws_acm_certificate" "root" {
  domain_name       = "andrelopes.tech"
  validation_method = "DNS"
  provider          = aws.us-east-1
}
