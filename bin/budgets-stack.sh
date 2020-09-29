#!/bin/bash

set -e
set -u

export BUDGETS_STACK_NAME="budgets"
source "${REPO_ROOT}"/bin/_utils.sh

# Budgets stack is in Sydney
export AWS_REGION="ap-southeast-2"

get_parameters() {
    parameters=$(cat "${REPO_ROOT}"/infra/budgets/budgets-parameters.json |
                     sed "s/{{ NOTIFICATION_EMAIL_1 }}/${DEVELOPER_EMAIL}/g" |
                     jq)
    echo "${parameters}"
}

create() {
    local parameters
    parameters=$(get_parameters)
    echo "${parameters}"
    aws cloudformation create-stack --stack-name "${BUDGETS_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/budgets/budgets-stack.yml \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters "${parameters}" \
        --enable-termination-protection
}

update() {
    local parameters
    parameters=$(get_parameters)
    echo "${parameters}"
    aws cloudformation update-stack --stack-name "${BUDGETS_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/budgets/budgets-stack.yml \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters "${parameters}"
}

delete() {
    local parameters
    parameters=$(get_parameters)
    echo "${parameters}"
    aws cloudformation delete-stack --stack-name "${BUDGETS_STACK_NAME}"
}

usage() {
    cat <<EOF
Applies budget stack.

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
