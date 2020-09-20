#!/bin/bash
# Various utilities

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)

check_environment() {
    if [ "${AWS_PROFILE}" == "qa" ]; then
        echo "In environment: QA"
    elif [ "${AWS_PROFILE}" == "prod" ]; then
        echo "In environment: prod"
    elif [ "${AWS_PROFILE}" == "master-admin" ]; then
        echo "In environment: master-admin"
    else
        echo "Unknown AWS_PROFILE. Must be 'qa' or 'prod'. Did you setup your aws cli properly? See README."
        echo "Exiting..."
        exit 1
    fi
}
