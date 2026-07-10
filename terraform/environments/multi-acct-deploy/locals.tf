locals {
  account_id = { for acct in var.accounts : acct.name => acct.id }
  account_name = { for acct in var.accounts : acct.id => acct.name }
  vpc_cidr = { for acct in var.accounts : acct.id => acct.cidr }
  current_account_id = data.aws_caller_identity.current.account_id
}

locals {
  default_tags = {
    project = "${var.project_resource_name_prefix}"
    deployed-by = "terraform"
  }
}
