import json
import boto3
import os
# import requests


def lambda_handler(event, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """

    # try:
    #     ip = requests.get("http://checkip.amazonaws.com/")
    # except requests.RequestException as e:
    #     # Send some context about this error to Lambda Logs
    #     print(e)

    #     raise e

    # client = boto3.client('macie')
    # finding_ids = client.list_findings()
    # for i in finding_ids:
    # some_json = client.get_findings(id)


    if is_dev == "1":
        webhook_url = os.environ["DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK"]
    else:
        webhook_url = os.environ["DISCORD_ALERTS_CHANNEL_WEBHOOK"]

    # return requests.post(webhook_url, content)
