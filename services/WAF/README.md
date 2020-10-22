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
!!!!Note: need to test the below!!!!
```
# Build
sam build

# Try to invoke it
sam local invoke

# Deploy
sam deploy
```
# stack template for deploying the WAF webACL
services/WAF/templates/aws-waf-security-automations.template
# stack template for migrating from WAF classic to AWS WAF2
services/WAF/templates/AWSWAFSecurityAutomationsAPIGateway1602565086135.json