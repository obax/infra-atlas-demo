terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.12"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "aws" {
  region = "us-east-1"
  alias = "use1"
}

resource "cloudflare_record" "uploads" {
  zone_id = var.cloudflare_zone_id
  name    = var.cname_uploads
  value   = var.cname_uploads_value
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "aws_route53_zone" "hosted_zone" {
  name = "${var.cname_backend}.${var.domain_root}."
}

locals {
    hosted_zone_ns = {
        # FYI There's a max of 6 name servers in Route 53
        # this approach helps helps avoid issues around an unknown number of name servers
        one: aws_route53_zone.hosted_zone.name_servers[0],
        two: aws_route53_zone.hosted_zone.name_servers[1],
        three: aws_route53_zone.hosted_zone.name_servers[2],
        four: aws_route53_zone.hosted_zone.name_servers[3]
    }
}

data "aws_route53_zone" "hosted_zone" {
  depends_on = [aws_route53_zone.hosted_zone]
  name         = "${var.cname_backend}.${var.domain_root}."
  private_zone = false
}

resource "cloudflare_record" "api" {
  depends_on = [data.aws_route53_zone.hosted_zone]
  for_each = { for k, val in local.hosted_zone_ns: k => val }
  zone_id = var.cloudflare_zone_id
  name    = var.cname_backend
  value   = each.value
  type    = "NS"
}

resource "aws_route53_record" "main"{
  allow_overwrite = true
  name            = "${var.cname_backend}.${var.domain_root}." # Notice the dot!!!test.main.com"
  ttl             = 172800
  type            = "NS"
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id

  records = data.aws_route53_zone.hosted_zone.name_servers
}

// aws certs have to be in us-east-1

resource "aws_acm_certificate" "api_cert" {
  domain_name       = "${var.cname_backend}.${var.domain_root}"
  validation_method = "DNS"
  provider = aws.use1
}

// these are the dns records required for acm validation
resource "aws_route53_record" "route_53_acm_validation" {
  provider = aws.use1
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "api_validated_acm" {
  provider = aws.use1
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route_53_acm_validation : record.fqdn]
}

resource "aws_api_gateway_domain_name" "api_domain" {
  certificate_arn = aws_acm_certificate_validation.api_validated_acm.certificate_arn
  domain_name     = "${var.cname_backend}.${var.domain_root}"
}

resource "aws_route53_record" "api_domain" {
  name    = "${var.cname_backend}.${var.domain_root}"
  type    = "A"
  zone_id = data.aws_route53_zone.hosted_zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain.cloudfront_zone_id
  }
}