# AWS WAF Setup

## Setting up of WAF WebACL and Rules
The first part of the WAF setup is to deploy the cloudformation template which will create WebACL and IP sets for CloudFront or ALB endpoints for our application. The setup follows the AWS  solutions https://aws.amazon.com/solutions/implementations/aws-waf-security-automations/
Considering the scope and time, for our soar solution we will be setting up rules such as Rate based, SQLI, XSS and whitelisted and Blacklisted IPsets.

Can be further extended to the full solution above if need be.



## How to deploy
This can be deployed manually using AWS SAM or as part of the CI/CD stack. 
### soar-stack deployment

```
cd bin/
AWS_PROFILE="qa"
./soar-stack.sh create-waf-stack

At the prompt enter 1 to continue or 2 to skip deploying to ALB endpoint
It will use the sam deploy command to deploy the cloudformation template
# deploy endpoint: ALB(APIGateway)
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-api-deploy.toml


At the next prompt enter 1 to continue or 2 to skip deploying to CloudFront endpoint
It will use the sam deploy command to deploy the cloudformation template
# deploy endpoint: Cloufront
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-cloudfront-deploy.toml
```
### Sam Deployment
```
# deploy endpoint: ALB(APIGateway)
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-api-deploy.toml

# deploy endpoint: Cloufront
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-cloudfront-deploy.toml
```
## Lambda kinesis-log-processors.py

```
The lambda parse the kinesis log info for blocked records to Kibana elastic search
And also update the Blacklist IPsets in WAF rule
 
services/WAF/Lambda/kinesis-log-processors.py

```

## How to cleanup
Detach associations and run cloudformation delete from console or from CLI

CLI commands
```
# deploy endpoint: ALB(APIGateway)
aws cloudformation delete-stack --stack-name waf-apigateway

# deploy endpoint: Cloufront
aws cloudformation delete-stack --stack-name waf-cloudfront

```
## Miscellaneous
### stack template for deploying the WAF webACL

```
services/WAF/templates/aws-waf-security-automations.template

```
### stack template for migrating from WAF classic to AWS WAF2

```
services/WAF/templates/AWSWAFSecurityAutomationsAPIGateway1602565086135.json

```


## How to run local tests
Please refer to https://github.com/comp9447-team4/soar/blob/master/services/WAF/test_script/README.MD
