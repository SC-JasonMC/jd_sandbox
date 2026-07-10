output "s3_bucket_arn" {
  value = aws_s3_bucket.s3_bucket.arn
  description = "Arn of the S3 bucket"
}

output "s3_bucket_id" {
  value = aws_s3_bucket.s3_bucket.id
  description = "ID of the S3 Bucket"
}