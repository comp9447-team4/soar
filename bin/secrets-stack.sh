#!/bin/bash

set -e
set -u

export SECRETS_STACK_NAME="Secrets"
export SECRETS_STACK_YML=file://"${REPO_ROOT}"/infra/secrets/secrets.yml
export AWS_PAGER=""
source "${REPO_ROOT}"/bin/_utils.sh

create() {
    aws cloudformation create-stack --stack-name "${SECRETS_STACK_NAME}" \
        --template-body "${SECRETS_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    aws cloudformation wait stack-create-complete --stack-name "${SECRETS_STACK_NAME}"
}

update() {
    aws cloudformation update-stack --stack-name "${SECRETS_STACK_NAME}" \
        --template-body "${SECRETS_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM
    aws cloudformation wait stack-update-complete --stack-name "${SECRETS_STACK_NAME}"
}

delete() {
    aws cloudformation \
        update-termination-protection \
        --stack-name "${SECRETS_STACK_NAME}" \
        --no-enable-termination-protection

    aws cloudformation \
        delete-stack \
        --stack-name "${SECRETS_STACK_NAME}"
    aws cloudformation wait stack-delete-complete --stack-name "${SECRETS_STACK_NAME}"
}

usage() {
    cat <<EOF
Applies secrets stack.

Usage: ./bin/budget-stack.sh <arg>
Where arg is:
create
delete
update
EOF
}

main() {
    args="$@"
    check_environment

    if [[ "${args}" == "create" ]]; then
        create
    elif [[ "${args}" == "delete" ]]; then
        delete
    elif [[ "${args}" == "update" ]]; then
        update
    elif [[ "${args}" == "describe" ]]; then
        describe_stack
    else
        echo "No command run :("
        usage
    fi

}

main "$@"
