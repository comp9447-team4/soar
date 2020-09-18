#!/bin/bash
# Deploys IAM user roles
# This only needs to be done once per environment!

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)
export USER_ROLES_STACK_NAME="user-roles"
export USERS_STACK_NAME="users"

create_user_role_stack() {
    echo "Creating..."
    aws cloudformation create-stack --stack-name "${USER_ROLES_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/users/roles.yml \
        --parameters file://"${REPO_ROOT}"/users/users-parameters.json \
        --capabilities CAPABILITY_NAMED_IAM
}

create_users_stack() {
    echo "Creating..."
    aws cloudformation create-stack --stack-name "${USERS_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/users/users.yml \
        --capabilities CAPABILITY_NAMED_IAM
}

delete_users_stack() {
    echo "Deleting..."
    aws cloudformation delete-stack --stack-name "${USERS_STACK_NAME}"
}

delete_user_role_stack() {
    echo "Deleting..."
    aws cloudformation delete-stack --stack-name "${USER_ROLES_STACK_NAME}"
}

main() {
    echo "Deploying on ${AWS_PROFILE}..."
    args="$@"

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
