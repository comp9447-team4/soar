#!/bin/bash
# Deploys IAM user roles
# This only needs to be done once per environment!

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)

export USER_ROLES_STACK_NAME="user-roles"
export USERS_STACK_NAME="users"

source "${REPO_ROOT}"/_utils.sh

create_user_role_stack() {
    echo "Creating role stack..."
    local parameters
    parameters=$("${REPO_ROOT}"/users/users-parameters.json |
                sed "s/{{ AWS_PROFILE}}/${AWS_PROFILE}/g" |
                jq)

    aws cloudformation create-stack --stack-name "${USER_ROLES_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/users/roles.yml \
        --parameters "${parameters}" \
        --capabilities CAPABILITY_NAMED_IAM
}

create_users_stack() {
    echo "Creating users stack..."
    aws cloudformation create-stack --stack-name "${USERS_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/users/users.yml \
        --capabilities CAPABILITY_NAMED_IAM
}

delete_users_stack() {
    echo "Deleting users stack..."
    aws cloudformation delete-stack --stack-name "${USERS_STACK_NAME}"
}

delete_user_role_stack() {
    echo "Deleting roles stack..."
    aws cloudformation delete-stack --stack-name "${USER_ROLES_STACK_NAME}"
}

main() {
    args="$@"
    check_environment

    if [ "${args}" == "delete-user-role-stack" ]; then
        delete_user_role_stack
    elif [ "${args}" == "create-user-role-stack" ]; then
        create_user_role_stack
    elif [ "${args}" == "create-users-stack" ]; then
        create_users_stack
    elif [ "${args}" == "delete-users-stack" ]; then
        delete_users_stack
    fi

}

main "$@"
