import json
import os
import logging
import boto3
import requests
logger = logging.getLogger()
logger.setLevel(logging.INFO)

import httpbl

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
    # logger.info('## ENVIRONMENT VARIABLES')
    # logger.info(os.environ)
    # logger.info('## EVENT')
    # logger.info(event)
    # logger.info(event.request)
    print(event)
    ip_address = event['request']['clientMetadata']['client_ip']

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

    blacklist_ipset = client.get_ip_set(IPSetId=BlacklistIPSetId)
    blacklist = [x['Value'] for x in blacklist_ipset['IPSet']['IPSetDescriptors']]
    blacklist.append("27.32.194.700")
    print("BLACKLISTED IPS")
    print(blacklist)

    print("COGNITO PRESIGNUP TRIGGER")
    print('IP Address: {}'.format(ip_address))
    print('Threat Score: {}'.format(response['threat_score']))
    print('Days since last activity: {}'.format(response['days_since_last_activity']))
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
    return event
