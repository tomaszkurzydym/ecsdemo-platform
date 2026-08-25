#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_env GITHUB_TOKEN
require_dir "$ENVIRONMENT_DIR"

banner "Beginning acceptance platform build"
cd "${ENVIRONMENT_DIR}/ecsdemo-platform"
mu env up acceptance

banner "Beginning production platform build"
mu env up production

for app in frontend nodejs crystal; do
  banner "Beginning ${app} pipeline build"
  cd "${ENVIRONMENT_DIR}/ecsdemo-${app}"
  mu pipeline up -t "$GITHUB_TOKEN"
done

banner "Build complete"
