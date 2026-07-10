variable "vpc_info" {
  description = "VPC details from networking module"
  type = object({
    id                      = string
    cidr_block              = string
    private_subnets         = list(string)
    # private_route_table_ids = list(string)
  })
}

variable "eks_name" {
    description = "EKS name"
    type = string
  
}

variable "k8s_ver" {
    description = "Kubernetes Version"
    type = string
  
}

variable "client_id" {
    description = "Client ID"
    type = string
  
}