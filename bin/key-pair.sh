#!/bin/bash
# Use this for wrapper for managing keypairs

set -eu

export REPO_ROOT=$(git rev-parse --show-toplevel)
source "${REPO_ROOT}"/bin/_utils.sh

# Drupal keypair is in US
export AWS_REGION="us-east-1"

create() {
    local key
    key=$(aws ec2 create-key-pair --key-name drupal | jq -r ".KeyMaterial")
    echo "${key}" > ~/.ssh/drupal.pem
    chmod 400 ~/.ssh/drupal.pem
    echo "Keypair saved in ~/.ssh/drupal.pem"

    echo "Saving in Secrets Manager.."
    aws secretsmanager create-secret \
        --name "drupal-keypair" \
        --secret-string "${key}"
}

# Uncomment if you are sure
# delete() {
#     aws ec2 delete-key-pair --key-name drupal
#     rm -f ~/.ssh/drupal.pem
#
#     echo "Deleting in Secrets Manager.."
#     echo "Keypair deleted in ~/.ssh/drupal.pem"
#     aws secretsmanager delete-secret \
#         --secret-id "drupal-keypair" \
#         --force-delete-without-recovery
# }

describe() {
    aws ec2 describe-key-pairs
}

usage() {
    cat <<EOF
Manages a keypair for drupal-quick-start. This only needs to be done once.
Do not modify the existing stack!

Usage: ./bin/key-pair.sh <arg>
Where arg is:
create                - creates the keypair and saves it in ~/.ssh/drupal.pem
delete                - deletes the keypair in AWS and in ~/.ssh/drupal.pem
describe              - describes the keypair in AWS
EOF
}

main() {
    args="$@"
    check_environment
    if [ $args == "create" ]; then
        create
    elif [ "$args" == "delete" ]; then
        delete
    elif [ "$args" == "describe" ]; then
        describe
    else
        usage
    fi
}

main "$@"
