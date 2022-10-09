resource "aws_route53_zone" "thunder_arrow_cloud_zone" {
  name     = local.domainName
  tags     = local.tags
}

resource "aws_route53_record" "certificate_validation_main" {
  //for_each        = toset(local.domainName)
  name            = tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_name
  depends_on      = [aws_acm_certificate.acm_certificate]
  zone_id         = aws_route53_zone.thunder_arrow_cloud_zone.zone_id
  type            = tolist(aws_acm_certificate.acm_certificate.domain_validation_options)[0].resource_record_type
  ttl             = "300"
  records         = [sort(aws_acm_certificate.acm_certificate.domain_validation_options[*].resource_record_value)[0]]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "certification_main" {
  //for_each        = toset(local.domainNames)
  provider        = aws.us-east-1
  certificate_arn = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [
    aws_route53_record.certificate_validation_main.fqdn,
  ]
  timeouts {
    create = "48h"
  }
}

resource "aws_route53_zone" "average_zone" {
  name     = join("-",[local.service.average.name, local.domainName])
  tags     = local.tags
}

resource "aws_route53_record" "average_name_servers_record" {
  //for_each        = toset(local.domainNames)
  name            = aws_route53_zone.average_zone.name
  allow_overwrite = true
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.average_zone.zone_id
  records         = aws_route53_zone.average_zone.name_servers
}

//locals {
//  subject_alternative_names = {
//    for policy_file in fileset("${path.root}/assets/policies", "*") : trimsuffix(policy_file, ".json") => {
//      name  = split("_", policy_file)[0]
//      label = trimsuffix(split("_", policy_file)[1], ".json")
//    }
//  }
//}

resource "aws_acm_certificate" "acm_certificate" {
  provider                  = aws.us-east-1
  domain_name               = local.domainName
//  subject_alternative_names = [for item in local.domainNames : "*.${item}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_route53_record" "average_record_ipv4" {
  //for_each = toset(local.domainNames)
  name     = aws_route53_zone.average_zone.name
  zone_id  = aws_route53_zone.average_zone.zone_id
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.average_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.average_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "average_record_ipv6" {
  //for_each = toset(local.domainNames)
  name     = aws_route53_zone.average_zone.name
  zone_id  = aws_route53_zone.average_zone.zone_id
  type     = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.average_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.average_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
