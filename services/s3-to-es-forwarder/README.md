This is a lambda that listens for S3 Put events and forwards it to ES.


## Local test
```
sam build
sam local invoke -e events/s3_put.json
```

## Deploy to QA

This is a manual deployment to QA. 
```
sam build
AWS_PROFILE=qa sam deploy --config-env qa
```

Releases to prod must be done via CI
