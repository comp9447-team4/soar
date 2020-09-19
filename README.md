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

# Setup

These are written in `bash` which glues together AWS commands. This works best under Linux / MacOS.

If you are on Windows, Cygwin / WSL may work but it may not be as smooth.

* https://docs.microsoft.com/en-us/windows/wsl/install-win10
* https://www.cygwin.com/


# Setup prerequisites

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
## AWS SSO

I'll send an email via AWS SSO.

## AWS CLI

Copy this template to your `~/.aws/cli`

```
[qa-user]
aws_access_key_id = <SECRET>
aws_secret_access_key = <SECRET>

[qa]
source_profile = qa-user
region = ap-southeast-2
<<<<<<< HEAD
role_arn = arn:aws:iam::306967644367:role/qa-RestrictedAdmin
=======
role_arn = arn:aws:iam::306967644367:role/qa-project-member
>>>>>>> 14502ca4328dcf2378f202ed288e405f0120aa65
mfa_serial = arn:aws:iam::306967644367:mfa/<YOUR_USERNAME>
```

# infra/ 

These contain infrastructure-as-code for comp9447-team4.

## infra/users/ folder

`infra/users/` contains the setup for AWS users that follows the well architected labs.

**THIS WILL ONLY BE NEEDED TO BE DONE ONCE** (Already provisioned for you).


<<<<<<< HEAD
# More to come
=======
# Branching (TODO)

* Checkout new branches from `dev` and submit new PRs onto `dev`.
* When we are satisfied with the `dev` branch, submit a PR to `master`
* Checkout a release branch off `master` (todo)
