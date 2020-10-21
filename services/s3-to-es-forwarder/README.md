This is a lambda that listens for S3 Put events and forwards it to ES.

```
sam build
sam local invoke -e events/s3_put.json

```
