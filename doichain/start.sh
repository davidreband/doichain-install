#!/bin/bash
set -euo pipefail

scripts/doichain-start.sh 
tail -f /dev/null