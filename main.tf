provider "aws" {
  region  = var.region
  profile = "yapchat-terraform"
}

resource "aws_s3_bucket" "cdn_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "YapChat File Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "cdn_block" {
  bucket = aws_s3_bucket.cdn_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "cdn_oac" {
  name                              = "yapchat-oac"
  description                       = "Allow CloudFront to access private S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  comment             = var.cdn_comment

  origin {
    domain_name = aws_s3_bucket.cdn_bucket.bucket_regional_domain_name
    origin_id   = "s3-yapchat"

    origin_access_control_id = aws_cloudfront_origin_access_control.cdn_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-yapchat"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "YapChat CloudFront CDN"
  }
}

resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  bucket = aws_s3_bucket.cdn_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowCloudFrontOnly",
        Effect : "Allow",
        Principal : {
          Service : "cloudfront.amazonaws.com"
        },
        Action : "s3:GetObject",
        Resource : "${aws_s3_bucket.cdn_bucket.arn}/*",
        Condition : {
          StringEquals : {
            "AWS:SourceArn" : aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}