import json
import logging
import os
import requests

# Setup logging
# https://docs.aws.amazon.com/lambda/latest/dg/python-logging.html#python-logging-lib
logger = logging.getLogger()
logger.setLevel(logging.INFO)

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
    """

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

    content = f"{message}. I am the CodePipeline bot. :robot:"
    response = requests.post(webhook_url, data={"content": content})
    return 0
