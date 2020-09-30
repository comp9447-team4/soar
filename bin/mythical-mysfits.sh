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
export STATIC_SITE_BUCKET_NAME="${AWS_PROFILE}-comp9447-team4-mythical-mysfits"

# Module 2
export CORE_STACK_NAME="MythicalMysfitsCoreStack"
export CORE_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/core.yml"
export ECR_STACK_NAME="MythicalMysfitsECRStack"
export ECR_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/ecr.yml"
export ECS_STACK_NAME="MythicalMysfitsECSStack"
export ECS_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/ecs.yml"
export FARGATE_SERVICE_STACK_NAME="MythicalMysfitsFargateServiceStack"
export FARGATE_SERVICE_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/fargate-service.yml"
export CICD_STACK_NAME="MythicalMysfitsCICDStack"
export CICD_STACK_YML="${REPO_ROOT}/mythical-mysfits/cfn/cicd.yml"
export MYTHICAL_MYSFITS_REPO="${REPO_ROOT}/../MythicalMysfitsService-Repository"
export ECR_IMAGE="${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com
export ECR_IMAGE_TAG="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/mythicalmysfits/service:latest"

# Module 1
create_static_site() {

    echo "Deploying bucket stack..."
    aws cloudformation create-stack \
        --stack-name "${STATIC_SITE_STACK_NAME}" \
        --template-body file://"${STATIC_SITE_STACK_YML}" \
        --parameters ParameterKey=BucketName,ParameterValue="${STATIC_SITE_BUCKET_NAME}" \
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
    cd "${REPO_ROOT}/mythical-mysfits/module-2/app"
    # I'd prefer using immutable tags but latest will do for now...
    sudo docker build \
           . \
           -t "${ECR_IMAGE_TAG}"
    cd -
}

login_to_ecr() {
    aws ecr get-login-password \
        --region "${AWS_REGION}" \
        | sudo docker login \
                 --username AWS \
                 --password-stdin "${ECR_IMAGE}"
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
        --parameters ParameterKey=ECRImageTag,ParameterValue="${ECR_IMAGE_TAG}" \
        --enable-termination-protection

    wait_build "${ECS_STACK_NAME}"
}

create_fargate_service(){
    echo "Creating fargate service separately because cfn doesn't play well with it..."
    echo "https://stackoverflow.com/questions/32727520/cloudformation-template-for-creating-ecs-service-stuck-in-create-in-progress"


    local nlb_tg=$(get_cfn_export MythicalMysfitsECSStack:NLBTargetGroup)
    local sg=$(get_cfn_export MythicalMysfitsCoreStack:FargateContainerSecurityGroup)
    local subnet_one=$(get_cfn_export MythicalMysfitsCoreStack:PrivateSubnetOne)
    local subnet_two=$(get_cfn_export MythicalMysfitsCoreStack:PrivateSubnetTwo)

    local parameters
    parameters=$(cat "${REPO_ROOT}"/mythical-mysfits/module-2/aws-cli/service-definition.json |
                     sed "s/REPLACE_ME_SECURITY_GROUP_ID/${sg}/g" |
                     sed "s/REPLACE_ME_NLB_TARGET_GROUP_ARN/${nlb_tg}/g" |
                     sed "s/REPLACE_ME_PRIVATE_SUBNET_ONE/${subnet_one}/g" |
                     sed "s/REPLACE_ME_PRIVATE_SUBNET_TWO/${subnet_two}/g"
    )

    echo "${parameters}"
    aws ecs create-service \
       --cli-input-json "${parameters}"

    # local task_def_arn=$(aws ecs list-task-definitions --family-prefix mythicalmysfitsservice | jq -r '.taskDefinitionArns[0]')
    # aws cloudformation create-stack \
    #     --stack-name "${FARGATE_SERVICE_STACK_NAME}" \
    #     --template-body file://"${FARGATE_SERVICE_STACK_YML}" \
    #     --capabilities CAPABILITY_NAMED_IAM \
    #     --parameters ParameterKey=TaskDefArn,ParameterValue="${task_def_arn}" \
    #     --enable-termination-protection
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

update_bucket() {
    aws s3 cp "${REPO_ROOT}"/mythical-mysfits/module-2/web/index.html s3://"${STATIC_SITE_BUCKET_NAME}"/index.html
}

init_mystical_mysfits_repo() {
    echo "Copying Module 2 app code into mythical mysfits repo..."
    cd "${REPO_ROOT}/.."
    git clone https://git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/MythicalMysfitsService-Repository
    cp -r "${REPO_ROOT}"/mythical-mysfits/module-2/app/* "${MYTHICAL_MYSFITS_REPO}"

    cd "${MYTHICAL_MYSFITS_REPO}"
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

        # create_ecs
        # create_fargate_service

        update_bucket
        # create_cicd
        # init_mystical_mysfits_repo

    else
        echo "No command run :("
        usage
    fi

}

main "$@"
