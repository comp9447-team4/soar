import json
import boto3
import os
import requests


def lambda_handler(event, context):
    """
    Send an alert of the AWS Macie findings to Discord
    """

    client = boto3.client('macie2')
    finding_ids = client.list_findings()
    for finding in finding_ids.findingsIds:
        macie_findings = client.get_findings(finding)
        

    is_dev=os.envrion["IS_DEV"]
    if is_dev == "1":
        webhook_url = os.environ["DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK"]
    else:
        webhook_url = os.environ["DISCORD_ALERTS_CHANNEL_WEBHOOK"]

    # Below is the response that will be sent to Discord
    content="""<insert the content here"""

    response = requests.post(webhook_url, data={"content": content})
    return response
