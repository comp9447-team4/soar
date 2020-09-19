#!/bin/bash
# Deploys IAM user roles for AWS SSO stack
# This only needs to be done once

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)
export MANAGED_POLICIES_STACK_NAME="sso-roles"

source "${REPO_ROOT}"/bin/_utils.sh

create_managed_policies() {
    aws cloudformation create-stack --stack-name "${MANAGED_POLICIES_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/sso/managed-policies.yml \
        --capabilities CAPABILITY_NAMED_IAM
}

update_managed_policies() {
    aws cloudformation update-stack --stack-name "${MANAGED_POLICIES_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/sso/managed-policies.yml \
        --capabilities CAPABILITY_NAMED_IAM
}

delete_managed_policies() {
    aws cloudformation delete-stack --stack-name "${MANAGED_POLICIES_STACK_NAME}"
}

main() {
    args="$@"
    check_environment

    if [[ "${AWS_PROFILE}" != "master-admin" ]]; then
        echo "This must be run in the master account!"
        echo "Exiting."
        exit 1
    fi

    if [[ "${args}" == "create-managed-policies" ]]; then
        create_managed_policies
    elif [[ "${args}" == "delete-managed-policies" ]]; then
        delete_managed_policies
    elif [[ "${args}" == "update-managed-policies" ]]; then
        update_managed_policies
    else
        echo "No command run :("
    fi

}

main "$@"
