from __future__ import print_function, unicode_literals
import sys
import click 
from os import path
from PyInquirer import style_from_dict, Token, prompt, Separator
from pprint import pprint
import boto3


style = style_from_dict({
    Token.Separator: '#cc5454',
    Token.QuestionMark: '#673ab7 bold',
    Token.Selected: '#cc5454',  # default
    Token.Pointer: '#673ab7 bold',
    Token.Instruction: '',  # default
    Token.Answer: '#f44336 bold',
    Token.Question: '',
})

def build_prompts(q_message, q_name, options):
    #create a prompt for the user to select something
    convert_options = [{'name': i} for i in options]
    q = [
        {
            'type': 'checkbox',
            'message': q_message,
            'name': q_name,
            'choices': convert_options,
            'validate': lambda answer: 'You must choose at one option' \
                if len(answer) == 0 else True
        }
    ]
    
    return q


#Parses class which parses the user import and deploy AWS security stack. 
class SOAR_PARSER():
    def __init__(self, args, aws_session):
        self.aws_session = aws_session
        self.template_folder = args['template_folder']
        self.inventory_folder = args['inv_folder']
        self.mapping_yml = args['mapping_cfg']
        
    
    def scan_serveless(self):
        print(f"Scanning for serveless applicaiton in account ...")
        s3_session = self.aws_session.client('s3')
        #list of buckets
        s3_buckets = [i['Name'] for i in s3_session.list_buckets()['Buckets']]
        #print(s3_buckets)
        s3_prompts = build_prompts("Deploy stack on the following s3 buckets:", "s3 buckets", s3_buckets)
        user_input = prompt(s3_prompts, style=style)

        pprint(user_input)

    #generate a play to be executed after parsing user input
    def execute_play(self):
        pass


'''
@click.command()
@click.option('--inv','-i', help="Location of the inventory folder", bold=True, required=True)
@click.option('--tmp-folder','-t', help="Location of the inventory folder", bold=True, default=None)
@click.option('--map','-m', help="Location of the inventory folder", bold=True, default=None)
#Using click prompts to generate an interactive cli form for users to select the type of deployment
def prompt_user(inv_folder, template_folder, mapping_cfg_loc):
    args = {}

    #check if folder exist
    if (inv_folder and dir_check(inv_folder)):
        args['inv_folder'] = inv_folder

        if (template_folder and mapping_cfg_loc):
            print("Found two references to folder path, please use only one path")
            sys.exit(1)
        else:
            args['template_folder'] = template_folder
            args['mapping_cfg'] = mapping_cfg_loc

    return args
'''

#checks if the directory exists
def dir_check(targetDir):
    if (path.exists(targetDir)):
        return True
    else:
        return False

if __name__ == '__main__':
    args = prompt_user()
    soar_obj = SOAR_PARSER(args)