#!/bin/bash

set -euo pipefail

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN is not set; export it before running this script." >&2
  exit 1
fi

echo "================================"
echo "Beginning acceptance platform build at $(date)"
cd ~/environment/ecsdemo-platform
mu env up acceptance
echo "================================"
echo "Beginning production platform build at $(date)"
mu env up production

echo "================================"
echo "Beginning frontend pipeline build at $(date)"
cd ~/environment/ecsdemo-frontend
mu pipeline up -t "$GITHUB_TOKEN"

echo "================================"
echo "Beginning nodejs pipeline build at $(date)"
cd ~/environment/ecsdemo-nodejs
mu pipeline up -t "$GITHUB_TOKEN"

echo "================================"
echo "Beginning crystal pipeline build at $(date)"
cd ~/environment/ecsdemo-crystal
mu pipeline up -t "$GITHUB_TOKEN"
