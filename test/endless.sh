#!/bin/bash

TEST_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${TEST_DIR}/common.sh"

count=1

while true; do
  log_step "Beginning test ${count} build"
  "${TEST_DIR}/cycle.sh"
  log_step "Ending test ${count} build"
  ((count++))
done
