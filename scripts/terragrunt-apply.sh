#!/bin/bash
set -e

# Terragrunt Apply Wrapper
# Runs terragrunt apply with safety checks

ENVIRONMENT=$1
MODULE=$2

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment> [module]"
  echo "Example: $0 development"
  echo "Example: $0 development eks-cluster"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="${REPO_ROOT}/environments/${ENVIRONMENT}"

if [ ! -d "$ENV_DIR" ]; then
  echo "Error: Environment directory not found: $ENV_DIR"
  echo "Valid environments: development, staging, production"
  exit 1
fi

# Extra confirmation for production
if [ "$ENVIRONMENT" = "production" ]; then
  echo "========================================="
  echo "WARNING: PRODUCTION ENVIRONMENT"
  echo "========================================="
  echo "You are about to apply changes to PRODUCTION!"
  echo ""
  read -p "Type 'APPLY PRODUCTION' to continue: " confirm
  if [ "$confirm" != "APPLY PRODUCTION" ]; then
    echo "Aborting."
    exit 1
  fi
fi

echo "========================================="
echo "Terragrunt Apply"
echo "========================================="
echo "Environment: $ENVIRONMENT"
echo "Directory: $ENV_DIR"
[ -n "$MODULE" ] && echo "Module: $MODULE"
echo "========================================="
echo ""

cd "$ENV_DIR"

if [ -n "$MODULE" ]; then
  # Apply specific module
  MODULE_REGION=$(find . -type d -name "$MODULE" | head -n 1 | xargs dirname)
  if [ -z "$MODULE_REGION" ]; then
    echo "Error: Module not found: $MODULE"
    exit 1
  fi
  
  echo "Applying module: ${MODULE_REGION}/${MODULE}"
  cd "${MODULE_REGION}/${MODULE}"
  
  # Check if plan file exists
  if [ -f "tfplan" ]; then
    terragrunt apply tfplan
  else
    echo "No plan file found. Running plan first..."
    terragrunt plan -out=tfplan
    echo ""
    read -p "Apply this plan? (yes/no): " apply_confirm
    if [ "$apply_confirm" = "yes" ]; then
      terragrunt apply tfplan
    else
      echo "Apply cancelled."
      exit 0
    fi
  fi
else
  # Apply all modules
  echo "Applying all modules..."
  terragrunt run-all apply
fi

echo ""
echo "========================================="
echo "Apply completed!"
echo "========================================="
