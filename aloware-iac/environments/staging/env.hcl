# DONOT MAKE ANY CHANGES TO THIS FILE WITHOUT APPROVAL

locals {
  aws_account_id = "225989345843" # Staging AWS Account ID
  env            = "staging"
  
  # Staging-specific settings
  enable_mde              = false
  eks_cluster_name        = "aloware-eks-staging"
  eks_admin_role_arn      = "arn:aws:iam::225989345843:role/alwr-eks-admin-role-staging"
}
