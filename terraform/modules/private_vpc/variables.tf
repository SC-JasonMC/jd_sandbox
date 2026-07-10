variable "accounts" {
  description = "List of account objects from root module"
  type = list(object({
    name = string
    id   = string
    cidr = string
  }))
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnets_count" {
  description = "Number of private subnets"
  type        = number
}

variable "private_subnets_length" {
  description = "Size of the private subnets CIDR Range"
  type        = number
}

variable "vpc_flow_logs_role" {
  description = "IAM role for VPC Flow Logs"
  type        = string
}

# variable "tgw_id" {
#   description = "Transit Gateway ID"
#   type        = string
# }

# variable "network_acct_tgw_attach_id" {
#   description = "Resource ID for the transit gateway attachment in the Networking account"
#   type = string
# }

variable "resource_name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "prefix_acct_name" {
  description = "Account name prefix to apply to resource name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type = map(string)
  default = {}
}