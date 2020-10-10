#!/bin/bash

set -e
set -o pipefail
set -u

source "${REPO_ROOT}"/bin/_utils.sh

# The CICD pipelines
export AWS_REGION="us-east-1"
export CICD_STACK_NAME="${AWS_PROFILE}-SoarCicd"
export CICD_STACK_YML="${REPO_ROOT}/infra/soar/cicd.yml"

create_cicd() {
    echo "Creating CICD stack..."
    aws cloudformation create-stack \
        --stack-name "${CICD_STACK_NAME}" \
        --template-body file://"${CICD_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsProfile,ParameterValue="${AWS_PROFILE}" \
        --enable-termination-protection
    wait_build "${CICD_STACK_NAME}"
}

update_cicd() {
    echo "Creating CICD stack..."
    aws cloudformation update-stack \
        --stack-name "${CICD_STACK_NAME}" \
        --template-body file://"${CICD_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsProfile,ParameterValue="${AWS_PROFILE}"
    wait_update "${CICD_STACK_NAME}"
}

# Store Secrets in this stack
export SECRETS_STACK_NAME="${AWS_PROFILE}-SoarSecrets"
export SECRETS_STACK_YML="${REPO_ROOT}/infra/soar/secrets.yml"

create_secrets() {
    echo "Creating secrets stack..."
    aws cloudformation create-stack \
        --stack-name "${SECRETS_STACK_NAME}" \
        --template-body file://"${SECRETS_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    wait_build "${SECRETS_STACK_NAME}"
}

usage() {
    cat <<EOF
Manages CFN stacks for the SOAR solution
Reference: https://github.com/aws-samples/aws-modern-application-workshop/tree/python

Usage: AWS_PROFILE=qa ./bin/soar.sh <arg>
Where arg is:
create-cicd
update-cicd
create-secrets
EOF
}
main() {
    args="$1"
    if [[ "${AWS_PROFILE}" == "prod" ]]; then
        echo "In environment: ${AWS_PROFILE}"
    elif [[ "${AWS_PROFILE}" == "qa" ]]; then
        echo "In environment: ${AWS_PROFILE}"
    else
        echo "Unknown AWS_PROFILE ${AWS_PROFILE}"
        echo "Unknown AWS_PROFILE. Must be 'qa' or 'prod'. Did you setup your aws cli properly? See README."
        echo "Must be prod or qa"
        usage
        exit 1
    fi

    if [[ "${args}" == "create-cicd" ]]; then
        create_cicd
    elif [[ "${args}" == "create-secrets" ]]; then
        create_secrets
    elif [[ "${args}" == "update-cicd" ]]; then
        update_cicd
    else
        echo "Not a valid argument..."
        usage
    fi
}

main "$@"
