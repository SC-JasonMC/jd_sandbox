resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.resource_name_prefix}-${data.aws_caller_identity.current.account_id}-${var.bucket_name}"
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]

  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "bucket_access_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.bucket_access_policy.json
}

data "aws_iam_policy_document" "bucket_access_policy" {
  statement {
    sid = "EC2Access"
    principals {
      type        = "AWS"
      identifiers = ["${var.ec2_s3_access_role}"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
  }

  statement {
  sid       = "AdminAccess"
  actions   = [
    "s3:*"
  ]
  resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
  principals {
    type        = "AWS"
    identifiers = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    ]
  }
}
}