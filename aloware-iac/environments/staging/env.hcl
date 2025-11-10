# DONOT MAKE ANY CHANGES TO THIS FILE WITHOUT APPROVAL

locals {
  aws_account_id = "225989345843" # Staging AWS Account ID
  env            = "staging"
  aws_region     = "us-west-2"
  
  # Staging-specific settings
  enable_mde              = false
  eks_cluster_name        = "aloware-eks-staging"
  eks_admin_role_arn      = "arn:aws:iam::225989345843:role/alwr-eks-admin-role-staging"
  
  # Production-like configuration
  enable_nat_gateway         = true
  single_nat_gateway         = false # Multiple NAT gateways for HA
  enable_vpn_gateway         = false
  enable_backup              = true
  backup_retention_days      = 7
  
  # Monitoring
  enable_detailed_monitoring = true
  log_retention_days         = 30
  
  # Auto-scaling
  enable_cluster_autoscaler  = true
  min_nodes                  = 2
  max_nodes                  = 10
}
