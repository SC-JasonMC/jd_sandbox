##########################################
##                  IAM                 ##
##########################################  

# VPC Flowlogs
module "client01_vpcflowlogs_iam" {
  source    = "../../modules/iam/vpc_flow_logs"
  providers = { aws = aws }
  project_resource_name_prefix = var.project_resource_name_prefix
}

# module "client02_vpcflowlogs_iam" {
#   source    = "../../modules/iam/vpc_flow_logs"
#   providers = { aws = aws.client02 }
#   project_resource_name_prefix = var.project_resource_name_prefix
# }

# module "client03_vpcflowlogs_iam" {
#   source    = "../../modules/iam/vpc_flow_logs"
#   providers = { aws = aws.client03 }
#   project_resource_name_prefix = var.project_resource_name_prefix
# }

##########################################
##              Public VPCs             ##
##########################################

# module "client01_vpc" {
#   source             = "../../modules/networking_vpc"
#   providers          = { aws = aws.client01 }
#   resource_name_prefix  = "${var.project_resource_name_prefix}-client01"
#   vpc_flow_logs_role = module.network_vpcflowlogs_iam.vpc_flow_logs_role
#   prefix_acct_name  = "client01"
#   sharedsvcs_acct_tgw_attach_id = module.sharedsvcs_vpc.tgw_attach_id
#   accounts = var.accounts
#   tags = { Environment = "client01" }
#   public_subnets_count = var.public_subnets_count
#   public_subnets_length = var.public_subnets_length
#   private_subnets_count = var.private_subnets_count
#   private_subnets_length = var.private_subnets_length
# }

# module "client02_vpc" {
#   source             = "../../modules/networking_vpc"
#   providers          = { aws = aws.client02 }
#   resource_name_prefix  = "${var.project_resource_name_prefix}-client02"
#   vpc_flow_logs_role = module.network_vpcflowlogs_iam.vpc_flow_logs_role
#   prefix_acct_name  = "client02"
#   sharedsvcs_acct_tgw_attach_id = module.sharedsvcs_vpc.tgw_attach_id
#   accounts = var.accounts
#   tags = { Environment = "client02" }
#   public_subnets_count = var.public_subnets_count
#   public_subnets_length = var.public_subnets_length
#   private_subnets_count = var.private_subnets_count
#   private_subnets_length = var.private_subnets_length
# }

# module "client03_vpc" {
#   source             = "../../modules/networking_vpc"
#   providers          = { aws = aws.client03 }
#   resource_name_prefix  = "${var.project_resource_name_prefix}-client03"
#   vpc_flow_logs_role = module.network_vpcflowlogs_iam.vpc_flow_logs_role
#   prefix_acct_name  = "client03"
#   sharedsvcs_acct_tgw_attach_id = module.sharedsvcs_vpc.tgw_attach_id
#   accounts = var.accounts
#   tags = { Environment = "client03" }
#   public_subnets_count = var.public_subnets_count
#   public_subnets_length = var.public_subnets_length
#   private_subnets_count = var.private_subnets_count
#   private_subnets_length = var.private_subnets_length
# }

##########################################
##              Private VPCs            ##
##########################################

module "client01_vpc" {
  source             = "../../modules/private_vpc"
  providers          = { aws = aws }
  resource_name_prefix = "${var.project_resource_name_prefix}-client01"
  vpc_flow_logs_role = module.client01_vpcflowlogs_iam.vpc_flow_logs_role
  prefix_acct_name  = "client01"
  vpc_cidr_block     = "${local.vpc_cidr[local.current_account_id]}"
  # tgw_id             = module.networking_vpc.tgw_id
  # network_acct_tgw_attach_id = module.networking_vpc.tgw_attach_id
  accounts = var.accounts
  tags = { Environment = "client01" }
  # public_subnets_count = var.public_subnets_count
  # public_subnets_length = var.public_subnets_length
  private_subnets_count = var.private_subnets_count
  private_subnets_length = var.private_subnets_length
}

# module "client02_vpc" {
#   source             = "../../modules/private_vpc"
#   providers          = { aws = aws.client02 }
#   resource_name_prefix = "${var.project_resource_name_prefix}-client02"
#   vpc_flow_logs_role = module.production_vpcflowlogs_iam.vpc_flow_logs_role
#   prefix_acct_name  = "client02"
#   vpc_cidr_block     = "${local.vpc_cidr[local.current_account_id]}"
#   tgw_id             = module.networking_vpc.tgw_id
#   network_acct_tgw_attach_id = module.networking_vpc.tgw_attach_id
#   accounts = var.accounts
#   tags = { Environment = "client02" }
#   # public_subnets_count = var.public_subnets_count
#   # public_subnets_length = var.public_subnets_length
#   private_subnets_count = var.private_subnets_count
#   private_subnets_length = var.private_subnets_length
#   tgw_ram_share_arn = module.networking_vpc.tgw_ram_share_arn
# }

# module "client03_vpc" {
#   source             = "../../modules/private_vpc"
#   providers          = { aws = aws.client03 }
#   resource_name_prefix = "${var.project_resource_name_prefix}-client03"
#   vpc_flow_logs_role = module.dev_vpcflowlogs_iam.vpc_flow_logs_role
#   prefix_acct_name  = "client03"
#   vpc_cidr_block     = "${local.vpc_cidr[local.current_account_id]}"
#   tgw_id             = module.networking_vpc.tgw_id
#   network_acct_tgw_attach_id = module.networking_vpc.tgw_attach_id
#   accounts = var.accounts
#   tags = { Environment = "client03" }
#   # public_subnets_count = var.public_subnets_count
#   # public_subnets_length = var.public_subnets_length
#   private_subnets_count = var.private_subnets_count
#   private_subnets_length = var.private_subnets_length
#   tgw_ram_share_arn = module.networking_vpc.tgw_ram_share_arn
# }

##########################################
##         Compute Resources            ##
########################################## 

# EKS

module "client01_eks" {
  source = "../../modules/eks"
  providers = {
     aws = aws
  }
  vpc_info = module.client01_vpc.vpc_info
  eks_name = "client01_eks"
  k8s_ver = "1.34"
  client_id = "client_01"
  
}

# module "client02_eks" {
#   source = "../../modules/eks"
#   providers = {
#      aws = aws.client02
#   }
#   vpc_info = module.client02_vpc.vpc_info
#   eks_name = "client02_eks"
#   k8s_ver = "1.34"
#   client_id = "client_02"
  
# }

# module "client03_eks" {
#   source = "../../modules/eks"
#   providers = {
#      aws = aws.client03
#   }
#   vpc_info = module.client03_vpc.vpc_info
#   eks_name = "client03_eks"
#   k8s_ver = "1.34"
#   client_id = "client_03"
  
# }

