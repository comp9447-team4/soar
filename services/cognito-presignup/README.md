# Prerequisites 

Requires 

- Python 3.8 to be install 
- virtualenv
- request and httbl python libraries
- A Project Honey Pot access key
- Cognito user pool has been set up for the app
- When signup is called, user ip has been passed in as a part of client metadata



## Installing virtualenv and required libraries

Ensure that you have virtualenv installed

```
pip install virtualenv
```

Once you have virtualenv install perform the following steps to ensure that you have both the httpbl and requests libraries installed.

```
source myvenv/bin/activate
pip install httbl
pip install requests
deactivate
```



## Getting Project Honey Pot Access Key

1. Create an account at https://www.projecthoneypot.org/httpbl_configure.php
2. Grab your access key and replace the 'my-key' string on line 33 in lambda_function.py



## Ensuring Lambda has the user's ip from client metadata inside application

Here is an example of a static webpage for the sample app Mystical Mysfits that passes in the users ip as client metadata (register.html):

https://github.com/comp9447-team4/soar/blob/master/mythical-mysfits/register.html

```html
<!DOCTYPE html>
<html lang="en">
  <!--
    A registration page where users who wish you use Mythical Mysfits can
    register with the email address and a password.  The JavaScript below
    uses the Amazon Cognito JavaScript SDK in order to integrate with the service.
  -->
  <head>
    <title>Register for Mythical Mysfits</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="js/aws-cognito-sdk.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/amazon-cognito-identity-js@4.5.4/dist/amazon-cognito-identity.min.js"></script>
  </head>
  <body style="background-color:#EBEBEB">
    <br>
    <div style="text-align: center">
      <img src="https://www.mythicalmysfits.com/images/mysfits_banner.gif" width="800px" align="center">
    </div>
    <div class="container">
      <h3>Register for Mythical Mysfits!</h3>
      <form id="userDetails" >
        <div class="form-group">
          <label for="email">Email:</label>
          <input type="email" class="form-control" id="email" placeholder="Enter email" name="email">
        </div>
        <div class="form-group">
          <label for="pwd">Password: </label>
          <input type="password" class="form-control" id="pwd" placeholder="Enter password" name="pwd">
        </div>
        <div class="form-group">
          <label for="confirmPwd">Confirm Password:</label>
          <input type="password" class="form-control" id="confirmPwd" placeholder="Confirm password" name="confirmPwd">
        </div>
        <button type="submit" class="btn btn-info">Register</button>
      </form>
    </div>

  </body>

  <script>

  var cognitoUserPoolId = 'us-east-1_LXxSwQ0uB';  // example: 'us-east-1_abcd12345'
  var cognitoUserPoolClientId = '26g55g3ikdltdbba38bq95ge1s'; // example: 'abcd12345abcd12345abcd12345'

  $(document).on('click', '.btn-info', function(event) {
    event.preventDefault();

    var poolData = {
      UserPoolId : cognitoUserPoolId,
      ClientId : cognitoUserPoolClientId
    };
    var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

    var attributeList = [];


    var email = document.getElementById('email').value;
    var pw = document.getElementById('pwd').value;
    var confirmPw = document.getElementById('confirmPwd').value;
    var dataEmail = {
        Name : 'email',
        Value : email
    };

    var attributeEmail = new AmazonCognitoIdentity.CognitoUserAttribute(dataEmail);

    attributeList.push(attributeEmail);

    $.get("https://ipinfo.io", function(response) { 
        var clientMetadata = {
          client_ip: response.ip
        };

        if (pw === confirmPw) {
          userPool.signUp(email, pw, attributeList, null, function(err, result){
              if (err) {
                  alert(err.message);
                  return;
              }
              cognitoUser = result.user;
              console.log(cognitoUser);
              localStorage.setItem('email', email);
              window.location.replace('confirm.html');
          }, clientMetadata);
        } else {
          alert('Passwords do not match.')
        }
      }, "json") 
  });
  </script>
</html>
```

Key things to note:

- Must be using a recent version of amazon-cognito-identity-js

```html
<script src="https://cdn.jsdelivr.net/npm/amazon-cognito-identity-js@4.5.4/dist/amazon-cognito-identity.min.js"></script>
```

- Client's ip MUST be passed in as part of clientMetadata in order for the lambda to get the ip.

# Manual Lambda Deployment

Once you have added your key to the lambda function run 

```
./compile.sh
```

inside of the current directory. This will produce a cognito-presignup.zip file.

Next go into the management console and create a new lambda function named 'CognitoPreSignUp'

![stepone](https://user-images.githubusercontent.com/70885465/100230546-f56c5d00-2f79-11eb-8bac-ae822df102da.PNG)

Under the Function code section, click on the 'actions' dropdown menu and select Upload a .zip file.

You want to upload the zip file which we just created called 'cognito-presignup.zip'.

![steptwo](https://user-images.githubusercontent.com/70885465/100230543-f4d3c680-2f79-11eb-944c-84c4a09119a2.PNG)

![stepthree](https://user-images.githubusercontent.com/70885465/100230542-f4d3c680-2f79-11eb-82ef-0868832725ae.PNG)



Next you can set up the environment variable to have the lambda alert your desired discord channel.

For example:

![step6_1](https://user-images.githubusercontent.com/70885465/100230537-f3a29980-2f79-11eb-9777-78d2ea8addea.PNG)



Next we need to ensure that the permissions are set correctly for the lambda so that it has access to the AWS WAF Blacklist. 

Do this by clicking on the permissions tab inside of the lambda function on the management console. ![stepfour](https://user-images.githubusercontent.com/70885465/100230541-f43b3000-2f79-11eb-9584-d5372c5efb92.PNG)Clicking on the permission assigned to the lambda function and attaching the AWSWAFReadOnlyAccess policy. 

![step5](https://user-images.githubusercontent.com/70885465/100230535-f2716c80-2f79-11eb-8579-9db7d8f9f6c3.PNG)

We can now test the lambda with the following event, remembering to replace userName with the username of a valid developer:

```json
{
  "version": "1",
  "region": "us-east-1",
  "userPoolId": "us-east-1_LXxSwQ0uB",
  "userName": "sliu.ailin8801@gmail.com",
  "callerContext": {
    "awsSdkVersion": "aws-sdk-unknown-unknown",
    "clientId": "26g55g3ikdltdbba38bq95ge1s"
  },
  "triggerSource": "PreSignUp_SignUp",
  "request": {
    "userAttributes": {
      "email": "mail@gmail.com"
    },
    "validationData": null,
    "clientMetadata": {
      "client_ip": "195.154.63.218"
    }
  },
  "response": {
    "autoConfirmUser": false,
    "autoVerifyEmail": false,
    "autoVerifyPhone": false
  }
}
```

This should result in an exception being raised stating that the signup has been denied and this should have alerted the discord channel. 

Next we have to link the lambda to cognito so that it is triggered at presignup. 

Navigate to cognito and the appropriate user pool inside of the management console.

Click on the triggers section on the side left hand menu and assigned the lambda we just created to be triggered at presignup. 

![step7](https://user-images.githubusercontent.com/70885465/100230549-f56c5d00-2f79-11eb-977d-c2aedeb91047.PNG)

# Lambda Deployment with aws sam

Run 

```
sam deploy --guided
```

Go into the management console and navigate to the lambda that was just created. 

Next we need to ensure that the permissions are set correctly for the lambda so that it has access to the AWS WAF Blacklist. 

Do this by clicking on the permissions tab inside of the lambda function on the management console. Clicking on the permission assigned to the lambda function and attaching the AWSWAFReadOnlyAccess policy. ![stepfour](https://user-images.githubusercontent.com/70885465/100230541-f43b3000-2f79-11eb-9584-d5372c5efb92.PNG)

![step5](https://user-images.githubusercontent.com/70885465/100230535-f2716c80-2f79-11eb-8579-9db7d8f9f6c3.PNG)

We can now test the lambda with the following event, remembering to replace userName with the username of a valid developer:

```json
{
  "version": "1",
  "region": "us-east-1",
  "userPoolId": "us-east-1_LXxSwQ0uB",
  "userName": "sliu.ailin8801@gmail.com",
  "callerContext": {
    "awsSdkVersion": "aws-sdk-unknown-unknown",
    "clientId": "26g55g3ikdltdbba38bq95ge1s"
  },
  "triggerSource": "PreSignUp_SignUp",
  "request": {
    "userAttributes": {
      "email": "mail@gmail.com"
    },
    "validationData": null,
    "clientMetadata": {
      "client_ip": "195.154.63.218"
    }
  },
  "response": {
    "autoConfirmUser": false,
    "autoVerifyEmail": false,
    "autoVerifyPhone": false
  }
}
```

This should result in an exception being raised stating that the signup has been denied and this should have alerted the discord channel (in this case it will default to alerting Team4's dev alerts channel). 

Next we have to link the lambda to cognito so that it is triggered at presignup. 

Navigate to cognito and the appropriate user pool inside of the management console.

Click on the triggers section on the side left hand menu and assigned the lambda we just created to be triggered at presignup. 

![step7](https://user-images.githubusercontent.com/70885465/100230549-f56c5d00-2f79-11eb-977d-c2aedeb91047.PNG)



Note by deploying this way, all alerts will go to the Team 4's dev alerts channel, to change the discord channel that all alerts will be forwarded to, change the webhook provided in template.yaml to your desired location.  

For example:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: 'AWS::Serverless-2016-10-31'
Description: An AWS Serverless Specification template describing your function.
Resources:
  cognitoPreSignUpTest:
    Type: 'AWS::Serverless::Function'
    Properties:
      Handler: lambda_function.lambda_handler
      Runtime: python3.8
      CodeUri: cognitoPreSignUpTest-ca6f9264-22c4-4134-a69a-aafbb5ba31dd.zip
      Description: ''
      MemorySize: 128
      Timeout: 3
      Role: >-
        arn:aws:iam::306967644367:role/service-role/cognitoPreSignUpTest-role-dwadtl1b
      Environment:
        Variables:
          DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK: >-
            REPLACE WITH YOUR DISCORD CHANNEL WEBOOK
```



