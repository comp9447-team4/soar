# AWS WAF Servie

default AWS template from aws docs

https://docs.aws.amazon.com/solutions/latest/aws-waf-security-automations/deployment.html

# How to run local tests
testing http rate-attacks 

script:
services/WAF/test_script/rate-attacks.sh

Note:
default WAF rate limit is set to 100/5min window
currently setup with access token after login

# How to deploy

```
# deploy endpoint: ALB(APIGateway)
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-api-deploy.toml

# deploy endpoint: Cloufront
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-cloudfront-deploy.toml

```

# How to cleanup

```
# deploy endpoint: ALB(APIGateway)
aws cloudformation delete-stack --stack-name waf-apigateway

# deploy endpoint: Cloufront
aws cloudformation delete-stack --stack-name waf-cloudfront

```
# stack template for deploying the WAF webACL
services/WAF/templates/aws-waf-security-automations.template
# stack template for migrating from WAF classic to AWS WAF2
services/WAF/templates/AWSWAFSecurityAutomationsAPIGateway1602565086135.json

#Lambda kinesis-log-processors.py

```
The lambda parse the kinesis log info for blocked records to Kibana elastic search
And also update the Blacklist IPsets in WAF rule
 
services/WAF/Lambda/kinesis-log-processors.py

```