#!/bin/bash
# Deploys admin resources such as users, roles

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)

deploy_users() {
    echo "Deploying on ${AWS_PROFILE}..."
    local parameters
    parameters=$(cat "${REPO_ROOT}"/users/users-parameters.json |
                     sed "s/{{ AWS_ENVIRONMENT }}/${AWS_PROFILE}/g" |
                     jq
              )
    echo "${parameters}"
    aws cloudformation create-stack --stack-name users \
        --template-body file://"${REPO_ROOT}"/users/users.yml \
        --parameters "${parameters}" \
        --capabilities CAPABILITY_NAMED_IAM

}

main() {
    deploy_users
}

main "$@"
