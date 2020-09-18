# COMP9447 Team 4 - 2020T3

TODO
Members:


# Setup

## AWS IAM User

Your username has been provisioned for you but you would still need to generate your own ACCESS KEYS and console passwords.

Steps:
* Go to AWS Console https://comp9447-team4-qa.signin.aws.amazon.com/console (I'll provide a password via Discord)
* Generate a new password on login and keep it safe
* Go to AWS IAM -> Users -> Find your user
* Generate Access Keys and save it in your `~/.aws/credentials`
* Download Google Authenticator on your phone.
* Enabled MFA and copy the ARN to `~/.aws/credentials` as `mfa_serial`. (See example below)

![](doc/img/user-setup.png)

Note you will **not** be able to call commands if you do not have MFA enabled. This is part of a well architected framework.

## AWS CLI

Copy this template to your `~/.aws/cli`

```
[qa-user]
aws_access_key_id = <SECRET>
aws_secret_access_key = <SECRET>

[qa]
source_profile = qa-user
region = ap-southeast-2
role_arn = arn:aws:iam::306967644367:role/qa-RestrictedAdmin
mfa_serial = arn:aws:iam::306967644367:mfa/<YOUR_USERNAME>
```

# infra/ 

These contain infrastructure-as-code for comp9447-team4.

## infra/users/ folder

`infra/users/` contains the setup for AWS users that follows the well architected labs.

**THIS WILL ONLY BE NEEDED TO BE DONE ONCE** (Already provisioned for you).


# More to come
