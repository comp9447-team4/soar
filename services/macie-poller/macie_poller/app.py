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

    # Creating lists to store the different classifications of findings
    high = []
    high.append("High: ")
    medium = []
    medium.append("Medium: ")
    low = []
    low.append("Low: ")
    other = []
    other.append("Other: ")

    # Creating a list that will be sent to Discord
    macie_response = []

    print("Hello")
    # Goes through the findings and classfies findings based on severity
    for finding in finding_ids.findingsIds:
        macie_finding = client.get_findings(finding)
        if (macie_finding.severity.description == "High"):
            high.append("Id: ")
            high.append(macie_finding.id)
            high.append("Location: ")
            high.append(macie_finding.resourceAffected.s3Bucket.arn)
        elif (macie_finding.severity.description == "Medium"):
            medium.append("Id: ")
            medium.append(macie_finding.id)
            medium.append("Location: ")
            medium.append(macie_finding.resourceAffected.s3Bucket.arn)
        elif (macie_finding.severity.description == "Low"):
            low.append("Id: ")
            low.append(macie_finding.id)
            low.append("Location: ")
            low.append(macie_finding.resourceAffected.s3Bucket.arn)
        else: 
            other.append("Id: ")
            other.append(macie_finding.id)
            other.append("Location: ")
            other.append(macie_finding.resourceAffected.s3Bucket.arn)

    is_dev=os.envrion["IS_DEV"]
    if is_dev == "1":
        webhook_url = os.environ["DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK"]
    else:
        webhook_url = os.environ["DISCORD_ALERTS_CHANNEL_WEBHOOK"]
    print("There")
    # Combine together the different types based on the findings
    macie_response.extend(high)
    macie_response.extend(medium)
    macie_response.extend(low)
    macie_response.extend(other)

    # Below is the response that will be sent to Discord
    content=f"{macie_response}"

    response = requests.post(webhook_url, data={"content": content})
    return response
