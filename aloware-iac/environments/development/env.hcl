# DONOT MAKE ANY CHANGES TO THIS FILE WITHOUT APPROVAL

locals {
  aws_account_id = "333629833033" # Development AWS Account ID
  env            = "development"
  aws_region     = "us-west-2"
  
  # Development-specific settings
  enable_mde              = true  # Multi-Developer Environments
  max_mde_namespaces      = 10
  eks_cluster_name        = "aloware-dev-uswest2-eks-cluster-cr-01"
  rds_cluster_endpoint    = "aloware-dev-mde-shared-rds-cr.cluster-cempo0wxi0u3.us-west-2.rds.amazonaws.com"
  
  # Cost optimization for dev
  enable_nat_gateway      = true
  single_nat_gateway      = true  # Cost saving
  enable_vpn_gateway      = false
  enable_backup           = false # No backups in dev
  
  # Monitoring
  enable_detailed_monitoring = false
  log_retention_days         = 7
}
