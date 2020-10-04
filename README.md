# COMP9447 Team 4 - 2020T3 - SOAR

The main repo for the SOAR project (COMP9447 Team4)

```
Team 4 (Drupal)
Mentor: Paul Hawkins
Tutor: Chong Yew Chang

Members:
Nathan Driscoll
Justin Ty
Sarah Ailin Liu
Yunsar Jilliani
Keung Lee
Elton Wong
Evangeline Endacott
William Yin
Dallas Yan
```

# Build Statuses

## QA Build Statuses

Service | Status
--- | ---
MythicalMysfitsService | ![](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoidENmREJOQlJOWXljOHFyeDkweEp3dFdEWStCaWx1UXNiaFBES2R0V2xPOElWbk04SW9XY3l1NXdod3J4a0svSnVFbFZGcDBlK3NuZFBLNUpXV3llYmJvPSIsIml2UGFyYW1ldGVyU3BlYyI6InkrWktsZzFvSEtXOGZsZk4iLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
MythicalMysfitsStreamingService | ![](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoidkFvT1p2K0lHTUpMUWlITTJ3NVZWRkhUNmppR3Q2WG1IOW5XaVhOY3BleVVQNE8yaDcvV3ZKTHFYWjJoRG9NdlU5ZUUyeDdsODl0YlNnNE1yYUdsL09VPSIsIml2UGFyYW1ldGVyU3BlYyI6InpTdHJTVllIeFZnbFl3ZjQiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

## Prod Build Statuses

TODO

# User Setup

## AWS SSO

I'll send an email via AWS SSO. Follow the email instructions and add an MFA device.

Our portal can be found in:
https://comp9447-team4.awsapps.com/start

You would need an MFA device to login. Register with Google Authenticator on your phone and scan the QR code.

If you've set it up properly, you would be able to login to the console and see this:

![](doc/img/single-signon.png)

Use the `developer` role for normal use and `billing` to keep track of $.

## AWS CLI V2

Install AWS CLI 2. Version 2 is required for AWS SSO.

https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

## AWS SSO CLI setup

To use the CLI with SSO, see:
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html


Once logged in via SSO, configure your AWS CLI in a terminal:

```sh
aws configure sso
SSO Start URL: https://comp9447-team4.awsapps.com/start
SSO Region: ap-southeast-2

<This will take you to a browser to login via SSO>
<Once logged in, it will then ask you to select qa or prod. Select qa to start with>

CLI default client Region: us-east-1 
  --> THIS IS IMPORTANT! All our development work must be in us-east-1 to get the latest resource features
CLI default output format: json
CLI profile name [CLI profile name [DeveloperAccess-306967644367]]: qa
  --> THIS IS IMPORTANT! Otherwise you might have to type in a very long profile name...
```
![](doc/img/sso-cli-1.png)
![](doc/img/sso-cli-2.png)

To test this, run this command in `qa`:

```
aws s3 ls --profile qa
```

Verify that this is what is in your `~/.aws/config` file.

```
[profile qa]
sso_start_url = https://comp9447-team4.awsapps.com/start
sso_region = ap-southeast-2
sso_account_id = 306967644367
sso_role_name = DeveloperAccess
region = us-east-1
output = json
```

## Having issues with SSO?

Login again
```
aws sso login --profile qa
```

If the above doesn't work, remove the cache and retry.

```
mv ~/.aws/sso ~/.aws/sso.bak
mv ~/.aws/config ~/.aws/config.bak
rm -rf ~/.aws/cli/cache
rm -rf ~/.aws/sso/cache

aws configure sso
# Repeat steps above

# Clean up if successful
rm -rf ~/.aws/sso.bak
rm -f ~/.aws/config.bak
```

# Repo prerequisites

These are written in `bash` which glues together AWS commands. This works best under Linux / MacOS.

This varies by OS but these instructions are for a Debian / Ubuntu based system.
You can also use `brew` for MacOS or Chocolatey for `Windows`.

If you have Windows, it is recommended to use a Virtual Machine instead with Linux for best compatability with bash.

See: https://www.virtualbox.org/


## AWS CLI v2
See https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## Jq
json parsing for API calls

```
sudo apt install jq
```

## Direnv
Setup direnv for environment variables. This is used for substituing environment variables to params.
It's optional, you can just set your environment variables as in `.envrc-demo`.
```
sudo apt install direnv

cp .envrc-demo .envrc
direnv allow

echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# DO NOT COMMIT YOUR .envrc
```

## Docker
https://docs.docker.com/engine/install/ubuntu/

This is required by AWS SAM.

## AWS SAM
Used for deploying lambdas for Mythical Mysfits. We can also use this for our own deployments for the SOAR solution.


https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html

```
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

brew --version

# Install AWS SAM
brew tap aws/tap
brew install aws-sam-cli

sam --version
```


# infra/ 

These contain infrastructure-as-code for comp9447-team4.

## infra/sso/ folder

This folder contains the setup for AWS users that follows the well architected labs. This uses AWS SSO.

**THIS WILL ONLY BE NEEDED TO BE DONE ONCE** on the master root account. (Already provisioned for you).

# Drupal

This will only need to be done **once**. Do not destroy the existing stack.

https://aws.amazon.com/quickstart/architecture/drupal/

Create a key pair with:

```
AWS_PROFILE=qa ./bin/key-pair.sh create
AWS_PROFILE=qa ./bin/key-pair.sh describe
```

Make sure you save it.


Deploy the stack with:

```
AWS_PROFILE=qa ./bin/drupal-stack.sh create
```

## Clean up Drupal stack
DO NOT DESTROY AN EXISTING STACK UNLESS ABSOLUTELY NECESSARY! It has termination protection on.

```
AWS_PROFILE=qa ./bin/key-pair.sh delete
AWS_PROFILE=qa ./bin/drupal-stack.sh delete
```

# Panther

I'm experimenting with Panther to do threat hunting on top of guard duty. 

There is an open source version with Cloudformation templates to deploy.

See:
* https://runpanther.io/
* https://docs.runpanther.io/

Note: The quick start templates are in `us-east-1`.

# AWS Region choice

`us-east-1` was chosen as the main AWS REGION to make it easier to deploy resources. This region is expected to get the latest features.
