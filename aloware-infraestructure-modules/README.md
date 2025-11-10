# Aloware Infrastructure Modules

This repository contains reusable Terraform modules for Aloware infrastructure.

## Structure

- **composite-modules/**: High-level modules that combine multiple resource modules
- **resource-modules/**: Low-level, atomic Terraform modules

## Module Categories

### Composite Modules

1. **networking**: Complete VPC setup with subnets, NAT gateways, security groups
2. **eks-cluster**: EKS cluster with node groups, IAM roles, and add-ons
3. **database**: RDS Aurora clusters with proper configuration
4. **storage**: S3 buckets and ECR repositories
5. **application**: Application deployment resources (Helm, K8s resources)
6. **monitoring**: CloudWatch, alarms, dashboards

### Resource Modules

1. **vpc**: VPC creation and configuration
2. **eks**: EKS cluster resources
3. **rds**: RDS database resources
4. **s3**: S3 bucket management
5. **ecr**: ECR repository management
6. **iam**: IAM roles and policies
7. **kms**: KMS key management

## Usage

Modules are referenced in the `aloware-iac` repository via Terragrunt:

```hcl
terraform {
  source = "git::https://github.com/aloware/aloware-infraestructure-modules.git//composite-modules/networking?ref=v1.0.0"
}
```

## Development

1. Create feature branch from `develop`
2. Make changes to modules
3. Test in development environment via `aloware-iac`
4. Create PR for review
5. After merge to `develop`, test in staging
6. Tag release and merge to `main` for production use

## Module Standards

Each module should have:
- `README.md`: Documentation and usage examples
- `main.tf`: Main resource definitions
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `versions.tf`: Terraform and provider version constraints
- `examples/`: Example usage

## Versioning

- Use semantic versioning (v1.0.0, v1.1.0, etc.)
- `develop` branch: Latest development code
- `main` branch: Stable, production-ready code
- Tags: Specific versions for production use
