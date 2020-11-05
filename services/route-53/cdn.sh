#hardcode the local dev account for test
export AWS_ENVIRONMENT="qa"
export AWS_DEFAULT_REGION=us-east-1
export CDN_NAME="${AWS_ENVIRONMENT}-CloudFront-Stack"
export CDN_TEMPLATE_YML="./cdn.yml"


echo "Creating cdn..."
aws cloudformation create-stack \
    --stack-name "${CDN_NAME}" \
    --region us-east-1 \
    --template-body file://"${CDN_TEMPLATE_YML}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey="DomainName",ParameterValue="9447.me"\
     ParameterKey="CertificateArn",ParameterValue="arn:aws:acm:us-east-1:306967644367:certificate/80c8b98e-ce6f-49a7-908c-86131e18fb30"\
     ParameterKey="BucketName",ParameterValue="qa-comp9447-team4-mythical-mysfits"\
     ParameterKey="S3Hosting",ParameterValue="qa-comp9447-team4-mythical-mysfits.s3-website-us-east-1.amazonaws.com"\
     ParameterKey="S3Region",ParameterValue="us-east-1"
