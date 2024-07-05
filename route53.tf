############ ##########################
# Add the Route 53 DNS A record
data "aws_route53_zone" "main"{
    name = "${data.aws_caller_identity.current.account_id}.realhandsonlabs.net"
}
resource "aws_route53_record" "medium_app_alb_record" {
  zone_id = data.aws_route53_zone.main.zone_id  # Reference your hosted zone
  name    ="medium-apps.${data.aws_caller_identity.current.account_id}.realhandsonlabs.net"  # Change this to your desired subdomain
  type    = "A"

  alias {
    name                   = aws_lb.medium_app_alb.dns_name
    zone_id                = aws_lb.medium_app_alb.zone_id
    evaluate_target_health = true
  }
}
# request a certificate from ACM for your domain.
resource "aws_acm_certificate" "medium_app_cert" {
  domain_name       = "medium-apps.${data.aws_caller_identity.current.account_id}.realhandsonlabs.net"
  validation_method = "DNS"

  tags = {
    Name = "app_cert"
  }
}
# validate the acm certificate
resource "aws_route53_record" "medium_app_cert_validation" {
  for_each = {
    for r in aws_acm_certificate.medium_app_cert.domain_validation_options : r.domain_name => {
      name  = r.resource_record_name
      type  = r.resource_record_type
      value = r.resource_record_value
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.main.zone_id
  records = [each.value.value]
  ttl     = 60
}
