module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.eks_name
  kubernetes_version = var.k8s_ver

  # Optional
  endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = var.vpc_info.id
  subnet_ids = var.vpc_info.private_subnets

  tags = {
    Environment = "${var.client_id}"
    Terraform   = "true"
  }
}