#!/bin/bash

set -e
set -u

source "${REPO_ROOT}"/bin/_utils.sh

export AWS_PAGER=""
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

######################################################################################
# Module 1
######################################################################################
export STATIC_SITE_STACK_NAME="MythicalMystfitsStaticSiteStack"
export STATIC_SITE_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/static-site.yml"
export STATIC_SITE_BUCKET_NAME="${AWS_PROFILE}-comp9447-team4-mythical-mysfits"

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
    update_bucket

    echo "You should now see this on your browser:"
    local url="http://${STATIC_SITE_BUCKET_NAME}.s3-website.${AWS_REGION}.amazonaws.com"
    echo "${url}"
    curl "${url}" | head -15
}

######################################################################################
# Module 2
######################################################################################
export CORE_STACK_NAME="MythicalMysfitsCoreStack"
export CORE_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/core.yml"
export ECR_STACK_NAME="MythicalMysfitsECRStack"
export ECR_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/ecr.yml"
export ECS_STACK_NAME="MythicalMysfitsECSStack"
export ECS_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/ecs.yml"
export FARGATE_SERVICE_STACK_NAME="MythicalMysfitsFargateServiceStack"
export FARGATE_SERVICE_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/fargate-service.yml"
export CICD_STACK_NAME="MythicalMysfitsCICDStack"
export CICD_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/cicd.yml"
export MYTHICAL_MYSFITS_REPO="${REPO_ROOT}/../MythicalMysfitsService-Repository"
export ECR_IMAGE="${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com
export ECR_IMAGE_TAG="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/mythicalmysfits/service:latest"
create_core() {
    # https://github.com/aws-samples/aws-modern-application-workshop/tree/python/module-2
    aws cloudformation create-stack \
        --stack-name "${CORE_STACK_NAME}" \
        --template-body file://"${CORE_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    wait_build "${CORE_STACK_NAME}"
}

update_core() {
    echo "Updating core roles..."
    aws cloudformation update-stack \
        --stack-name "${CORE_STACK_NAME}" \
        --template-body file://"${CORE_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM
    aws cloudformation wait stack-update-complete --stack-name "${CORE_STACK_NAME}"
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
    aws cloudformation create-stack \
        --stack-name "${CICD_STACK_NAME}" \
        --template-body file://"${CICD_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsProfile,ParameterValue="${AWS_PROFILE}" \
        --enable-termination-protection

    wait_build "${CICD_STACK_NAME}"
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

update_bucket() {
    echo "Copying index.html to static bucket..."
    aws s3 cp "${REPO_ROOT}"/mythical-mysfits/module-2/web/index.html s3://"${STATIC_SITE_BUCKET_NAME}"/index.html
}

init_mystical_mysfits_repo() {
    echo "Copying Module 2 app code into mythical mysfits repo..."
    cd "${REPO_ROOT}/.."
    rm -rf "${MYTHICAL_MYSFITS_REPO}"

    cd "${MYTHICAL_MYSFITS_REPO}"
    echo "Follow some git commands..."
    git add .
    git config --global credential.helper '!aws codecommit credential-helper $@'
    git config --global credential.UseHttpPath true
    git commit -m "I changed the age of one of the mysfits."
    git push

    cd "${REPO_ROOT}"
}

######################################################################################
# Module 3
# https://github.com/aws-samples/aws-modern-application-workshop/tree/python/module-3
######################################################################################
export DYNAMODB_STACK_NAME="MythicalMysfitsDynamoDBStack"
export DYNAMODB_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/dynamodb.yml"

create_dynamodb() {
    aws cloudformation create-stack \
        --stack-name "${DYNAMODB_STACK_NAME}" \
        --template-body file://"${DYNAMODB_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    wait_build "${DYNAMODB_STACK_NAME}"
}

write_dynamodb_items() {
    aws dynamodb \
        batch-write-item \
        --request-items \
        file://"${REPO_ROOT}"/mythical-mysfits/module-3/aws-cli/populate-dynamodb.json
}

module_3_code_updates() {
    cp "${REPO_ROOT}"/mythical-mysfits/module-3/app/service/* \
       "${MYTHICAL_MYSFITS_REPO}"/service/
    cd "${MYTHICAL_MYSFITS_REPO}"

    git add .
    git commit -m "Add new integration to DynamoDB."
    git push
    cd "${REPO_ROOT}"

}
module_3_s3_updates() {
    echo "Running a state of the art CI/CD to render static content! (not)..."
    local nlb_dns_name=$(get_cfn_export MythicalMysfitsECSStack:NLBDNSName)
    local new_index_html=$(cat "${REPO_ROOT}/mythical-mysfits/module-3/web/index.html" |
                         sed "s/REPLACE_ME/http:\/\/${nlb_dns_name}/g"
    )

    mkdir -p "${REPO_ROOT}"/tmp
    echo "${new_index_html}" > "${REPO_ROOT}"/tmp/index.html

    aws s3 cp "${REPO_ROOT}"/tmp/index.html \
        s3://"${STATIC_SITE_BUCKET_NAME}"/
    cd "${REPO_ROOT}"

    rm -rf "${REPO_ROOT}"/tmp
}

######################################################################################
# Module 4
# https://github.com/aws-samples/aws-modern-application-workshop/tree/python/module-4
######################################################################################

export USER_POOL_STACK_NAME="MythicalMysfitsUserPoolStack"
export USER_POOL_STACK_YML="${REPO_ROOT}/infra/mythical-mysfits/user-pool.yml"
create_user_pool() {
    echo "Creating user pool..."
    aws cloudformation create-stack \
        --stack-name "${USER_POOL_STACK_NAME}" \
        --template-body file://"${USER_POOL_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_PROFILE}" \
        --enable-termination-protection
    wait_build "${USER_POOL_STACK_NAME}"

    # echo "Updating user pool..."
    # aws cloudformation update-stack \
    #     --stack-name "${USER_POOL_STACK_NAME}" \
    #     --template-body file://"${USER_POOL_STACK_YML}" \
    #     --capabilities CAPABILITY_NAMED_IAM \
    #     --parameters ParameterKey=AwsEnvironment,ParameterValue="${AWS_PROFILE}"
}

module_4_code_updates() {
    cp -r "${REPO_ROOT}"/mythical-mysfits/module-4/app/* "${MYTHICAL_MYSFITS_REPO}"
    cd "${MYTHICAL_MYSFITS_REPO}"
    git add .
    git commit -m "Update service code backend to enable additional website features."
    git push
    cd "${REPO_ROOT}"
}

module_4_s3_updates() {
    echo "Running a state of the art CI/CD to render static content! (not)..."
    local cognito_user_pool_id=$(get_cfn_export MythicalMysfitsUserPoolStack:CognitoUserPoolId)
    local cognito_user_pool_client_id=$(get_cfn_export MythicalMysfitsUserPoolStack:CognitoUserPoolClientId)
    local api_endpoint=$(get_cfn_export MythicalMysfitsUserPoolStack:ApiEndpoint)
    local new_index_html=$(cat "${REPO_ROOT}/mythical-mysfits/module-4/web/index.html" |
                               sed "s/var cognitoUserPoolId = 'REPLACE_ME';/var cognitoUserPoolId = \'${cognito_user_pool_id}\';/" |
                               sed "s/var cognitoUserPoolClientId = 'REPLACE_ME';/var cognitoUserPoolClientId = \'${cognito_user_pool_client_id}\';/" |
                               sed "s/var awsRegion = 'REPLACE_ME';/var awsRegion = \'${AWS_REGION}\';/" |
                               sed "s/var mysfitsApiEndpoint = 'REPLACE_ME';/var mysfitsApiEndpoint = \'${api_endpoint}\';/g"
          )
    local new_register_html=$(cat "${REPO_ROOT}/mythical-mysfits/module-4/web/register.html" |
                                  sed "s/var cognitoUserPoolId = 'REPLACE_ME';/var cognitoUserPoolId = \'${cognito_user_pool_id}\';/" |
                                  sed "s/var cognitoUserPoolClientId = 'REPLACE_ME';/var cognitoUserPoolClientId = \'${cognito_user_pool_client_id}\';/"
    )
    local new_confirm_html=$(cat "${REPO_ROOT}/mythical-mysfits/module-4/web/confirm.html" |
                                  sed "s/var cognitoUserPoolId = 'REPLACE_ME';/var cognitoUserPoolId = \'${cognito_user_pool_id}\';/" |
                                  sed "s/var cognitoUserPoolClientId = 'REPLACE_ME';/var cognitoUserPoolClientId = \'${cognito_user_pool_client_id}\';/"
          )

    rm -rf "${REPO_ROOT}"/tmp
    mkdir -p "${REPO_ROOT}"/tmp
    cp -r "${REPO_ROOT}"/mythical-mysfits/module-4/web/* "${REPO_ROOT}"/tmp
    echo "${new_index_html}" > "${REPO_ROOT}"/tmp/index.html
    echo "${new_register_html}" > "${REPO_ROOT}"/tmp/register.html
    echo "${new_confirm_html}" > "${REPO_ROOT}"/tmp/confirm.html

    aws s3 cp --recursive \
        "${REPO_ROOT}"/tmp/ \
        s3://"${STATIC_SITE_BUCKET_NAME}"/

    cd "${REPO_ROOT}"
    echo "Cleaning up..."
    rm -rf "${REPO_ROOT}"/tmp
}

######################################################################################
# Module 5
# https://github.com/aws-samples/aws-modern-application-workshop/tree/python/module-5
######################################################################################
# export STREAMING_SERVICE_REPO="${REPO_ROOT}"/../MythicalMysfitsStreamingService-Repository
export STREAMING_SERVICE_CICD_STACK_NAME="MythicalMysfitsStreamingServiceCICDStack"
export STREAMING_SERVICE_CICD_YML="${REPO_ROOT}"/infra/mythical-mysfits/streaming-service-cicd.yml
create_streaming_service_cicd() {
    echo "Creating streaming service stack..."
    aws cloudformation create-stack \
        --stack-name "${STREAMING_SERVICE_CICD_STACK_NAME}" \
        --template-body file://"${STREAMING_SERVICE_CICD_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    wait_build "${STREAMING_SERVICE_CICD_STACK_NAME}"
}

update_streaming_service_cicd() {
    echo "Updating streaming service stack..."
    aws cloudformation update-stack \
        --stack-name "${STREAMING_SERVICE_CICD_STACK_NAME}" \
        --template-body file://"${STREAMING_SERVICE_CICD_YML}" \
        --capabilities CAPABILITY_NAMED_IAM
    aws cloudformation wait stack-update-complete --stack-name "${STREAMING_SERVICE_CICD_STACK_NAME}"
}

init_streaming_service_repo() {
    echo "Cloning repository..."
    cd "${REPO_ROOT}"/..
    rm -rf "${STREAMING_SERVICE_REPO}"
    git clone https://git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/MythicalMysfitsStreamingService-Repository
    echo "Copying files to the streaming service repo..."
    cp -r "${REPO_ROOT}"/mythical-mysfits/module-5/app/streaming/* "${STREAMING_SERVICE_REPO}"
    cp "${REPO_ROOT}"/mythical-mysfits/module-5/cfn/* "${STREAMING_SERVICE_REPO}"

    cd "${STREAMING_SERVICE_REPO}"
    git add .
    # git config --global credential.helper '!aws codecommit credential-helper $@'
    # git config --global credential.UseHttpPath true
    git commit -m "New stream processing service."
    git push

    cd "${REPO_ROOT}"
}

package_streaming_lambda() {

    echo "Gonna make changes to streaming service..."
    echo "Going to streaming service repo..."
    cd "${STREAMING_SERVICE_REPO}"
    git reset --hard HEAD
    local api_endpoint=$(get_cfn_export MythicalMysfitsUserPoolStack:ApiEndpoint)
    local lambda_artifacts_bucket=$(get_cfn_export MythicalMysfitsStreamingServiceStack:LambdaArtifactsBucket)

    echo "Changing api endpoint of stream processor..."
    local new_stream_processor=$( cat ./streamProcessor.py |
        sed "s/apiEndpoint = 'REPLACE_ME_API_ENDPOINT'/apiEndpoint = \'${api_endpoint}\'/g"
    )
    echo "${new_stream_processor}" > ./streamProcessor.py
    echo "Written new stream processor"

    echo "Installing requests..."
    pip3 install requests -t .

    echo "Creating sam package..."
    sam package \
        --template-file ./real-time-streaming.yml \
        --output-template-file ./transformed-streaming.yml \
        --s3-bucket "${lambda_artifacts_bucket}"
    wait
    cd "${REPO_ROOT}"
}

deploy_streaming_lambda() {
    echo "Going to streaming service repo..."
    cd "${STREAMING_SERVICE_REPO}"
    echo "Deploying lambda..."
    aws cloudformation deploy \
        --template-file ./transformed-streaming.yml \
        --stack-name MythicalMysfitsStreamingStack \
        --capabilities CAPABILITY_IAM

    echo "Lambda being deployed..."
    echo "Going back to main repo..."
    cd "${REPO_ROOT}"
}


module_5_static_site_updates() {
    # aws s3 cp ~/environment/aws-modern-application-workshop/module-5/web/index.html s3://YOUR-S3-BUCKET/
    echo "Running a state of the art CI/CD to render static content! (not)..."
    local cognito_user_pool_id=$(get_cfn_export MythicalMysfitsUserPoolStack:CognitoUserPoolId)
    echo "${cognito_user_pool_id}"
    local cognito_user_pool_client_id=$(get_cfn_export MythicalMysfitsUserPoolStack:CognitoUserPoolClientId)
    echo "${cognito_user_pool_client_id}"
    local api_endpoint=$(get_cfn_export MythicalMysfitsUserPoolStack:ApiEndpoint)
    echo "${api_endpoint}"
    local streaming_api_endpoint=$(aws cloudformation describe-stacks --stack-name MythicalMysfitsStreamingStack |
        jq -r '.Stacks[0].Outputs[0].OutputValue' |
        sed -r 's/\//\\\//g'
    )
    echo "${streaming_api_endpoint}"

    local new_index_html=$(cat "${REPO_ROOT}/mythical-mysfits/module-5/web/index.html" |
        sed "s/var cognitoUserPoolId = 'REPLACE_ME';/var cognitoUserPoolId = \'${cognito_user_pool_id}\';/" |
        sed "s/var cognitoUserPoolClientId = 'REPLACE_ME';/var cognitoUserPoolClientId = \'${cognito_user_pool_client_id}\';/" |
        sed "s/var awsRegion = 'REPLACE_ME';/var awsRegion = \'${AWS_REGION}\';/" |
        sed "s/var streamingApiEndpoint = 'REPLACE_ME'/var streamingApiEndpoint = \'${streaming_api_endpoint}\'/g" |
        sed "s/var mysfitsApiEndpoint = 'REPLACE_ME';/var mysfitsApiEndpoint = \'${api_endpoint}\';/g"
    )
    local new_register_html=$(cat "${REPO_ROOT}/mythical-mysfits/module-5/web/register.html" |
        sed "s/var cognitoUserPoolId = 'REPLACE_ME';/var cognitoUserPoolId = \'${cognito_user_pool_id}\';/" |
        sed "s/var cognitoUserPoolClientId = 'REPLACE_ME';/var cognitoUserPoolClientId = \'${cognito_user_pool_client_id}\';/"
    )
    local new_confirm_html=$(cat "${REPO_ROOT}/mythical-mysfits/module-5/web/confirm.html" |
        sed "s/var cognitoUserPoolId = 'REPLACE_ME';/var cognitoUserPoolId = \'${cognito_user_pool_id}\';/" |
        sed "s/var cognitoUserPoolClientId = 'REPLACE_ME';/var cognitoUserPoolClientId = \'${cognito_user_pool_client_id}\';/"
    )

    rm -rf "${REPO_ROOT}"/tmp
    mkdir -p "${REPO_ROOT}"/tmp
    cp -r "${REPO_ROOT}"/mythical-mysfits/module-5/web/* "${REPO_ROOT}"/tmp
    echo "${new_index_html}" > "${REPO_ROOT}"/tmp/index.html
    echo "${new_register_html}" > "${REPO_ROOT}"/tmp/register.html
    echo "${new_confirm_html}" > "${REPO_ROOT}"/tmp/confirm.html

    aws s3 cp --recursive \
        "${REPO_ROOT}"/tmp/ \
        s3://"${STATIC_SITE_BUCKET_NAME}"/

    cd "${REPO_ROOT}"
    echo "Cleaning up..."
    rm -rf "${REPO_ROOT}"/tmp
}

######################################################################################
# Module 6
# https://github.com/aws-samples/aws-modern-application-workshop/tree/python/module-6
######################################################################################
export QUESTIONS_SERVICE_CICD_STACK_NAME="MythicalMysfitsQuestionsServiceCICDStack"
export QUESTIONS_SERVICE_CICD_STACK_YML="${REPO_ROOT}"/infra/mythical-mysfits/questions-service-cicd.yml
create_questions_service_cicd() {
    echo "Creating questions service cicd stack..."
    aws cloudformation create-stack \
        --stack-name "${QUESTIONS_SERVICE_CICD_STACK_NAME}" \
        --template-body file://"${QUESTIONS_SERVICE_CICD_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameters ParameterKey=AdministratorEmailAddress,ParameterValue="${DEVELOPER_EMAIL}" \
        --enable-termination-protection
    wait_build "${QUESTIONS_SERVICE_CICD_STACK_NAME}"
}

update_questions_service_cicd() {
    echo "Updating questions service cicd stack..."
    aws cloudformation update-stack \
        --stack-name "${QUESTIONS_SERVICE_CICD_STACK_NAME}" \
        --template-body file://"${QUESTIONS_SERVICE_CICD_STACK_YML}" \
        --parameters ParameterKey=AdministratorEmailAddress,ParameterValue="${DEVELOPER_EMAIL}" \
        --capabilities CAPABILITY_NAMED_IAM
    aws cloudformation wait stack-update-complete --stack-name "${QUESTIONS_SERVICE_CICD_STACK_NAME}"
}

usage() {
    cat <<EOF
Creates the Mythical Mysfits core stack.
Reference: https://github.com/aws-samples/aws-modern-application-workshop/tree/python

Usage: AWS_PROFILE=qa ./bin/mythical-mysfits.sh <arg>
Where arg is:
create-module-1
create-module-2
create-module-3
create-module-4
create-module-5
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
        create_static_site
    elif [[ "${args}" == "create-module-2" ]]; then
        create_core
        create_ecr

        build_docker_image
        push_image_to_ecr

        create_ecs
        create_fargate_service
        echo "Did you create codestar?"
        create_cicd

        echo "There are stateful code updates which are commented out... Uncomment if you need to make these changes for the first time."
        # init_mystical_mysfits_repo
    elif [[ "${args}" == "create-module-3" ]]; then
        create_dynamodb
        write_dynamodb_items

        echo "There are stateful code updates which are commented out... Uncomment if you need to make these changes for the first time."
        # module_3_code_updates
        # module_3_s3_updates
    elif [[ "${args}" == "create-module-4" ]]; then
        create_user_pool

        echo "There are stateful code updates which are commented out... Uncomment if you need to make these changes for the first time."
        # module_4_code_updates
        # module_4_s3_updates
    elif [[ "${args}" == "create-module-5" ]]; then
        create_streaming_service
        echo "There are stateful code updates which are commented out... Uncomment if you need to make these changes for the first time."
        # init_streaming_service_repo
        # package_streaming_lambda
        # deploy_streaming_lambda
        # module_5_static_site_updates
    elif [[ "${args}" == "create-module-6" ]]; then
        create_questions_service_cicd
    elif [[ "${args}" == "create-cicd" ]]; then
        create_cicd
    elif [[ "${args}" == "delete-cicd" ]]; then
        delete_cicd
    elif [[ "${args}" == "create-streaming-service-cicd" ]]; then
        create_streaming_service_cicd
    elif [[ "${args}" == "update-streaming-service-cicd" ]]; then
        update_streaming_service_cicd
    elif [[ "${args}" == "update-questions-service-cicd" ]]; then
        update_questions_service_cicd
    elif [[ "${args}" == "update-core" ]]; then
        update_core
    else
        echo "No command run :("
        usage
    fi

}

main "$@"
