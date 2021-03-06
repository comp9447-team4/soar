import os
import requests


def lambda_handler(event, context):
    """
    I will send alert to discord channel!
    """
    print(context)
    is_dev = os.environ["IS_DEV"]
    if is_dev == "1":
        webhook_url = os.environ["DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK"]
    else:
        webhook_url = os.environ["DISCORD_ALERTS_CHANNEL_WEBHOOK"]
    content=""":robot: :wave: @here please send your daily standup updates!
    * What did you do yesterday?
    * What will you do today?
    * Any blockers?"
    """
    response = requests.post(webhook_url, data={"content": content})
    return response