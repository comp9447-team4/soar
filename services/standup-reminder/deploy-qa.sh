#!/bin/bash
# A convenience script for deploying locally.
# This is not for the CI.

main() {
    AWS_PROFILE=qa \
        sam build \
        --config-env qa

    AWS_PROFILE=qa \
        sam deploy \
        --config-env qa
}

main
