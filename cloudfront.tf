data "aws_s3_bucket" "client" {
  bucket = replace("${local.product_information.context.project}_${local.service.average.client.name}", "_", "-")
}

data "aws_acm_certificate" "hosting_domain_acm_certificate" {
  provider = aws.us-east-1
  domain = local.hostingZone.certificateDomain
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_origin_access_identity" "client" {
  comment = "S3 cloudfront origin access identity for ${local.service.average.client.title} service in ${local.projectTitle}"
}

locals {
  s3_origin_id = "${local.service.average.client.name}_s3"
}

resource "aws_cloudfront_distribution" "average_cloudfront" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = [join(".",[local.service.average.name, local.hostingZone.name])]

  custom_error_response {
    error_caching_min_ttl = 7200
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  # S3 Origin
  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.client.cloudfront_access_identity_path
    }

    domain_name = data.aws_s3_bucket.client.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 7200
    min_ttl                = 0
    max_ttl                = 86400
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    trusted_signers = []

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

//    lambda_function_association {
//      event_type   = "viewer-request"
//      lambda_arn   = "arn:aws:lambda:us-east-1:675617695436:function:average-cognito:4"
//      include_body = false
//    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["FR"]
    }

  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.hosting_domain_acm_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }



  tags = local.tags
}

data "aws_iam_policy_document" "client_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.client.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.client.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.client.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.client.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "client" {
  bucket = data.aws_s3_bucket.client.id
  policy = data.aws_iam_policy_document.client_s3_policy.json
}
