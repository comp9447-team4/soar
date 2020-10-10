#!/bin/bash

set -e
set -o pipefail
set -u

source "${REPO_ROOT}"/bin/_utils.sh

export CICD_STACK_NAME="SoarCicd"
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

export SECRETS_STACK_NAME="SoarSecrets"
export SECRETS_STACK_YML="${REPO_ROOT}/infra/soar/secrets.yml"
create_secrets() {
    echo "Creating secrets stack..."
    aws cloudformation create-stack \
        --stack-name "${SECRETS_STACK_NAME}" \
        --template-body file://"${SECRETS_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsProfile,ParameterValue="${AWS_PROFILE}" \
        --enable-termination-protection
    wait_build "${SECRETS_STACK_NAME}"
}

main() {

    args="$1"

    if [[ "${args}" == "create-cicd" ]]; then
        create_cicd
    elif [[ "${args}" == "create-secrets" ]]; then
        create_secrets
    fi


}

main
