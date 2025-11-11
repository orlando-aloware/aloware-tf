#!/bin/bash
set -e

# Terragrunt Plan Wrapper
# Runs terragrunt plan with optional module filtering

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

echo "========================================="
echo "Terragrunt Plan"
echo "========================================="
echo "Environment: $ENVIRONMENT"
echo "Directory: $ENV_DIR"
[ -n "$MODULE" ] && echo "Module: $MODULE"
echo "========================================="
echo ""

cd "$ENV_DIR"

if [ -n "$MODULE" ]; then
  # Plan specific module
  MODULE_REGION=$(find . -type d -name "$MODULE" | head -n 1 | xargs dirname)
  if [ -z "$MODULE_REGION" ]; then
    echo "Error: Module not found: $MODULE"
    exit 1
  fi
  
  echo "Planning module: ${MODULE_REGION}/${MODULE}"
  cd "${MODULE_REGION}/${MODULE}"
  terragrunt plan -out=tfplan
else
  # Plan all modules
  echo "Planning all modules..."
  terragrunt run-all plan
fi

echo ""
echo "========================================="
echo "Plan completed!"
echo "========================================="
