locals {
  website_origin_id = "WebsiteBucket"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "AngularWebsite"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.website_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "My Angular Website Distribution"
  default_root_object = "index.html"

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.website_origin_id

    cache_policy_id = aws_cloudfront_cache_policy.website.id

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Sends to the origin and caches it
resource "aws_cloudfront_cache_policy" "website" {
  name = "angular_cache_policy"

  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "none"
    }
    cookies_config {
      cookie_behavior = "all"
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

# Sends to the origin but doesn't cache it
# Must be set with a Cache Policy
# resource "aws_cloudfront_origin_request_policy" "website_origin_request_policy" {
#   name = "origin_request_policy"
#   headers_config {
#     header_behavior = "allViewer"
#   }

#   cookies_config {
#     cookie_behavior = "all"
#   }

#   query_strings_config {
#     query_string_behavior = "all"
#   }
# }

# If CORS is needed, add this
# data "aws_cloudfront_response_headers_policy" "cors_response_headers_policy" {
#   name = "CORS-With-Preflight"
# }
