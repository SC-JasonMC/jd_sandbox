variable "project_name" {
  description = "The name of the project"
  default     = "sha-test"
  type        = string
}

variable "instance_type" {
  description = "The type for the instance that will run the SHA scripts"
  default     = "t2.micro"
  type        = string

  validation {
    condition     = (
      contains(["t2.micro", "r6i.large", "r6i.xlarge", "r6i.2xlarge", "r5.large", "r5.xlarge", "r5.2xlarge"], var.instance_type)
    )
    error_message = "Check valid values for var: instance_type"
  } 
}

variable "vpc_cidr_block" {
  description = "The main CIDR for the VPC. This doesn't have to be unique, it doesn't connect to existing VPCs."
  default     = "10.100.0.0/20"
  type        = string
}

# variable "intra_subnets_count" {
#   description = "Number of intra subnets. These don't have a route to the internet, they're completely internal"
#   default     = 1
#   type        = number
#   validation {
#     condition     = var.intra_subnets_count >= 1
#     error_message = "Number of intra subnets needs to be greater or equal than 1"
#   }
# }

variable "public_subnets_count" {
  description = "Number of public subnets to house NAT Gateway and internet Gateway. One should suffice for more deployments."
  default     = 1
  type        = number
  validation {
    condition     = var.public_subnets_count >= 1
    error_message = "Number of public subnets needs to be greater or equal than 3"
  }
}

variable "private_subnets_count" {
  description = "Number of private subnets to host the instance(s) that will run the SHA scripts. The VPC endpoints will also go here."
  default     = 1
  type        = number
  validation {
    condition     = var.private_subnets_count >= 1
    error_message = "Number of private subnets needs to be greater or equal than 1"
  }
}

# variable "intra_subnets_length" {
#   description = "Size of the intra subnets CIDR Range. Allow enough space for all planned resources."
#   default     = 28
#   type        = number
#   validation {
#     condition     = var.intra_subnets_length >= 16 && var.intra_subnets_length <=28
#     error_message = "Public subnet length needs to be between /16 and /28"
#   }
# }

variable "public_subnets_length" {
  description = "Size of the public subnets CIDR Range. Allow enough space for all planned resources."
  default     = 28
  type        = number
  validation {
    condition     = var.public_subnets_length >= 16 && var.public_subnets_length <=28
    error_message = "Public subnet length needs to be between /16 and /28"
  }
}

variable "private_subnets_length" {
  description = "Size of the private subnets CIDR Range. Allow enough space for all planned resources."
  default     = 28
  type        = number
  validation {
    condition     = var.private_subnets_length >= 16 && var.private_subnets_length <=28
    error_message = "Private subnet length needs to be between /16 and /28"
  }
}

variable "notification_recipient" {
  description = "Email address to notify when script has completed and outputs have been send to S3."
  default     = "jasonmc@softcat.com"
  type        = string
}

locals {
  vpc_cidr_block_parsed = regex("(?P<range>.+)/(?P<length>.+)", var.vpc_cidr_block)
}

# SHA script variables

variable "parallelism" {
  description = "Number of threads to run in parallel"
  default     = 12
  type        = number
}

variable "finding_output" {
  description = "Findings log level"
  default     = "--status FAIL"
  type        = string
}

variable "account_list" {
  description = "Determines which accounts are included in the scan"
  default     = "thisaccount"
  type        = string

  validation {
    condition     = (
      contains(["allaccounts", "inputfile", "thisaccount"], var.account_list)
    )
    # condition = alltrue([
    #   for v in var.account_list : (
    #     StringEquals(["allaccounts", "inputfile", "thisaccount", ]) ||
    #     can(regex("^[0-9]{12}$", v))
    #   )
    # ])
    error_message = "Valid values for var: account_list are (allaccounts, inputfile, thisaccount, or 12 digit account number(s))."
  } 
} 
