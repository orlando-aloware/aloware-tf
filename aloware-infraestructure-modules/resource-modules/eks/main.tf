module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa = var.enable_irsa

  cluster_addons = var.cluster_addons

  eks_managed_node_groups = var.eks_managed_node_groups

  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  node_security_group_additional_rules    = var.node_security_group_additional_rules

  cluster_enabled_log_types = var.cluster_enabled_log_types

  tags = var.tags
}
