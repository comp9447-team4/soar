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

create-waf-stack()  {
    echo "Do you wish to deploy to endpoint CloudFront?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) sam deploy \
        -t services/WAF/templates/aws-waf-security-automations.template \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --config-file services/WAF/templates/waf-cloudfront-deploy.toml; break;;
        No ) continue;;
    esac
    done

    echo "Do you wish to deploy to endpoint ALB?"
    select yn in "Yes" "No"; do
    case $yn in
        Yes ) sam deploy \
        -t services/WAF/templates/aws-waf-security-automations.template \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --config-file services/WAF/templates/waf-api-deploy.toml; break;;
        No ) continue;;
    esac
    done

}


usage() {
    cat <<EOF
Manages CFN stacks for the SOAR solution
Reference: https://github.com/aws-samples/aws-modern-application-workshop/tree/python

Usage: AWS_ENVIRONMENT=qa ./bin/soar.sh <arg>
Where arg is:
create-cicd
update-cicd
create-secrets
create-waf-stack
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
    elif [[ "${args}" == "create-waf-stack" ]]; then
        create-waf-stack
    else
        echo "Not a valid argument..."
        usage
    fi
}

main "$@"
