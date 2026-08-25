#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

enter_repo "${PLATFORM_REPO}"
for environment in "${MU_ENVIRONMENTS[@]}"; do
  log_step "Beginning ${environment} platform build"
  mu env up "${environment}"
done

for service in "${MU_SERVICES[@]}"; do
  log_step "Beginning ${service} pipeline build"
  enter_repo "${service}"
  mu pipeline up -t "${GITHUB_TOKEN}"
done
