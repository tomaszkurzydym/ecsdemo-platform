#!/bin/bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${script_dir}/lib.sh"

# Always tear down, even when the build fails, but report the first failure.
up_status=0
"${script_dir}/up.sh" || up_status=$?
if [ "$up_status" -ne 0 ]; then
  echo "ERROR: up.sh failed with exit ${up_status}" >&2
fi

down_status=0
"${script_dir}/down.sh" || down_status=$?
if [ "$down_status" -ne 0 ]; then
  echo "ERROR: down.sh failed with exit ${down_status}" >&2
fi

if [ "$up_status" -ne 0 ]; then
  exit "$up_status"
fi
exit "$down_status"
