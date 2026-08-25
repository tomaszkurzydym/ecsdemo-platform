#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

./up.sh
./down.sh
