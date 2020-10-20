import boto3
import re
import requests
import json
from requests_aws4auth import AWS4Auth

region = 'us-east-1'
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

host = os.environ["ES_DOMAIN"] # the Amazon ES domain, including https://
index = os.environ["ES_INDEX"]
type = 'lambda-type'
url = host + '/' + index + '/' + type
headers = { "Content-Type": "application/json" }
s3 = boto3.client('s3')

def handler(event, context):
    for record in event['Records']:
        # Get the bucket name and key for the new file
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get, read, and split the file into lines
        obj = s3.get_object(Bucket=bucket, Key=key)
        body = obj['Body'].read()
        lines = body.splitlines()

        for line in lines:
            document = json.loads(str(line))
            r = requests.post(url, auth=awsauth, json=document, headers=headers)
