#!/bin/bash
set -e

# Cleanup Terragrunt cache files recursively
# This script removes all .terragrunt-cache directories and .terraform.lock.hcl files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Cleaning Terragrunt Cache"
echo "========================================="
echo "Working directory: $REPO_ROOT"
echo ""

# Remove .terragrunt-cache directories
echo "Removing .terragrunt-cache directories..."
find "$REPO_ROOT" -type d -name ".terragrunt-cache" -print -exec rm -rf {} + 2>/dev/null || true

# Remove .terraform.lock.hcl files
echo "Removing .terraform.lock.hcl files..."
find "$REPO_ROOT" -type f -name ".terraform.lock.hcl" -print -exec rm -f {} + 2>/dev/null || true

# Remove .terraform directories (if any)
echo "Removing .terraform directories..."
find "$REPO_ROOT" -type d -name ".terraform" -print -exec rm -rf {} + 2>/dev/null || true

echo ""
echo "========================================="
echo "Cache cleanup completed!"
echo "========================================="
