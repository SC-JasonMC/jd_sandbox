terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "${var.target_region}"
  shared_credentials_files = [
    "${var.credential_file_path}"
  ]
  profile = "${var.credential_profile}"
  default_tags {
    tags = local.default_tags
  }
}
