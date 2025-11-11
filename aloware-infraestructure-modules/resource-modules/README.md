# Aloware Infrastructure - Resource Modules

This directory contains atomic Terraform modules for individual AWS resources. Each module is designed to be reusable, composable, and follows Terraform best practices.

## Module Architecture

Resource modules follow a consistent structure:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `versions.tf` - Terraform and provider version constraints
- `README.md` - Module documentation (optional)

## Available Modules

### Compute & Container

#### `eks/`
EKS (Elastic Kubernetes Service) cluster configuration.
- **Purpose**: Creates EKS clusters with managed node groups
- **Wraps**: `terraform-aws-modules/eks/aws` ~> 19.0
- **Key Features**: IRSA support, cluster addons, security group rules, CloudWatch logging
- **Use In**: `composite-modules/eks-cluster/`

### Networking

#### `vpc/`
Virtual Private Cloud configuration.
- **Purpose**: Creates VPC with subnets, NAT gateways, route tables
- **Wraps**: `terraform-aws-modules/vpc/aws` ~> 5.0
- **Key Features**: Multi-AZ support, public/private subnets, NAT gateway configuration
- **Use In**: `composite-modules/networking/`

#### `security-group/`
Security group and rules management.
- **Purpose**: Creates security groups with ingress/egress rules
- **Key Features**: Dynamic rule creation, source security group references, CIDR blocks
- **Use In**: All networking-related composite modules

#### `alb/`
Application Load Balancer configuration.
- **Purpose**: Creates ALB with listeners and target groups
- **Wraps**: `terraform-aws-modules/alb/aws` ~> 8.0
- **Key Features**: HTTP/HTTPS listeners, target group routing, access logs, deletion protection
- **Use In**: `composite-modules/application/`

#### `route53/`
DNS zone and record management.
- **Purpose**: Creates Route53 hosted zones and DNS records
- **Key Features**: Public/private zones, A/CNAME/ALIAS records, VPC association
- **Use In**: `composite-modules/networking/`, `composite-modules/application/`

#### `acm/`
SSL/TLS certificate management.
- **Purpose**: Creates and validates ACM certificates
- **Key Features**: DNS/Email validation, SAN support, Route53 validation records, auto-renewal
- **Use In**: `composite-modules/application/`, ALB HTTPS listeners

### Storage

#### `s3/`
S3 bucket configuration.
- **Purpose**: Creates S3 buckets with security and lifecycle policies
- **Key Features**: Versioning, encryption (AES256/KMS), lifecycle rules, CORS, public access block
- **Use In**: `composite-modules/storage/`, CloudFront distributions

#### `ecr/`
Elastic Container Registry.
- **Purpose**: Creates ECR repositories for Docker images
- **Key Features**: Image scanning, encryption, lifecycle policies, repository policies
- **Use In**: `composite-modules/storage/`, CI/CD pipelines

### Database

#### `rds/`
RDS Aurora database clusters.
- **Purpose**: Creates Aurora MySQL/PostgreSQL clusters
- **Wraps**: `terraform-aws-modules/rds-aurora/aws` ~> 8.0
- **Key Features**: Multi-AZ, automated backups, encryption, parameter groups, monitoring
- **Use In**: `composite-modules/database/`

#### `dynamodb/`
DynamoDB table configuration.
- **Purpose**: Creates DynamoDB tables with indexes
- **Key Features**: On-demand/provisioned billing, GSI/LSI support, streams, point-in-time recovery, encryption
- **Use In**: `composite-modules/database/`, Terraform state locking

### Security & Identity

#### `iam/`
IAM roles, policies, and instance profiles.
- **Purpose**: Creates IAM resources for AWS services and applications
- **Key Features**: Role creation, policy attachment, instance profiles, assume role policies
- **Use In**: All composite modules requiring AWS permissions

#### `kms/`
KMS key management.
- **Purpose**: Creates KMS keys for encryption
- **Key Features**: Automatic key rotation, multi-region support, key aliases
- **Use In**: RDS, S3, Secrets Manager, CloudWatch Logs encryption

#### `secrets-manager/`
AWS Secrets Manager.
- **Purpose**: Stores and rotates secrets securely
- **Key Features**: KMS encryption, automatic rotation, recovery window, version management
- **Use In**: `composite-modules/database/`, application credentials

#### `ssm-parameter/`
AWS Systems Manager Parameter Store.
- **Purpose**: Stores configuration parameters and secrets
- **Key Features**: String/SecureString/StringList types, Standard/Advanced tiers, KMS encryption
- **Use In**: All composite modules, Jenkins pipelines (heavily used by Aloware)

### Monitoring & Logging

#### `cloudwatch/`
CloudWatch resources.
- **Purpose**: Creates log groups, metric alarms, and dashboards
- **Key Features**: Log retention, KMS encryption, metric alarms with SNS actions, dashboard JSON
- **Use In**: All composite modules for monitoring and alerting

## Usage Patterns

### Direct Usage (Simple Resources)

```hcl
module "app_bucket" {
  source = "git::https://github.com/aloware/aloware-infraestructure-modules.git//resource-modules/s3?ref=v1.0.0"

  bucket_name = "aloware-app-assets-prod"
  versioning_enabled = true
  
  tags = {
    Environment = "production"
    Application = "talk2"
  }
}
```

### Composite Module Usage (Complex Resources)

Resource modules are typically consumed by composite modules:

```hcl
# In composite-modules/networking/main.tf
module "vpc" {
  source = "../../resource-modules/vpc"
  
  name = var.vpc_name
  cidr = var.vpc_cidr
  # ... additional configuration
}

module "database_sg" {
  source = "../../resource-modules/security-group"
  
  name   = "${var.vpc_name}-database-sg"
  vpc_id = module.vpc.vpc_id
  # ... security group rules
}
```

## Module Versioning

All modules support Git-based versioning:

```hcl
# Using a specific version
source = "git::https://github.com/aloware/aloware-infraestructure-modules.git//resource-modules/eks?ref=v1.2.0"

# Using a branch
source = "git::https://github.com/aloware/aloware-infraestructure-modules.git//resource-modules/eks?ref=main"

# Using a commit SHA
source = "git::https://github.com/aloware/aloware-infraestructure-modules.git//resource-modules/eks?ref=abc123"
```

## Terraform Provider Requirements

All modules require:
- **Terraform**: >= 1.8.0
- **AWS Provider**: ~> 5.0

Some modules wrap community modules with their own version constraints. See individual module `versions.tf` files.

## Module Dependencies

### No External Dependencies
- `kms/` - Standalone
- `ssm-parameter/` - Standalone
- `secrets-manager/` - Requires KMS for encryption (optional)

### VPC Dependencies
- `security-group/` - Requires VPC
- `rds/` - Requires VPC and subnets
- `eks/` - Requires VPC and subnets
- `alb/` - Requires VPC and subnets

### DNS Dependencies
- `route53/` - Standalone or requires VPC for private zones
- `acm/` - Requires Route53 for DNS validation (optional)

## Best Practices

### 1. Use Consistent Tagging
All modules support a `tags` variable. Always include:
- `Environment` - development, staging, production
- `Application` - talk2, api-core, etc.
- `ManagedBy` - terraform
- `Project` - aloware

### 2. Enable Encryption
Always enable encryption for:
- S3 buckets (use KMS for sensitive data)
- RDS databases (use KMS)
- Secrets Manager (use KMS)
- CloudWatch Logs (use KMS for compliance)

### 3. Use Remote State
Never commit sensitive outputs. Use Terraform remote state with encryption.

### 4. Version Your Modules
Pin module versions in production:
```hcl
source = "git::https://github.com/aloware/aloware-infraestructure-modules.git//resource-modules/rds?ref=v1.0.0"
```

### 5. Enable Backups
For stateful resources:
- RDS: Enable automated backups and point-in-time recovery
- DynamoDB: Enable point-in-time recovery
- S3: Enable versioning

### 6. Security Groups
- Use minimal required rules
- Reference security groups by ID when possible
- Document each rule's purpose

### 7. SSM Parameter Store
Aloware heavily uses SSM Parameter Store for Jenkins pipelines. Organize parameters:
```
/aloware/development/database/host
/aloware/development/database/password
/aloware/staging/api/secret-key
/aloware/production/redis/endpoint
```

## Testing Modules

### Validate Syntax
```bash
cd resource-modules/vpc
terraform init
terraform validate
```

### Plan Module
```bash
terraform plan -var-file=test.tfvars
```

### Automated Testing
Consider using:
- [Terratest](https://terratest.gruntwork.io/) - Go-based testing
- [terraform-compliance](https://terraform-compliance.com/) - BDD-style tests
- [Checkov](https://www.checkov.io/) - Policy-as-code security scanning

## Contributing

When adding new resource modules:

1. **Follow the standard structure**: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
2. **Use descriptive variable names**: Avoid abbreviations
3. **Add validation**: Use variable validation blocks where appropriate
4. **Document outputs**: Clearly describe what each output provides
5. **Include examples**: Add usage examples in README.md
6. **Tag resources**: Always include the `tags` variable
7. **Test thoroughly**: Test in development environment first
8. **Version conservatively**: Use pessimistic version constraints (`~>`)

## Support Matrix

### AWS Services Covered
| Service | Module | Status |
|---------|--------|--------|
| VPC | `vpc/` | ✅ Complete |
| EKS | `eks/` | ✅ Complete |
| RDS Aurora | `rds/` | ✅ Complete |
| S3 | `s3/` | ✅ Complete |
| ECR | `ecr/` | ✅ Complete |
| DynamoDB | `dynamodb/` | ✅ Complete |
| ALB | `alb/` | ✅ Complete |
| Security Groups | `security-group/` | ✅ Complete |
| IAM | `iam/` | ✅ Complete |
| KMS | `kms/` | ✅ Complete |
| Route53 | `route53/` | ✅ Complete |
| ACM | `acm/` | ✅ Complete |
| Secrets Manager | `secrets-manager/` | ✅ Complete |
| SSM Parameters | `ssm-parameter/` | ✅ Complete |
| CloudWatch | `cloudwatch/` | ✅ Complete |

### Planned Additions
- `elasticache/` - Redis/Memcached caching
- `lambda/` - Serverless functions
- `sqs/` - Message queuing
- `sns/` - Notifications
- `cloudfront/` - CDN distribution (for Talk2 frontend)
- `ecs/` - ECS tasks and services (if needed alongside EKS)

## Related Documentation

- [Composite Modules README](../composite-modules/README.md) - High-level orchestration modules
- [Aloware IAC README](../../aloware-iac/README.md) - Main infrastructure repository
- [Quick Start Guide](../../aloware-iac/QUICK_START.md) - Getting started
- [Implementation Guide](../../aloware-iac/IMPLEMENTATION_GUIDE.md) - Deployment roadmap

## Questions?

For questions or issues:
1. Check individual module README files
2. Review the [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
3. Consult the [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
4. Review wrapped module documentation (linked in each module's README)
