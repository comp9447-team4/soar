import click
#from lib.tools import SOAR_PARSER
from pyfiglet import Figlet
import boto3
import subprocess
import sys
import configparser

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
    user_input = None
    arr_bound = leng
    while user_input < 0 or user_input > len(option_arr)-1: 
        #print out the options
        user_input = input(f"Enter select [0-{arr_bound}]: ")
    
    return option_arr[user_input]

def setup():
#Do some checks to make sure that all the prerequsites are installed.
    aws_installed = subprocess.check_output(['which', 'aws']).decode()
    #print(f"Checking: {aws_installed}")
    if len(aws_installed) > 0:
        #check the install creditentials are valid
        config = configparser.ConfigParser()
        config.read(config_path)

        if len(config.sections()) > 0:
            #TO-DO: add prompts for user to choose configure block
            print("")
        else:
           return user_configure     
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
    setup()
    #parser_object = SOAR_PARSER()
    parser_object.execute_play()
