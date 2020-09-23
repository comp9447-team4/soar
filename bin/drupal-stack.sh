#!/bin/bash
# Use this for managing CFN stacks

set -e
set -u

export REPO_ROOT=$(git rev-parse --show-toplevel)
export STACK_NAME="drupal-quick-start"
export AZS="us-east-1a,us-east-1b"
export KEY_PAIR="drupal"

# Drupal keypair is in US
export AWS_REGION="us-east-1"

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
        --capabilities CAPABILITY_IAM \
        --enable-termination-protection

    # Ideally it should be part of the stack
    # but it requires keypairs to exists
    # and the drupal stack is quite convoluted...
    aws secretsmanager create-secret \
        --name "drupal-parameters" \
        --secret-string "${parameters}"
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

# Uncomment if you are sure
# delete() {
#     aws cloudformation delete-stack \
#         --stack-name "${STACK_NAME}"
#     echo "Deleting stack..."
#
#     aws secretsmanager delete-secret \
#         --secret-id "drupal-parameters" \
#         --force-delete-without-recovery
# }

describe() {
    aws cloudformation describe-stacks
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
describe              - describes the stack and its events
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
    elif [ "${args}" == "describe" ]; then
        describe
    else
        usage
    fi

}

main "$@"
