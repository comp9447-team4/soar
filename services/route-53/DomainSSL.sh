#Variables
export AWS_ENVIRONMENT="qa"
export AWS_DEFAULT_REGION=us-east-1
export Route53_NAME="${AWS_ENVIRONMENT}-53-SSL-Stack"
export Route_Config_YML="./ssl.yml"
export My_domain="Insert your domain"

echo "Creating route 53 host zone..."
aws cloudformation create-stack \
    --stack-name "${Route53_NAME}" \
    --region "${AWS_DEFAULT_REGION}" \
    --template-body file://"${Route_Config_YML}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey="DomainName",ParameterValue="${My_domain}"\
     ParameterKey="HostedZoneId",ParameterValue="Z0356916NZWKOARDXAL1"

