#!/bin/bash
# Use this for managing CFN stacks

set -e
set -u

export REPO_ROOT=$(git rev-parse --show-toplevel)
export STACK_NAME="drupal-quick-start"
export AZS="ap-southeast-2a,ap-southeast-2b"
export KEY_PAIR="drupal"

source "${REPO_ROOT}"/bin/_utils.sh

generate_password() {
    openssl rand -base64 16 | sed 's/=//g' | sed 's/+//g'
}

create() {

    local parameters
    local password
    password=$(generate_password)
    echo "Filling in parameters from .envrc"
    parameters=$(cat "${REPO_ROOT}"/infra/drupal/drupal-parameters.json |
                     sed "s/{{ REMOTE_ACCESS_CIDER }}/${MY_IP}\/32/g" |
                     sed "s/{{ DEVELOPER_EMAIL }}/${DEVELOPER_EMAIL}/g" |
                     sed "s/{{ AVAILABILITY_ZONES }}/${AZS}/g" |
                     sed "s/{{ KEY_PAIR }}/${KEY_PAIR}/g" |
                     sed "s/{{ PASSWORD }}/${password}/g" |
                     jq)


    echo "Validating template..."
    aws cloudformation validate-template \
        --template-body file://"${REPO_ROOT}"/infra/drupal/drupal-stack.yml

    echo "Parameters:"
    echo "${parameters}"
    echo "Creating stack..."
    aws cloudformation create-stack \
        --stack-name "${STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/drupal/drupal-stack.yml \
        --parameters "${parameters}" \
        --capabilities CAPABILITY_IAM # Assumes you have a role that can do this
}

update() {

    local parameters
    local password
    password=$(generate_password)
    echo "Filling in parameters from .envrc"
    parameters=$(cat "${REPO_ROOT}"/infra/drupal/drupal-parameters.json |
                     sed "s/{{ REMOTE_ACCESS_CIDER }}/${MY_IP}\/32/g" |
                     sed "s/{{ DEVELOPER_EMAIL }}/${DEVELOPER_EMAIL}/g" |
                     sed "s/{{ AVAILABILITY_ZONES }}/${AZS}/g" |
                     sed "s/{{ KEY_PAIR }}/${KEY_PAIR}/g" |
                     sed "s/{{ PASSWORD }}/${password}/g" |
                     jq)


    echo "Validating template..."
    aws cloudformation validate-template \
        --template-body file://"${REPO_ROOT}"/infra/drupal/drupal-stack.yml

    echo "Parameters:"
    echo "${parameters}"
    echo "Creating stack..."
    aws cloudformation update-stack \
        --stack-name "${STACK_NAME}" \
        --template-body file://"${REPO_ROOT}"/infra/drupal/drupal-stack.yml \
        --parameters "${parameters}" \
        --capabilities CAPABILITY_IAM # Assumes you have a role that can do this
}

delete() {
    aws cloudformation delete-stack \
        --stack-name "${STACK_NAME}"
    echo "Deleting stack..."
}

describe_stacks() {
    aws cloudformation describe-stacks
}

describe_stack_events() {
    aws cloudformation describe-stack-events \
        --stack-name "${STACK_NAME}"
}

usage() {
    cat <<EOF
Manages a stack for drupal-quick-start

Usage: ./bin/stack <arg>
Where arg is:
create                - creates the stack
delete                - deletes the stack
describe-stacks       - describes stacks
describe-stack-events - describes stack events
EOF
}

main() {
    args="$@"
    check_environment

    if [ "${args}" == "create" ]; then
        create
    elif [ "${args}" == "delete" ]; then
        delete
    elif [ "${args}" == "update" ]; then
        update
    elif [ "${args}" == "describe-stacks" ]; then
        describe_stacks
    elif [ "${args}" == "describe-stack-events" ]; then
        describe_stack_events
    else
        usage
    fi

}

main "$@"
