resource "aws_s3_bucket" "pca_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

data "aws_iam_policy_document" "acmpca_bucket_access" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      aws_s3_bucket.pca_bucket.arn,
      "${aws_s3_bucket.pca_bucket.arn}/*",
    ]

    principals {
      identifiers = ["acm-pca.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_s3_bucket_policy" "acmpca_bucket_policy" {
  bucket = aws_s3_bucket.pca_bucket.id
  policy = data.aws_iam_policy_document.acmpca_bucket_access.json
}

resource "aws_acmpca_certificate_authority" "acm_pca" {
    type = "SUBORDINATE"
    certificate_authority_configuration {
        key_algorithm     = "RSA_4096"
        signing_algorithm = "SHA512WITHRSA"

        subject {
        common_name = var.common_name
        }
    }

    revocation_configuration {

    crl_configuration {
      custom_cname = "${var.common_name}.crl"
      enabled            = true
      expiration_in_days = 7
      s3_bucket_name     = aws_s3_bucket.pca_bucket.id
      s3_object_acl      = "BUCKET_OWNER_FULL_CONTROL"

    }

  }

  depends_on = [aws_s3_bucket_policy.acmpca_bucket_policy]

    permanent_deletion_time_in_days = 7
}


## Also needs certificates.. There are two types in the library. May need both. Figure it out!

## Try and put this in Shared Services and share via RAM to other accounts. Should support cross account

## Cross account should help keep costs down by only needing one PCA, but see if there needs to be separation between prod and non-prod (probably does tbf)