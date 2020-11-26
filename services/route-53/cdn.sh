#Replacable variables
export AWS_ENVIRONMENT="qa"
export AWS_DEFAULT_REGION=us-east-1
export CDN_NAME="${AWS_ENVIRONMENT}-CloudFront-Stack"
export CDN_TEMPLATE_YML="./cdn.yml"
export Cert_ARN="Insert your certificate ARN here"
export My_domain="Insert your domain name here"
export Bucket_name="Insert bucket name here"

echo "Creating CDN..."
aws cloudformation create-stack \
    --stack-name "${CDN_NAME}" \
    --region us-east-1 \
    --template-body file://"${CDN_TEMPLATE_YML}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey="DomainName",ParameterValue="${My_domain}"\
     ParameterKey="CertificateArn",ParameterValue="${Cert_ARN}"\
     ParameterKey="BucketName",ParameterValue="${Bucket_name}"\
     ParameterKey="S3Region",ParameterValue="${AWS_DEFAULT_REGION}"
