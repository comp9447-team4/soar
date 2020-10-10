#!/bin/bash
# Deploys IAM user roles for AWS SSO stack.
# This only needs to be done once by master admin.
# Developers would not need to run this.

set -e
set -u

export REPO_ROOT=$(git rev-parse --show-toplevel)
export SSO_STACK_NAME="sso"
source "${REPO_ROOT}"/bin/_utils.sh

# SSO region is in Sydney
export AWS_REGION="ap-southeast-2"

get_parameters() {
    parameters=$(cat "${REPO_ROOT}"/infra/sso/sso-parameters.json |
                     sed "s/{{ MASTER_ACCOUNT_ID }}/${MASTER_ACCOUNT_ID}/g" |
                     sed "s/{{ QA_ACCOUNT_ID }}/${QA_ACCOUNT_ID}/g" |
                     sed "s/{{ PROD_ACCOUNT_ID }}/${PROD_ACCOUNT_ID}/g" |
                     sed "s/{{ SSO_ADMINISTRATORS_GROUP_ID }}/${SSO_ADMINISTRATORS_GROUP_ID}/g" |
                     sed "s/{{ SSO_DEVELOPERS_GROUP_ID }}/${SSO_DEVELOPERS_GROUP_ID}/g" |
                     jq)
    echo "${parameters}"
}

create() {
    local parameters
    parameters=$(get_parameters)
    echo "${parameters}"
    aws cloudformation create-stack --stack-name "${SSO_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/sso/sso-stack.yml \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters "${parameters}" \
        --enable-termination-protection
    aws cloudformation \
        wait \
        stack-create-complete \
        --stack-name "${SSO_STACK_NAME}"
}

update() {
    local parameters
    parameters=$(get_parameters)
    aws cloudformation update-stack --stack-name "${SSO_STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/sso/sso-stack.yml \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters "${parameters}"
    aws cloudformation \
        wait \
        stack-update-complete \
        --stack-name "${SSO_STACK_NAME}"
}

delete() {
    aws cloudformation delete-stack --stack-name "${SSO_STACK_NAME}"
    aws cloudformation \
        wait \
        stack-delete-complete \
        --stack-name "${SSO_STACK_NAME}"
}

describe_stack() {
    aws cloudformation describe-stacks
    aws cloudformation describe-stack-events \
        --stack-name "${SSO_STACK_NAME}"
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
describe
EOF
}

main() {
    args="$@"

    export AWS_PROFILE="master-admin"
    if [[ "${AWS_PROFILE}" != "master-admin" ]]; then
        echo "Got AWS_PROFILE: ${AWS_PROFILE}"
        echo "This must be run in the master account! (master-admin)"
        echo "Exiting."
        exit 1
    fi

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
