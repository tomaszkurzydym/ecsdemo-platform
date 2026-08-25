#!/bin/bash
#
# Shared helpers and configuration for the ecsdemo test scripts.
# Source this file instead of duplicating banners, paths and AWS lookups:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/environment}"
PLATFORM_REPO="ecsdemo-platform"
MU_ENVIRONMENTS=(acceptance production)
MU_SERVICES=(ecsdemo-frontend ecsdemo-nodejs ecsdemo-crystal)

# Prints a banner with the current timestamp.
log_step() {
  echo "================================"
  echo "$* at $(date)"
}

# Changes into one of the ecsdemo repositories in the workspace.
enter_repo() {
  cd "${WORKSPACE_DIR}/$1" || exit 1
}

# Services in the reverse order of MU_SERVICES, for teardown.
mu_services_reversed() {
  local i
  for ((i = ${#MU_SERVICES[@]} - 1; i >= 0; i--)); do
    echo "${MU_SERVICES[$i]}"
  done
}

# Region of the instance this script runs on, derived from its availability zone.
aws_region() {
  curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone |
    sed 's/\(.*\)[a-z]/\1/'
}

aws_account_id() {
  aws sts get-caller-identity --query Account --output text
}

delete_stack() {
  aws cloudformation delete-stack --stack-name "$1"
}

delete_ecr_repository() {
  aws ecr delete-repository --repository-name "$1" --force || true
}

empty_bucket() {
  aws s3 rm --recursive "s3://$1"
}
