#!/bin/bash

#   askYN.sh  -  Ask the user a yes/no question on stdout/stdin.
#
#   Usage:  askYN.sh [ "Question?" ]
#
#   Exits with code 0 for yes, 1 for no.
#
#   E.B. Smith  -  October 2013

set -eu
set -o pipefail

question="${1:-""}"

read -n 1 -r -p "${question} [y/N] "
echo ""
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    exit 0
else
    exit 1
fi
