#!/bin/bash
# Deploys IAM user roles for AWS SSO stack.
# This only needs to be done once by master admin.
# Developers would not need to run this.

set -e
set -u

export REPO_ROOT=$(git rev-parse --show-toplevel)
export SSO_STACK_NAME="sso"

source "${REPO_ROOT}"/bin/_utils.sh

create() {
    aws cloudformation create-stack --stack-name "${SSO_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/sso/managed-policies.yml \
        --capabilities CAPABILITY_NAMED_IAM
}

update() {
    aws cloudformation update-stack --stack-name "${SSO_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/sso/managed-policies.yml \
        --capabilities CAPABILITY_NAMED_IAM
}

delete() {
    aws cloudformation delete-stack --stack-name "${SSO_STACK_NAME}"
}

usage() {
    cat <<EOF
Manages the SSO stack on the MASTER ACCOUNT.
Only the admin can change this.

Usage: ./bin/sso-stack.sh <arg>
Where arg is:
create
delete
update
EOF
}

main() {
    args="$@"
    check_environment

    if [[ "${AWS_PROFILE}" != "master-admin" ]]; then
        echo "Got AWS_PROFILE: ${AWS_PROFILE}"
        echo "This must be run in the master account! (master-admin)"
        echo "Exiting."
        exit 1
    fi

    if [[ "${args}" == "create" ]]; then
        create
    elif [[ "${args}" == "delete" ]]; then
        delete
    elif [[ "${args}" == "update" ]]; then
        update
    else
        echo "No command run :("
        usage
    fi

}

main "$@"
