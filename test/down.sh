#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

while read -r service; do
  log_step "Beginning ${service} pipeline term"
  enter_repo "${service}"
  mu pipeline term
done < <(mu_services_reversed)

enter_repo "${PLATFORM_REPO}"
for environment in "${MU_ENVIRONMENTS[@]}"; do
  log_step "Beginning ${environment} platform term"
  mu env term "${environment}"
done

log_step "Beginning ecr repo delete"
for service in "${MU_SERVICES[@]}"; do
  delete_ecr_repository "${MU_NAMESPACE}-${service}"
done

log_step "Beginning s3 bucket delete"
REGION=$(aws_region)
ACCOUNT_ID=$(aws_account_id)
export REGION ACCOUNT_ID
for bucket in codedeploy codepipeline; do
  empty_bucket "${MU_NAMESPACE}-${bucket}-${REGION}-${ACCOUNT_ID}"
done

log_step "Beginning cf stack delete"
for service in "${MU_SERVICES[@]}"; do
  for environment in "${MU_ENVIRONMENTS[@]}"; do
    delete_stack "${MU_NAMESPACE}-iam-service-${service}-${environment}"
  done
done

for service in "${MU_SERVICES[@]}"; do
  delete_stack "${MU_NAMESPACE}-repo-${service}"
done

for bucket in codedeploy codepipeline; do
  delete_stack "${MU_NAMESPACE}-bucket-${bucket}"
done

# delay waiting for all the other CF stacks to be deleted -- replace with a count of stacks or something
log_step "Beginning sleep 300"
sleep 300

log_step "Beginning iam-common stack delete"
delete_stack "${MU_NAMESPACE}-iam-common"
log_step "Teardown complete"
