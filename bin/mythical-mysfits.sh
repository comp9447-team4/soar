#!/bin/bash

set -e
set -u

source "${REPO_ROOT}"/bin/_utils.sh

export MODULE_1_STACK_NAME="MythicalMystfitsStaticSiteStack"
export MODULE_1_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/static-site.yml"

export MODULE_2_CORE_STACK_NAME="MythicalMysfitsCoreStack"
export MODULE_2_CORE_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/core.yml"

export AWS_REGION="us-east-1"


create_static_site() {
    local bucket_name
    bucket_name="${AWS_PROFILE}-comp9447-team4-mythical-mysfits"

    echo "Deploying bucket stack..."
    aws cloudformation create-stack \
        --stack-name "${MODULE_1_STACK_NAME}" \
        --template-body file://"${MODULE_1_STACK_YML}" \
        --parameters ParameterKey=BucketName,ParameterValue="${bucket_name}" \
        --enable-termination-protection

    wait
    echo "Waiting for stack to be created... (ugh not the best way to do this...)"
    sleep 10
    echo "Copying to S3..."
    aws s3 cp \
        "${REPO_ROOT}"/mythical-mysfits/web/index.html \
        s3://"${bucket_name}"/index.html

    echo "You should now see this on your browser:"
    local url="https://${bucket_name}.s3.amazonaws.com/index.html"
    echo "${url}"
    curl "${url}" | head -15
}

create_core() {
    # https://github.com/aws-samples/aws-modern-application-workshop/tree/python/module-2
    aws cloudformation create-stack \
        --stack-name "${MODULE_2_CORE_STACK_NAME}" \
        --template-body file://"${MODULE_2_CORE_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
}

usage() {
    cat <<EOF
Creates the Mythical Mysfits core stack.
Reference: https://github.com/aws-samples/aws-modern-application-workshop/tree/python

Usage: ./bin/mythical-mysfits.sh <arg>
Where arg is:
create-module-1
create-module-2
EOF
}

main() {
    args="$@"

    if [[ "${AWS_PROFILE}" == "prod" ]]; then
        echo "In environment: ${AWS_PROFILE}"
    elif [[ "${AWS_PROFILE}" == "qa" ]]; then
        echo "In environment: ${AWS_PROFILE}"
    else
        echo "Unknown AWS_PROFILE ${AWS_PROFILE}"
        echo "Unknown AWS_PROFILE. Must be 'qa' or 'prod'. Did you setup your aws cli properly? See README."
        echo "Must be prod or qa"
    fi

    if [[ "${args}" == "create-module-1" ]]; then
        # Module 1
        create_static_site
    elif [[ "${args}" == "create-module-2" ]]; then
        create_core
    else
        echo "No command run :("
        usage
    fi

}

main "$@"
