import boto3
import re
import io
import requests
import json
import gzip
from requests_aws4auth import AWS4Auth
import os
import datetime


def lambda_handler(event, context):
    region = os.environ["AWS_REGION"]
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

    host = f"https://{os.environ['ES_DOMAIN']}" # the Amazon ES domain, including https://
    index = f"{os.environ['ES_INDEX']}_{datetime.utcnow().strftime('%Y%m%d')}"
    type = 'lambda-type'
    url = host + '/' + index + '/' + type
    headers = { "Content-Type": "application/json" }
    s3 = boto3.client('s3')


    for record in event['Records']:
        # Get the bucket name and key for the new file
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get, read, and split the file into lines
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read()
        with gzip.GzipFile(fileobj=io.BytesIO(content), mode='rb') as fh:
            file_content = fh.read().decode('utf-8')
            lines = file_content.splitlines()
            for line in lines:
                document = json.loads(str(line))
                r = requests.post(url, auth=awsauth, json=document, headers=headers)
                last_req = r.json()

            return(last_req)
