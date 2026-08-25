#!/bin/bash
# Shared helpers for the test harness scripts. Source this file instead of
# repeating error handling in every script.

set -Eeuo pipefail

on_error() {
  local exit_code=$1 line=$2 command=$3 source_file=${4:-${BASH_SOURCE[0]}}
  echo "ERROR: ${source_file}:${line}: exited ${exit_code} while running: ${command}" >&2
  exit "$exit_code"
}

trap 'on_error "$?" "$LINENO" "$BASH_COMMAND" "${BASH_SOURCE[0]}"' ERR

# Directory holding the ecsdemo-* checkouts.
ENVIRONMENT_DIR=${ENVIRONMENT_DIR:-$HOME/environment}

banner() {
  echo "================================"
  echo "$* at $(date)"
}

require_env() {
  local name status=0
  for name in "$@"; do
    if [ -z "${!name:-}" ]; then
      echo "ERROR: required environment variable ${name} is not set" >&2
      status=1
    fi
  done
  return "$status"
}

require_dir() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    echo "ERROR: expected directory ${dir} does not exist" >&2
    return 1
  fi
}

# Run a command, tolerating only "resource is already gone" failures. Any other
# failure is reported with the command output and propagated to the caller.
ignore_missing() {
  local output status=0
  output=$("$@" 2>&1) || status=$?

  if [ "$status" -eq 0 ]; then
    if [ -n "$output" ]; then
      printf '%s\n' "$output"
    fi
    return 0
  fi

  if printf '%s' "$output" | grep -qiE 'NotFound|does not exist|no such'; then
    echo "WARN: skipping absent resource: $* (${output})" >&2
    return 0
  fi

  echo "ERROR: command failed (exit ${status}): $*" >&2
  printf '%s\n' "$output" >&2
  return "$status"
}

# Region of the current instance, preferring the standard AWS environment
# variables and falling back to the instance metadata service.
current_region() {
  if [ -n "${AWS_REGION:-}" ]; then
    printf '%s\n' "$AWS_REGION"
    return 0
  fi
  if [ -n "${AWS_DEFAULT_REGION:-}" ]; then
    printf '%s\n' "$AWS_DEFAULT_REGION"
    return 0
  fi

  local token az region
  token=$(curl -fsS -m 5 -X PUT http://169.254.169.254/latest/api/token \
    -H 'X-aws-ec2-metadata-token-ttl-seconds: 60' 2>/dev/null) || token=""

  if [ -n "$token" ]; then
    az=$(curl -fsS -m 5 -H "X-aws-ec2-metadata-token: ${token}" \
      http://169.254.169.254/latest/meta-data/placement/availability-zone) || az=""
  else
    az=$(curl -fsS -m 5 http://169.254.169.254/latest/meta-data/placement/availability-zone) || az=""
  fi

  region=$(printf '%s' "$az" | sed 's/[a-z]$//')
  if [ -z "$region" ]; then
    echo "ERROR: unable to determine the AWS region; set AWS_REGION" >&2
    return 1
  fi
  printf '%s\n' "$region"
}
