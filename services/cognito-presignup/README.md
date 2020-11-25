# Prerequisites 

Requires 

- Python 3.8 to be install 
- virtualenv
- request and httbl python libraries
- A Project Honey Pot access key



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



# Lambda Deployment

Once you have added your key to the lambda function run 

```
./compile.sh
```

inside of the current directory. This will produce a cognito-presignup.zip file.

Now run 

```
sam deploy --guided
```

Followed by 





