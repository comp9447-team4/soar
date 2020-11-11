import base64
import boto3
import json
from datetime import datetime

waf_prefix="waf-apigateway"
# set client as waf
client = boto3.client('waf-regional')
# set Blacklist Ipset
response = client.list_ip_sets()
for ipset in response['IPSets']:
    if ipset['Name'] == f"{waf_prefix} - Blacklist Set":
        BlacklistIPSetId = ipset['IPSetId']
# set blacklist rule ID
response = client.list_rules()
for rule in response['Rules']:
    if rule['Name'] == f"{waf_prefix} - Blacklist Rule":
        BlacklistRuleId = rule['RuleId']


def update_ipset(clientIp):
    clientIp = clientIp + "/32"
    ChangeToken = client.get_change_token()['ChangeToken']
    response = client.update_ip_set(
        IPSetId=BlacklistIPSetId,
        ChangeToken=ChangeToken,
        Updates=[
            {
                'Action': 'INSERT',
                'IPSetDescriptor': {
                    'Type': 'IPV4',
                    'Value': clientIp
                }
            },
        ]
    )
    print(response)


# Incoming Event
def lambda_handler(event, context):
    output = []
    now = datetime.utcnow().isoformat()

    # Loop through records in incoming Event
    for record in event['records']:
        # Extract message
        data = base64.b64decode(record['data']).decode("utf-8")
        message = json.loads(data)

        if message['terminatingRuleType'] == "REGULAR":
            response = client.get_rule(RuleId=message['terminatingRuleId'])
            rule = response['Rule']['Predicates'][0]['Type']
        else:
            rule = message['terminatingRuleType']

        if message['action'] == "BLOCK" and message['terminatingRuleId'] != BlacklistRuleId:
            # Construct output
            data_field = {
                'timestamp': now,
                'action': message['action'],
                'terminatingRuleType': rule,
                'clientIp': message['httpRequest']['clientIp'],
                'country': message['httpRequest']['country'],
                'uri': message['httpRequest']['uri'],
            }
            print(data_field)
            output_record = {
                'recordId': record['recordId'],
                'result': 'Ok',
                'data': base64.b64encode(json.dumps(data_field).encode('utf-8')).decode('utf-8')
            }
            output.append(output_record)
            update_ipset(message['httpRequest']['clientIp'])
        else:
            # Construct output
            data_field = {
                'timestamp': now,
                'action': message['action'],
                'terminatingRuleType': rule,
                'clientIp': message['httpRequest']['clientIp'],
                'country': message['httpRequest']['country'],
                'uri': message['httpRequest']['uri'],
            }
            output_record = {
                'recordId': record['recordId'],
                'result': 'Dropped',
                'data': base64.b64encode(json.dumps(data_field).encode('utf-8')).decode('utf-8')
            }
            output.append(output_record)
    return {'records': output}