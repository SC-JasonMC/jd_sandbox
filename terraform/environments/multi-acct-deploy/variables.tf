# Account Info
variable "accounts" {
  type = list(object({
    name = string
    id   = string
    cidr = string
  }))
  default = [
    { name = "client01",      id = "396662537168",    cidr = "10.1.0.0/20" }
  ]
}

variable "public_subnets_count" {
  description = "Number of public subnets"
  default     = 3
  type        = number
  validation {
    condition     = var.public_subnets_count >= 2
    error_message = "Number of public subnets needs to be greater than or equal to 2"
  }
}

variable "private_subnets_count" {
  description = "Number of private subnets"
  default     = 3
  type        = number
  validation {
    condition     = var.private_subnets_count >= 3
    error_message = "Number of private subnets needs to be greater than or equal to 2"
  }
}

variable "public_subnets_length" {
  description = "Size of the public subnets CIDR Range"
  default     = 24
  type        = number
  validation {
    condition     = var.public_subnets_length >= 16 && var.public_subnets_length <=28
    error_message = "Public subnet length needs to be between /16 and /28"
  }
}

variable "private_subnets_length" {
  description = "Size of the private subnets CIDR Range"
  default     = 24
  type        = number
  validation {
    condition     = var.private_subnets_length >= 16 && var.private_subnets_length <=28
    error_message = "Private subnet length needs to be between /16 and /28"
  }
}

variable "project_resource_name_prefix" {
    description = "Project prefix to apply to resources"
    type        = string
    default     = "plexal"
}

variable "credential_profile" {
    description = "Profile from Credentials File to use for access"
    type = string
    default = "sandbox"
}

variable "terraform_exec_role" {
    description = "TerraformExecRole Name"
    type = string
    default = "TerraformExecRole"
}

variable "credential_file_path" {
    description = "Credentials file path"
    type = string
    default = "C:\\Users\\McleodJ\\.aws\\credentials"
}

variable "target_region" {
    description = "Region to deploy the resources to"
    type = string
    default = "us-east-1"
}

variable "target_region_id" {
    description = "Region to deploy the resources to"
    type = string
    default = "use1"
}
