#!/bin/bash

# Deploys Panther stack. Must be in us-east-1.
# https://docs.runpanther.io/quick-start

source "${REPO_ROOT}"/bin/_utils.sh

# Panthers is in US
export AWS_REGION="us-east-1"

create() {
    AWS_REGION=us-east-1 aws cloudformation deploy \
        --template-file "${REPO_ROOT}"/infra/panther/panther.yml \
        --stack-name panther \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
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
