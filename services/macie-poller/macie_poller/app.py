import json
import boto3
import os
import requests


def lambda_handler(event, context):
    """
    What does this lambda do?
    """

    # client = boto3.client('macie')
    # finding_ids = client.list_findings()
    # for i in finding_ids:
    # some_json = client.get_findings(id)


    if is_dev == "1":
        webhook_url = os.environ["DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK"]
    else:
        webhook_url = os.environ["DISCORD_ALERTS_CHANNEL_WEBHOOK"]

    # return requests.post(webhook_url, content)
