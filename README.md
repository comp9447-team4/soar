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

# User Setup

## AWS CLI

Install AWS CLI 2. Version 2 is required for AWS SSO.

https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

## AWS SSO

I'll send an email via AWS SSO. Follow the email instructions and add an MFA device.

Our portal is in:
https://comp9447-team4.awsapps.com/start

You would need an MFA device to login. Register with Google Authenticator on your phone and scan the QR code.

To use the CLI with SSO, see:
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

Once logged in via SSO, configure your AWS CLI in a terminal:

```
aws configure sso
SSO Start URL: https://comp9447-team4.awsapps.com/start
SSO Region: ap-southeast-2
CLI default client Region: ap-southeast-2
CLI default output format: json
CLI profile name: qa (or) prod --> THIS IS IMPORTANT! Otherwise you might have to type in a very long profile name...
```

To test this, run this command in `qa`:

```
aws sts get-caller-identity --profile qa
```

# Setup prerequisites

These are written in `bash` which glues together AWS commands. This works best under Linux / MacOS.

This varies by OS but these instructions are for a Debian / Ubuntu based system.
You can also use `brew` for MacOS or Chocolatey for `Windows`.

## Jq
json parsing for API calls

```
sudo apt install direnv jq
```

## Direnv
Setup direnv for environment variables. This is used for substituing environment variables to params.
It's optional, you can just set your environment variables as in `.envrc-demo`.
```
cp .envrc-demo .envrc
direnv allow

echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```


# infra/ 

These contain infrastructure-as-code for comp9447-team4.

## infra/users/ folder

`infra/users/` contains the setup for AWS users that follows the well architected labs.

**THIS WILL ONLY BE NEEDED TO BE DONE ONCE** (Already provisioned for you).

