# AWS WAF Setup

* ## Setting up of WAF WebACL and Rules
The first part of the WAF setup is to deploy the cloudformation template which will create WebACL and IP sets for CloudFront or ALB endpoints for our application. The setup follows the AWS  solutions https://aws.amazon.com/solutions/implementations/aws-waf-security-automations/
Considering the scope and time, for our soar solution we will be setting up rules such as Rate based, SQLI, XSS and whitelisted and Blacklisted IPsets.

Can be further extended to the full solution above if need be.
<img src="https://d1.awsstatic.com/Solutions/Solutions%20Category%20Template%20Draft/Solution%20Architecture%20Diagrams/waf-security-automations-architecture.520fa104475cd846b62df3b2027a64094dfad31a.png" width="80%">

### How to deploy
This can be deployed manually using AWS SAM or as part of the CI/CD stack. 
##### soar-stack deployment

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
##### Sam Deployment
```
# deploy endpoint: ALB(APIGateway)
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-api-deploy.toml

# deploy endpoint: Cloufront
sam deploy -t aws-waf-security-automations.template --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --config-file waf-cloudfront-deploy.toml
```

Once deployed you can see the following rules setup under the WebACL.

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_rules.png" width="80%">

* ## Add Association
Once you have deployed the WebACL and corresponding rules and IP sets, we should associate the API’s or CloudFront resources to them. Under Rules we can see an option to add associations. For CloudFront the region must be global and for ALB’s it must be the deployed regions e.g.: “us-east-1”.

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_association_api.png" width="80%">
 
Once this is done WAF will start to take actions on the incoming traffic, by default it is set to allowed but incase if a rule blocks an IP it will be temporarily blocked for a period of 240 mins.

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_sample_request.jpg" width="80%">


* ## Enabling logging
WAF has the option to enable  continuous logging and monitoring using a kinesis firehose data stream. Make sure the Kinesis log stream starts with “aws-waf-logs-“, e.g.: aws-waf-logs-firehose We will need to enable logging for each of the WebACL we setup. By default, the kinesis logs are sent to an S3 bucket.

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_logging.jpg" width="80%">

We can setup Lambda functions if we need to process these logs and can send those logs to other destinations.

![](https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_kinesis_streams.jpg)

In addition to this the lambda function also pass on any stdout to cloudwatch logs. You can see the log stream here /aws/lambda/kinesis-log-processors.

![](https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_lambda_cloudwatch_logs.jpg)


* ## Parse logs to elastic search using lambda
As discussed above a lambda function e.g.: kinesis-log-processors is setup to send processed logs to specified destinations. We have already setup Elastic search with Kibana frontend on our AWS console. We are using the same setup to send our logs for monitoring needs. The lambda function filters out and sends the blocked traffic logs to our ES. The index for the same is setup in Elastic search as “waf-kinesis-logs” where below information for blocked IP is passed.

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_es_index.jpg" width="50%">

* ## Threat analysis and automated updation of WAF rules and IP sets using Lambda
An integral part of the WAF is to minimize the human workload when external threat occurs. WAF to an extent handles this. But at the same time, we need to ensure a proper threat analysis can be done and block such malicious sources from further attempting to break into the system. This is where we use Blacklisted IP sets, where the rule blocks any IP’s listed in it.

![](https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_threat_analysis.jpg)


Whenever an IP is blocked by any rule, the WAF puts a temporary block, we want the IP to be moved into a permanent Blacklist if multiple attempts happen. We ensure this by a Lambda Function update_ipset(clientIp). The function which is part of : kinesis-log-processors update the Blacklisted IP set whenever the client IP is blocked by WAF, although current setup takes action on the first attempt itself.
```
services/WAF/Lambda/kinesis-log-processors.py
```

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_lambda_update_ipset.jpg" width="50%">

Apart from setting up the Lambda we must change the permissions in IAM so that the Lambda can read and update the WAF rules and IP sets. This is done by attaching AWSWAFFullAccess policy to the function in IAM.

![](https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_lambda_IAM.jpg)

* ##  Monitoring for threats and alerting stakeholders
Whenever a security threat arises, WAF blocks the threat but at the same time it is important to have the incident alerted to security engineers or other concerned stakeholders. The Kibana ES offers this solution by setting up monitors on the index of our logs from WAF. As you can see, we have setup monitors which will capture information if there are any such events.

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_kibana_monitors.jpg" width="50%">

Each of these monitors are set up to alert the concerned person, in our case our team discord channel. This is done by  AWS SNS and target the notification towards Discord channel.

<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_kibana_alerts.jpg" width="50%">


Below image is a sample alert sent to the discord channel when a source attempted a rate based attack. We can see the clientIP, the rule based on which IP is blocked , source country as well as the timestamp of the event in the alert.
<img src="https://github.com/comp9447-team4/soar/blob/master/doc/img/waf_discord_alert.jpg" width="50%">


* ## How to cleanup
Detach associations and run cloudformation delete from console or from CLI.

CLI commands
```
# deploy endpoint: ALB(APIGateway)
aws cloudformation delete-stack --stack-name waf-apigateway

# deploy endpoint: Cloufront
aws cloudformation delete-stack --stack-name waf-cloudfront

```
Once above step is complete we can delete the kinesis streams and the Lambda functions setup for logging and threat analysis.

* ## How to run local tests
Please refer to https://github.com/comp9447-team4/soar/blob/master/services/WAF/test_script/README.MD

## Miscellaneous
### stack template for deploying the WAF webACL

```
services/WAF/templates/aws-waf-security-automations.template

```
### stack template for migrating from WAF classic to AWS WAF2

```
services/WAF/templates/AWSWAFSecurityAutomationsAPIGateway1602565086135.json

```
