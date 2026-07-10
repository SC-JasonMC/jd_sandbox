terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  shared_credentials_files = ["C:\\Users\\McleodJ\\.aws\\credentials"]
  profile = "softcatsha"
  # assume_role {
  #   role_arn      = "arn:aws:iam::381492207664:role/SoftcatOrgExecutionRole"
  #   session_name  = "terraform"
  # }
  default_tags {
    tags = {
      environment = "sandbox"
      deployed-by = "terraform"
    }
  }
}