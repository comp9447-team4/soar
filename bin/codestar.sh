#!/bin/bash

set -e
set -u

source "${REPO_ROOT}"/bin/_utils.sh
export CODESTAR_STACK_NAME="GithubRepoCodeStarStack"
export CODESTAR_STACK_YML="${REPO_ROOT}"/infra/codestar.yml

create_codestar_connection() {
    aws cloudformation create-stack \
        --stack-name "${CODESTAR_STACK_NAME}" \
        --template-body file://"${CODESTAR_STACK_YML}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --enable-termination-protection
    aws cloudformation wait stack-create-complete "${CODESTAR_STACK_NAME}"
    echo "Now go to CodePipeline -> Settings -> Connections -> Update Pending connection -> Enable Github Oauth"
}

main() {
    create_codestar_connection
}

main
