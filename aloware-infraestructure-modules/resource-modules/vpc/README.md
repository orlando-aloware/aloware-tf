# VPC Resource Module

Creates AWS VPC with proper configuration for production workloads.

## Usage

```hcl
module "vpc" {
  source = "../../resource-modules/vpc"

  name = "aloware-dev-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  
  tags = {
    Environment = "development"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | VPC name | string | - | yes |
| cidr | VPC CIDR block | string | - | yes |
| azs | Availability zones | list(string) | - | yes |
| private_subnets | Private subnet CIDRs | list(string) | - | yes |
| public_subnets | Public subnet CIDRs | list(string) | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| private_subnet_ids | Private subnet IDs |
| public_subnet_ids | Public subnet IDs |
