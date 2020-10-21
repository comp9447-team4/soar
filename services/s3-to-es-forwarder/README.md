This is a lambda that listens for S3 Put events and forwards it to ES.


## Local test
```
make build
sam local invoke -e events/s3_put.json
```

## Deploy to QA

This is a manual deployment to QA. 
```
make deploy_qa
```

Releases to prod must be done via CI
