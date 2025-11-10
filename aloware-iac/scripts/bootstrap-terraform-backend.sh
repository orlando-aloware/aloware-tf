#!/bin/bash
set -e

# Bootstrap Terraform Backend for Aloware Infrastructure
# This script creates the S3 bucket and DynamoDB table for Terraform state management

ENVIRONMENT=$1
REGION=${2:-us-west-2}

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment> [region]"
  echo "Example: $0 development us-west-2"
  exit 1
fi

# Load environment configuration
case $ENVIRONMENT in
  development)
    AWS_ACCOUNT_ID="333629833033"
    AWS_PROFILE="aloware-dev"
    ;;
  staging)
    AWS_ACCOUNT_ID="225989345843"
    AWS_PROFILE="aloware-staging"
    ;;
  production)
    AWS_ACCOUNT_ID="PRODUCTION_ACCOUNT_ID"
    AWS_PROFILE="aloware-production"
    echo "WARNING: You are about to bootstrap PRODUCTION environment!"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
      echo "Aborting."
      exit 1
    fi
    ;;
  *)
    echo "Invalid environment: $ENVIRONMENT"
    echo "Valid environments: development, staging, production"
    exit 1
    ;;
esac

S3_BUCKET="aloware-${ENVIRONMENT}-${AWS_ACCOUNT_ID}-${REGION}-terraform-state"
DYNAMODB_TABLE="aloware-${ENVIRONMENT}-terraform-state-lock"

echo "========================================="
echo "Bootstrapping Terraform Backend"
echo "========================================="
echo "Environment: $ENVIRONMENT"
echo "AWS Account: $AWS_ACCOUNT_ID"
echo "Region: $REGION"
echo "S3 Bucket: $S3_BUCKET"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo "========================================="

# Create S3 bucket for Terraform state
echo "Creating S3 bucket..."
aws s3 mb "s3://${S3_BUCKET}" \
  --region "${REGION}" \
  --profile "${AWS_PROFILE}" || echo "Bucket may already exist"

# Enable versioning
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "${S3_BUCKET}" \
  --versioning-configuration Status=Enabled \
  --profile "${AWS_PROFILE}"

# Enable encryption
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket "${S3_BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      },
      "BucketKeyEnabled": true
    }]
  }' \
  --profile "${AWS_PROFILE}"

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "${S3_BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  --profile "${AWS_PROFILE}"

# Enable lifecycle policy to delete old versions
echo "Setting lifecycle policy..."
aws s3api put-bucket-lifecycle-configuration \
  --bucket "${S3_BUCKET}" \
  --lifecycle-configuration '{
    "Rules": [{
      "Id": "DeleteOldVersions",
      "Status": "Enabled",
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 90
      }
    }]
  }' \
  --profile "${AWS_PROFILE}"

# Add bucket tags
echo "Adding bucket tags..."
aws s3api put-bucket-tagging \
  --bucket "${S3_BUCKET}" \
  --tagging "TagSet=[
    {Key=Name,Value=${S3_BUCKET}},
    {Key=Environment,Value=${ENVIRONMENT}},
    {Key=ManagedBy,Value=Terragrunt},
    {Key=Purpose,Value=TerraformState}
  ]" \
  --profile "${AWS_PROFILE}"

# Create DynamoDB table for state locking
echo "Creating DynamoDB table..."
aws dynamodb create-table \
  --table-name "${DYNAMODB_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}" \
  --profile "${AWS_PROFILE}" \
  --tags "Key=Name,Value=${DYNAMODB_TABLE}" \
         "Key=Environment,Value=${ENVIRONMENT}" \
         "Key=ManagedBy,Value=Terragrunt" \
         "Key=Purpose,Value=TerraformStateLock" \
  2>/dev/null || echo "DynamoDB table may already exist"

# Enable point-in-time recovery for production
if [ "$ENVIRONMENT" = "production" ]; then
  echo "Enabling point-in-time recovery for DynamoDB..."
  aws dynamodb update-continuous-backups \
    --table-name "${DYNAMODB_TABLE}" \
    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true \
    --region "${REGION}" \
    --profile "${AWS_PROFILE}"
fi

echo "========================================="
echo "Bootstrap completed successfully!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Navigate to the environment directory:"
echo "   cd environments/${ENVIRONMENT}"
echo ""
echo "2. Initialize Terragrunt:"
echo "   terragrunt run-all init"
echo ""
echo "3. Plan your infrastructure:"
echo "   terragrunt run-all plan"
echo ""
echo "4. Apply when ready:"
echo "   terragrunt run-all apply"
echo "========================================="
