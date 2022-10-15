data "aws_route53_zone" "hosting_zone" {
  name  = local.hostingZone.name
}

# TODO We could do better by setting the delegation_set_id from an input var
# We would need to save an output thunder_arrow_cloud_delegation_set_id from the https://github.com/romain-cambonie/thunder-network-infrastructure repository
# and set it up as a workspace discoverable variable (through the api)
# var.thunder_arrow_cloud_delegation_set_id
//resource "aws_route53_zone" "average_zone" {
//  name     = join(".", [local.service.average.name, local.parentDomain.name])
//  delegation_set_id = local.parentDomain.delegationSetId
//  tags     = local.tags
//}

//resource "aws_route53_record" "average_name_servers_record" {
//  //for_each        = toset(local.parentDomainNames)
//  name            = aws_route53_zone.average_zone.name
//  allow_overwrite = true
//  ttl             = 30
//  type            = "NS"
//  zone_id         = aws_route53_zone.average_zone.zone_id
//  records         = aws_route53_zone.average_zone.name_servers
//}

//locals {
//  subject_alternative_names = {
//    for policy_file in fileset("${path.root}/assets/policies", "*") : trimsuffix(policy_file, ".json") => {
//      name  = split("_", policy_file)[0]
//      label = trimsuffix(split("_", policy_file)[1], ".json")
//    }
//  }
//}

//resource "aws_acm_certificate" "acm_certificate" {
//  provider                  = aws.us-east-1
//  domain_name               = local.parentDomainName
////  subject_alternative_names = [for item in local.parentDomainNames : "*.${item}"]
//  validation_method         = "DNS"
//
//  lifecycle {
//    create_before_destroy = true
//  }
//
//  tags = local.tags
//}

resource "aws_route53_record" "average_record_ipv4" {
  //for_each = toset(local.parentDomainNames)
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
  //for_each = toset(local.parentDomainNames)
  name     = join(".", [local.service.average.name, data.aws_route53_zone.hosting_zone.name])
  zone_id  = data.aws_route53_zone.hosting_zone.zone_id
  type     = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.average_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.average_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
