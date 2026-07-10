variable "bucket_name" {
    description = "Name prefix of the S3 bucket (account id and prefix is added to keep it unique)"
    type = string
}

variable "resource_name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "ec2_s3_access_role" {
  description = "IAM role for EC2 access to the bucket"
  type        = string
}