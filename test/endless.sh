#!/bin/bash

set -uo pipefail

cd "$(dirname "$0")" || exit 1

count=1

while true; do
  echo "================================"
  echo "Beginning test ${count} build at $(date)"
  ./cycle.sh
  echo "Ending test ${count} build at $(date)"
  echo "================================"
  ((count++))
done
