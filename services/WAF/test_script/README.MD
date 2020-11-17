### Testing process

### Prequisites
Install the prerequisites below using either `brew` or `apt`:

- Python3 
- Pip3
- Git


### Rate base attacks

**Note**: You may use the following terminal command to check your public ip `dig +short myip.opendns.com @resolver1.opendns.com`. You may need to install dig.


Steps:
1. Browse to https://qa.9447.me and open up the inspect tool on chrome.

2. Click on one of the misfit, under the network tab copy the api get request url. It show look something like this:
  ```
    https://6jztqidvd6.execute-api.us-east-1.amazonaws.com/qa/mysfits/b6d16e02-6aeb-413c-b457-321151bb403d
  ```
3. Open up http_rate_attack.py with your favorite text editor and replace:
```
  http_attack('https://6jztqidvd6.execute-api.us-east-1.amazonaws.com/qa/mysfits/b6d16e02-6aeb-413c-b457-321151bb403d', 200)
  #with
  http_attack('your_url', rate_per_second)
```
4. Under Waf Classic (waf-api) > condition > ip addresses in the AWS, your public ip show appear in the black list.

### SQL Injection

Steps:
1. Download sql map from the following repo:
  ```bash
  git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
  ```
2. Browse to https://qa.9447.me and open up the inspect tool on chrome.

3. Click on one of the misfit, under the network tab copy the api get request url. It show look something like this:
  ```
    https://6jztqidvd6.execute-api.us-east-1.amazonaws.com/qa/mysfits/b6d16e02-6aeb-413c-b457-321151bb403d
  ```
4. Go to the sqlmap repo and run the following commands to launch the attack:
  ```bash
    python3 sqlmap.py -u "https://6jztqidvd6.execute-api.us-east-1.amazonaws.com/qa/mysfits/b6d16e02-6aeb-413c-b457-321151bb403d" --batch -banner
  ```
5. Head over to the AWS management console > waf > waf classic, and under conditions > ip addresses > black list. Your public IP should be blocked.

