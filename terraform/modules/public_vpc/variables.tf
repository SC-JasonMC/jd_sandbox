variable "accounts" {
  description = "List of account objects from root module"
  type = list(object({
    name = string
    id   = string
    cidr = string
    cidr_2 = string
  }))
}

variable "public_subnets_count" {
  description = "Number of public subnets"
  type        = number
}

variable "private_subnets_count" {
  description = "Number of private subnets"
  type        = number
}

variable "public_subnets_length" {
  description = "Size of the public subnets CIDR Range"
  type        = number
}

variable "private_subnets_length" {
  description = "Size of the private subnets CIDR Range"
  type        = number
}

variable "resource_name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "prefix_acct_name" {
  description = "Account name prefix to apply to resource name"
  type        = string
}

variable "vpc_flow_logs_role" {
  description = "IAM role for VPC Flow Logs"
  type        = string
}

variable "sharedsvcs_acct_tgw_attach_id" {
    description = "ID of the Shared Services TGW Attachment"
    type = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type = map(string)
  default = {}
}

variable "sharedsvcs_tgw_attach_id" {
  description = "IDs of the TGWs attachments in shared accounts"
  type = string
}

variable "prod_tgw_attach_id" {
  description = "IDs of the TGWs attachments in shared accounts"
  type = string
}

variable "dev_tgw_attach_id" {
  description = "IDs of the TGWs attachments in shared accounts"
  type = string
}

variable "uat_tgw_attach_id" {
  description = "IDs of the TGWs attachments in shared accounts"
  type = string
}