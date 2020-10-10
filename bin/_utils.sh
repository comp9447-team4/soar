#!/bin/bash
# Various utilities

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)
export AWS_PAGER=""

check_environment() {
    echo "Checking if you have set AWS_PROFILE..."
    echo "If this step fails, make sure you have setup your AWS CLI properly. See README."
    if [ "${AWS_PROFILE}" == "qa" ]; then
        echo "In environment: QA"
    elif [ "${AWS_PROFILE}" == "prod" ]; then
        echo "In environment: prod"
    elif [ "${AWS_PROFILE}" == "master-admin" ]; then
        echo "In environment: master-admin"
    elif [ "${AWS_PROFILE}" == "prod-admin" ]; then
        echo "In environment: prod-admin"
    else
        echo "Unknown AWS_PROFILE. Must be 'qa' or 'prod'. Did you setup your aws cli properly? See README."
        echo "Exiting..."
        exit 1
    fi
}

wait_build() {
    stack_name="$1"
    echo "Waiting create for ${stack_name}..."
    aws cloudformation wait stack-exists --stack-name "${stack_name}" > /dev/null
    aws cloudformation wait stack-create-complete --stack-name "${stack_name}" > /dev/null
}

wait_update() {
    stack_name="$1"
    echo "Waiting update for ${stack_name}..."
    aws cloudformation wait stack-exists --stack-name "${stack_name}" > /dev/null
    aws cloudformation wait stack-update-complete --stack-name "${stack_name}" > /dev/null
}

get_cfn_export() {
    local export_names=$(aws cloudformation list-exports | jq -r '.Exports' )
    local val=$(echo "${export_names}" |
                       jq -c "map(select(.Name==\"$1\")| .Value)" |
                       jq -r '.[0]' |
                       sed 's/\//\\\//g')
    echo "$val"
}
