import json
import os
import logging
import boto3
import requests
logger = logging.getLogger()
logger.setLevel(logging.INFO)

import httpbl

# Sends data regarding the denied ip to a discord alert channel
def sendAlertToDiscord(response, ip_address):
    content = 'COGNITO SIGN UP DENIED\n'
    content = content + "IP Address: {}".format(ip_address) + "\n"
    if response['threat_score'] > 0:
        content += 'Threat Score: {}'.format(response['threat_score']) + "\n"
        content += 'Days since last activity: {}'.format(response['days_since_last_activity']) + "\n"
        content += 'Visitor type: {}'.format(', '.join([httpbl.DESCRIPTIONS[t] for t in response['type']]))
    else:
        content += 'Visitor type: WAFBLACKLISTED IP'
    print(content)
    webhook_url = os.environ["DISCORD_DEV_ALERTS_CHANNEL_WEBHOOK"]
    requests.post(webhook_url, data={"content": "```" + content + "```"})

def lambda_handler(event, context):
    print(event)

    # Grab the client's ip from which the request came from
    ip_address = event['request']['clientMetadata']['client_ip']

    # Query the httlbl for details regarding the incoming ip
    # TODO: SET my-key to be your access key from ProjectHoneyPot
    #       https://www.projecthoneypot.org/httpbl_configure.php
    bl = httpbl.HttpBL('my-key')
    response = bl.query(ip_address)

    waf_prefix="waf-apigateway"
    # set client as waf
    client = boto3.client('waf-regional')
    # set Blacklist Ipset
    ipsets = client.list_ip_sets()
    for ipset in ipsets['IPSets']:
        if ipset['Name'] == f"{waf_prefix} - Blacklist Set":
            BlacklistIPSetId = ipset['IPSetId']

    # Place all blacklisted ips into an array
    blacklist_ipset = client.get_ip_set(IPSetId=BlacklistIPSetId)
    blacklist = [x['Value'] for x in blacklist_ipset['IPSet']['IPSetDescriptors']]

    print("BLACKLISTED IPS")
    print(blacklist)

    # Log info about what triggered the lambda
    print("COGNITO PRESIGNUP TRIGGER")
    print('IP Address: {}'.format(ip_address))
    print('Threat Score: {}'.format(response['threat_score']))
    print('Days since last activity: {}'.format(response['days_since_last_activity']))

    # if the ip in httpbl is listed as being threatening or is in the waf blacklist then deny it
    if response['threat_score'] > 0:
        print('Visitor type: {}'.format(', '.join([httpbl.DESCRIPTIONS[t] for t in response['type']])))
        print(event)
        print("DENIED SIGNUP")
        sendAlertToDiscord(response, ip_address)
        raise Exception("Denied signup")
    elif ip_address +"/32" in blacklist:
        print('Visitor type: blacklisted')
        print("DENIED SIGNUP")
        sendAlertToDiscord(response, ip_address)
        raise Exception("Denied signup")
    print("###################################################")
    print(event)

    # If no exceptions were raised, proceed with the signup request
    return event
