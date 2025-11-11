terraform {
  source = "${get_repo_root()}/../../aloware-infraestructure-modules//composite-modules/eks-cluster"
}

include "root" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  aws_account_id = local.env_vars.locals.aws_account_id
  env            = local.env_vars.locals.env
  aws_region     = local.env_vars.locals.aws_region
}

# Depend on networking module
dependency "networking" {
  config_path = "../networking"
  
  mock_outputs = {
    vpc_id              = "vpc-mock-id"
    private_subnet_ids  = ["subnet-mock-1", "subnet-mock-2", "subnet-mock-3"]
    public_subnet_ids   = ["subnet-mock-public-1", "subnet-mock-public-2"]
  }
}

inputs = {
  # EKS Cluster Configuration
  cluster_name    = local.env_vars.locals.eks_cluster_name
  cluster_version = "1.28"
  
  # Networking
  vpc_id             = dependency.networking.outputs.vpc_id
  subnet_ids         = dependency.networking.outputs.private_subnet_ids
  control_plane_subnet_ids = dependency.networking.outputs.private_subnet_ids
  
  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true
  
  # Cluster Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  
  # Node Groups
  eks_managed_node_groups = {
    general = {
      name           = "aloware-${local.env}-general"
      instance_types = ["t3a.medium", "t3.medium"]
      
      min_size     = 2
      max_size     = 10
      desired_size = 3
      
      # Use spot instances for dev to save costs
      capacity_type = local.env == "development" ? "SPOT" : "ON_DEMAND"
      
      labels = {
        role = "general"
        environment = local.env
      }
      
      tags = {
        NodeGroup = "general"
      }
    }
    
    application = {
      name           = "aloware-${local.env}-application"
      instance_types = ["t3a.large", "t3.large"]
      
      min_size     = local.env == "production" ? 3 : 1
      max_size     = local.env == "production" ? 20 : 10
      desired_size = local.env == "production" ? 5 : 2
      
      capacity_type = local.env == "development" ? "SPOT" : "ON_DEMAND"
      
      labels = {
        role = "application"
        environment = local.env
      }
      
      taints = []
      
      tags = {
        NodeGroup = "application"
        "karpenter.sh/discovery" = local.env_vars.locals.eks_cluster_name
      }
    }
  }
  
  # Cluster Security Group
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }
  
  # Node Security Group
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  
  # Enable MDE for development
  enable_mde = local.env_vars.locals.enable_mde
  
  # CloudWatch logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  # Tags
  tags = {
    Module = "eks-cluster"
    Tier   = "compute"
  }
}
