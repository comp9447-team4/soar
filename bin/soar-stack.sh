#!/bin/bash

set -e
set -o pipefail
set -u

source "${REPO_ROOT}"/bin/_utils.sh

export AWS_ENVIRONMENT="${AWS_PROFILE}"

# The CICD pipelines
export AWS_REGION="us-east-1"
export CICD_STACK_NAME="${AWS_ENVIRONMENT}-SoarCicd"
export CICD_STACK_YML="${REPO_ROOT}/infra/soar/cicd.yml"

create_cicd() {
    echo "Creating CICD stack..."
    aws cloudformation create-stack \
        --stack-name "${CICD_STACK_NAME}" \
        --template-body file://"${CICD_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}" \
        --enable-termination-protection
    wait_build "${CICD_STACK_NAME}"
}

update_cicd() {
    echo "Creating CICD stack..."
    aws cloudformation update-stack \
        --stack-name "${CICD_STACK_NAME}" \
        --template-body file://"${CICD_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}"
    wait_update "${CICD_STACK_NAME}"
}

delete_cicd() {
    echo "Deleting cicd stack..."
    aws cloudformation \
        update-termination-protection \
        --stack-name "${CICD_STACK_NAME}" \
        --no-enable-termination-protection

    aws cloudformation \
        delete-stack \
        --stack-name "${CICD_STACK_NAME}"

}

# Store Secrets in this stack
export SECRETS_STACK_NAME="${AWS_ENVIRONMENT}-SoarSecrets"
export SECRETS_STACK_YML="${REPO_ROOT}/infra/soar/secrets.yml"

create_secrets() {
    echo "Creating secrets stack..."
    aws cloudformation create-stack \
        --stack-name "${SECRETS_STACK_NAME}" \
        --template-body file://"${SECRETS_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    wait_build "${SECRETS_STACK_NAME}"
}

export CLOUDTRAIL_STACK_NAME="${AWS_ENVIRONMENT}-CloudTrail"
export CLOUDTRAIL_STACK_YML="${REPO_ROOT}/infra/soar/cloudtrail.yml"
create_cloudtrail() {
    echo "Creating cloudtrail stack..."
    aws cloudformation create-stack \
        --stack-name "${CLOUDTRAIL_STACK_NAME}" \
        --template-body file://"${CLOUDTRAIL_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}" \
        --enable-termination-protection
    wait_build "${CLOUDTRAIL_STACK_NAME}"
}

update_cloudtrail() {
    echo "Creating cloudtrail stack..."
    aws cloudformation update-stack \
        --stack-name "${CLOUDTRAIL_STACK_NAME}" \
        --template-body file://"${CLOUDTRAIL_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}"
    wait_build "${CLOUDTRAIL_STACK_NAME}"
}

# Athena and ES for analytics
export ATHENA_STACK_NAME="${AWS_ENVIRONMENT}-Athena"
export ATHENA_STACK_YML="${REPO_ROOT}/infra/soar/athena.yml"
create_athena() {
    echo "Creating athena stack..."
    aws cloudformation create-stack \
        --stack-name "${ATHENA_STACK_NAME}" \
        --template-body file://"${ATHENA_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}" \
        --enable-termination-protection
    wait_build "${ATHENA_STACK_NAME}"
}

update_athena() {
    echo "Creating athena stack..."
    aws cloudformation update-stack \
        --stack-name "${ATHENA_STACK_NAME}" \
        --template-body file://"${ATHENA_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}"
}

export ES_STACK_NAME="${AWS_ENVIRONMENT}-es"
export ES_STACK_YML="${REPO_ROOT}/infra/soar/es.yml"
create_es() {
    echo "Creating es stack..."
    aws cloudformation create-stack \
        --stack-name "${ES_STACK_NAME}" \
        --template-body file://"${ES_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}" \
        --enable-termination-protection
    wait_build "${ES_STACK_NAME}"
}

update_es() {
    echo "Creating es stack..."
    aws cloudformation update-stack \
        --stack-name "${ES_STACK_NAME}" \
        --template-body file://"${ES_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_ENVIRONMENT}"
}

usage() {
    cat <<EOF
Manages CFN stacks for the SOAR solution
Reference: https://github.com/aws-samples/aws-modern-application-workshop/tree/python

Usage: AWS_PROFILE=qa ./bin/soar.sh <arg>
Where arg is:
create-cicd
update-cicd
create-secrets
create-athena
create-es
EOF
}
main() {
    args="$1"
    if [[ "${AWS_ENVIRONMENT}" == "prod" ]]; then
        echo "In environment: ${AWS_ENVIRONMENT}"
    elif [[ "${AWS_ENVIRONMENT}" == "qa" ]]; then
        echo "In environment: ${AWS_ENVIRONMENT}"
    else
        echo "Unknown AWS_ENVIRONMENT ${AWS_ENVIRONMENT}"
        echo "Unknown AWS_ENVIRONMENT. Must be 'qa' or 'prod'. Did you setup your aws cli properly? See README."
        echo "Must be prod or qa"
        usage
        exit 1
    fi

    if [[ "${args}" == "create-cicd" ]]; then
        create_cicd
    elif [[ "${args}" == "create-secrets" ]]; then
        create_secrets
    elif [[ "${args}" == "update-cicd" ]]; then
        update_cicd
    elif [[ "${args}" == "delete-cicd" ]]; then
        delete_cicd
    elif [[ "${args}" == "create-cloudtrail" ]]; then
        create_cloudtrail
    elif [[ "${args}" == "update-cloudtrail" ]]; then
        update_cloudtrail
    elif [[ "${args}" == "create-athena" ]]; then
        create_athena
    elif [[ "${args}" == "update-athena" ]]; then
        update_athena
    elif [[ "${args}" == "create-es" ]]; then
        create_es
    elif [[ "${args}" == "update-es" ]]; then
        update_es
    else
        echo "Not a valid argument..."
        usage
    fi
}

main "$@"
