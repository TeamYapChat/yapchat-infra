variable "bucket_name" {
    type        = string
    description = "The name of the S3 bucket"
    default     = "yapchat-files"
}

variable "region" {
    type        = string
    description = "AWS region"
    default     = "us-east-1"
}

variable "cdn_comment" {
    type        = string
    description = "A comment for the CloudFront distribution"
    default     = "YapChat file CDN"
}