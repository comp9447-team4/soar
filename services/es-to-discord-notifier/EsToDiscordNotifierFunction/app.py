import json
import logging
import os
import requests

# Setup logging
# https://docs.aws.amazon.com/lambda/latest/dg/python-logging.html#python-logging-lib
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    AWS_ENVIRONMENT = os.environ["AWS_ENVIRONMENT"]
    webhook_url = ""
    if AWS_ENVIRONMENT == "qa":
        webhook_url = os.environ["DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK"]
    elif AWS_ENVIRONMENT == "prod":
        webhook_url = os.environ["DISCORD_ALERTS_CHANNEL_WEBHOOK"]
    else:
        raise ValueError(f"Unknown AWS_ENVIRONMENT: {AWS_ENVIRONMENT}. Must be qa or prod.")

    message = event['Records'][0]['Sns']['Message']
    logger.info(f"Got a message: {message}")

    content = f"```{message}```"
    response = requests.post(webhook_url, data={"content": content})
    return 0
