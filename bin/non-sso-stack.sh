#!/bin/bash
# Deploys IAM user roles
# This only needs to be done once per environment!
# This is legacy (non sso) to be deprecated once we have AWS SSO

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)

export USER_ROLES_STACK_NAME="user-roles"
export USERS_STACK_NAME="users"

source "${REPO_ROOT}"/bin/_utils.sh

create_user_role_stack() {
    echo "Creating role stack..."
    local parameters
    parameters=$(cat "${REPO_ROOT}"/infra/users/users-parameters.json |
                sed "s/{{ AWS_PROFILE }}/${AWS_PROFILE}/g" |
                jq)

    echo "${parameters}"

    aws cloudformation create-stack --stack-name "${USER_ROLES_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/users/roles.yml \
        --parameters "${parameters}" \
        --capabilities CAPABILITY_NAMED_IAM
}

create_users_stack() {
    echo "Creating users stack..."
    aws cloudformation create-stack --stack-name "${USERS_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/users/users.yml \
        --parameters ParameterKey=BaselineExportName,ParameterValue="${AWS_PROFILE}" \
        --capabilities CAPABILITY_NAMED_IAM
}

update_users_stack() {
    aws cloudformation update-stack --stack-name "${USERS_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/users/users.yml \
        --parameters ParameterKey=BaselineExportName,ParameterValue="${AWS_PROFILE}" \
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
    elif [ "${args}" == "update-users-stack" ]; then
        update_users_stack
    elif [ "${args}" == "delete-users-stack" ]; then
        delete_users_stack
    fi

}

main "$@"
