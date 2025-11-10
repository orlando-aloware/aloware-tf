# Networking Composite Module

Creates a complete VPC networking setup for Aloware applications.

## Features

- VPC with customizable CIDR
- Public, private, and database subnets across multiple AZs
- NAT Gateways for private subnet internet access
- VPC Flow Logs for network monitoring
- Security groups for common use cases

## Usage

```hcl
module "networking" {
  source = "git::https://github.com/aloware/aloware-infraestructure-modules.git//composite-modules/networking?ref=v1.0.0"

  vpc_name = "aloware-dev-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets   = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
  
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
| vpc_name | Name of the VPC | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | - | yes |
| availability_zones | List of AZs | list(string) | - | yes |
| private_subnets | Private subnet CIDRs | list(string) | - | yes |
| public_subnets | Public subnet CIDRs | list(string) | - | yes |
| database_subnets | Database subnet CIDRs | list(string) | [] | no |
| enable_nat_gateway | Enable NAT Gateway | bool | true | no |
| single_nat_gateway | Use single NAT Gateway | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| private_subnet_ids | Private subnet IDs |
| public_subnet_ids | Public subnet IDs |
| database_subnet_ids | Database subnet IDs |
| nat_gateway_ids | NAT Gateway IDs |
