#!/bin/bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${script_dir}/lib.sh"

# Set CONTINUE_ON_FAILURE=1 to keep looping after a failed cycle.
continue_on_failure=${CONTINUE_ON_FAILURE:-0}
count=1
failures=0

while true; do
  banner "Beginning test ${count} build"

  status=0
  "${script_dir}/cycle.sh" || status=$?

  if [ "$status" -ne 0 ]; then
    failures=$((failures + 1))
    echo "ERROR: test ${count} failed with exit ${status} (${failures} failure(s) so far)" >&2
    if [ "$continue_on_failure" != "1" ]; then
      exit "$status"
    fi
  fi

  banner "Ending test ${count} build"
  count=$((count + 1))
done
