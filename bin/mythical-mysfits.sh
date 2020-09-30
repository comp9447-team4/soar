#!/bin/bash

set -e
set -u

source "${REPO_ROOT}"/bin/_utils.sh

export AWS_PAGER=""
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

# Module 1
export STATIC_SITE_STACK_NAME="MythicalMystfitsStaticSiteStack"
export STATIC_SITE_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/static-site.yml"
# Module 2
export CORE_STACK_NAME="MythicalMysfitsCoreStack"
export CORE_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/core.yml"
export ECR_STACK_NAME="MythicalMysfitsECRStack"
export ECR_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/ecr.yml"
export ECS_STACK_NAME="MythicalMysfitsECSStack"
export ECS_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/ecs.yml"
export CICD_STACK_NAME="MythicalMysfitsCICDStack"
export CICD_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/cicd.yml"

# Module 1
create_static_site() {
    local bucket_name
    bucket_name="${AWS_PROFILE}-comp9447-team4-mythical-mysfits"

    echo "Deploying bucket stack..."
    aws cloudformation create-stack \
        --stack-name "${STATIC_SITE_STACK_NAME}" \
        --template-body file://"${STATIC_SITE_STACK_YML}" \
        --parameters ParameterKey=BucketName,ParameterValue="${bucket_name}" \
        --enable-termination-protection

    wait
    echo "Waiting for stack to be created..."
    wait_build "${STATIC_SITE_STACK_NAME}"
    echo "Copying to S3..."
    aws s3 cp \
        "${REPO_ROOT}"/mythical-mysfits/web/index.html \
        s3://"${bucket_name}"/index.html

    echo "You should now see this on your browser:"
    local url="https://${bucket_name}.s3.amazonaws.com/index.html"
    echo "${url}"
    curl "${url}" | head -15
}

# Module 2
create_core() {
    # https://github.com/aws-samples/aws-modern-application-workshop/tree/python/module-2
    aws cloudformation create-stack \
        --stack-name "${CORE_STACK_NAME}" \
        --template-body file://"${CORE_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    wait_build "${CORE_STACK_NAME}"
}

create_ecr() {
    echo "Creating ECR..."
    aws cloudformation create-stack \
        --stack-name "${ECR_STACK_NAME}" \
        --template-body file://"${ECR_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    wait_build "${ECR_STACK_NAME}"

}

build_docker_image() {
    cd "${REPO_ROOT}/mythical-mysfits/app"
    # I'd prefer using immutable tags but latest will do for now...
    sudo docker build \
           . \
           -t "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/mythicalmysfits/service:latest"
    cd -
}

login_to_ecr() {
    aws ecr get-login-password \
        --region "${AWS_REGION}" \
        | sudo docker login \
                 --username AWS \
                 --password-stdin "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com
}

push_image_to_ecr() {
    echo "Pushing image to ECR..."
    login_to_ecr
    sudo docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/mythicalmysfits/service:latest"
}

create_ecs() {
    echo "Creating ecs stack..."
    aws cloudformation create-stack \
        --stack-name "${ECS_STACK_NAME}" \
        --template-body file://"${ECS_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection

    echo "Creating fargate service..."
    wait_build "${ECS_STACK_NAME}"
    aws ecs create-service --cli-input-json "${REPO_ROOT}"/mythical-mysfits/module-2/aws-cli/service-definition.json
}

create_cicd() {
    local bucket_name
    bucket_name="${AWS_PROFILE}-comp9447-team4-mythical-mysfits-artifacts"
    aws cloudformation create-stack \
        --stack-name "${CICD_STACK_NAME}" \
        --template-body file://"${CICD_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=BucketName,ParameterValue="${bucket_name}" \
        --enable-termination-protection
    wait_build "${CICD_STACK_NAME}"
}

init_mystical_mysfits_repo() {
    cd "${REPO_ROOT}/.."
    git clone https://git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/MythicalMysfitsService-Repository

    cp -r "${REPO_ROOT}"/mythical-mysfits/app/* "${REPO_ROOT}"/../MythicalMysfitsService-Repository/

    git add .
    git commit -m "I changed the age of one of the mysfits."
    git push

    cd "${REPO_ROOT}"
}


usage() {
    cat <<EOF
Creates the Mythical Mysfits core stack.
Reference: https://github.com/aws-samples/aws-modern-application-workshop/tree/python

Usage: AWS_PROFILE=qa ./bin/mythical-mysfits.sh <arg>
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
        usage
    fi

    if [[ "${args}" == "create-module-1" ]]; then
        # Module 1
        create_static_site
    elif [[ "${args}" == "create-module-2" ]]; then
        # create_core
        # create_ecr
        # build_docker_image
        # push_image_to_ecr

        create_ecs

        create_cicd

    else
        echo "No command run :("
        usage
    fi

}

main "$@"
