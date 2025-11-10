# Use terraform-aws-modules/vpc/aws as the base
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = var.availability_zones
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # VPC Flow Logs
  enable_flow_log                      = var.enable_flow_log
  flow_log_destination_type            = var.flow_log_destination_type
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  flow_log_retention_in_days           = var.flow_log_retention_in_days

  # Subnet tags for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = merge(
    var.tags,
    var.common_tags,
    {
      Name = var.vpc_name
    }
  )
}

# Security Group for Database
resource "aws_security_group" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  name_description = "${var.vpc_name}-database-sg"
  description      = "Security group for database access"
  vpc_id           = module.vpc.vpc_id

  ingress {
    description = "MySQL/Aurora from private subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    var.common_tags,
    {
      Name = "${var.vpc_name}-database-sg"
    }
  )
}
