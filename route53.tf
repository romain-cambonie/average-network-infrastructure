data "aws_route53_zone" "hosting_zone" {
  name  = local.hostingZone.name
}

resource "aws_route53_record" "average_record_ipv4" {
  name     = join(".", [local.service.average.name, data.aws_route53_zone.hosting_zone.name])
  zone_id  = data.aws_route53_zone.hosting_zone.zone_id
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.average_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.average_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "average_record_ipv6" {
  name     = join(".", [local.service.average.name, data.aws_route53_zone.hosting_zone.name])
  zone_id  = data.aws_route53_zone.hosting_zone.zone_id
  type     = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.average_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.average_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
