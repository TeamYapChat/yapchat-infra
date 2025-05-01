output "cdn_domain" {
  description = "The CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.cdn_bucket.id
}