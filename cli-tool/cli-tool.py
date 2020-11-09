import click
#from lib.tools import SOAR_PARSER
from pyfiglet import Figlet
import boto3
import subprocess
import sys
import configparser
import os
from lib.tools.SOAR_PARSER import SOAR_PARSER

'''
SOAR CLI tool 
- One stop cli tool to securing popular serveless architectures.
- Utilise AWS proven stacks to protect your workload

Written by Steve 2020, credits goes to COMP9447 AWS SOAR templates.
'''

#global vars
cli_ver = "v0.01"
cli_name = "SOAR CLI Tool"
team_name = "Team 04"
#assumne aws generated configuration in ~/.aws/config
config_path = "~/.aws/config"

def prompt_options(option_arr):
    user_input = -1
    arr_bound = len(option_arr)-1
    while user_input < 0 or user_input > arr_bound: 
        #print out the options
        print(f"\nProfile options:")
        for i in range(len(option_arr)):
            print(f"{i}. {option_arr[i]}")
        user_input = int(input(f"Enter select [0-{arr_bound}]: "))
    
    #return the user selected name from the array
    return option_arr[user_input]

#TODO: https://stackoverflow.com/questions/62311866/how-to-use-the-aws-python-sdk-while-connecting-via-sso-credentials
def setup():
#Do some checks to make sure that all the prerequsites are installed.
    aws_installed = subprocess.check_output(['which', 'aws']).decode()
    #print(f"Checking: {aws_installed}")
    if len(aws_installed) > 0:
        #check the install creditentials are valid
        config = configparser.ConfigParser()
        config.read(os.path.expanduser(config_path))

        if len(config.sections()) > 0:
            #Add prompts for user to choose configure block
            selection = prompt_options(config.sections())

            #return a dictionary of creditentials based on user seleciton
            '''
            aws_access_key_id=ACCESS_KEY,
            aws_secret_access_key=SECRET_KEY,
            aws_session_token=SESSION_TOKEN
            {
                'key_id': '',
                'secret': '',
                'session':''
            } 
            '''
            for i in config['profile Default']:
                print(i)
            return config[selection]
        else:
           return None     
    else:
        print("Please install aws")
        sys.exit(1)

#print cool heading
def heading():
    head = Figlet (font="slant")
    print (head.renderText(team_name))
    print (head.renderText(f"{cli_name} {cli_ver}"))



if __name__ == "__main__":
    heading()
    #aws_profile = setup()
    
    #creating session
    session = boto3.session.Session()
    '''
    #s3 session
    s3 = session.client('s3')
    response = s3.list_buckets()

    # Output the bucket names
    print('Existing buckets:')
    for bucket in response['Buckets']:
        print(f'  {bucket["Name"]}')
    '''

    #TODO: need to invoke some shell script to create inventory or custom templates
    conf = {
        'template_folder': './templates',
        'inv_folder': '',
        'mapping_cfg': ''
    }

    #interactive part of the cli tool
    parser_object = SOAR_PARSER(conf,session)
    parser_object.scan_serveless()
    #parser_object.execute_play()
