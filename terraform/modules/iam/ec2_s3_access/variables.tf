variable "s3_bucket_arn" {
    description = "S3 Bucket Arn"
    type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type = map(string)
  default = {}
}