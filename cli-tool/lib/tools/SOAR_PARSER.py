from __future__ import print_function, unicode_literals
import sys
import click 
from os import path
from PyInquirer import style_from_dict, Token, prompt, Separator
from pprint import pprint
import boto3
import configparser
import io
import re

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
    convert_options = [Separator(f'=== {q_name} ===')] + [{'name': i} for i in options]
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
        try:
            #list of buckets
            s3_buckets = [i['Name'] for i in s3_session.list_buckets()['Buckets']]
            #print(s3_buckets)
            s3_prompts = build_prompts("Deploy stack on the following s3 buckets:", "s3 buckets", s3_buckets)
            user_input =   prompt(s3_prompts, style=style)

            pprint(user_input)
        except Exception as e:
            print("Error occurried when trying find buckets!")

    def deploy_services(self, service_type=''):
        #prompt users on the tech stack available
        #if it is requires dns, do some quick checks and prompt user on settings needed
        #deploy stack using boto.client('cloudformation')
        #might need to poll and check if the stack is ready
        #pass

        #hardcode the service type for now, export to individual waf script later
        service_type = 'CLI-WAF'
        waf_template = load_cloudform_template(path.expanduser('../services/WAF/templates/aws-waf-security-automations.template'))
        
        #waf deployment part 1
        #waf_api_dict = toml.loads(path.expanduser('../services/WAF/templates/waf-cloudfront-deploy.toml'))
        waf_api_args, waf_api_dict = new_toml_read(path.expanduser('../services/WAF/templates/waf-cloudfront-deploy.toml'))
        #waf deployment part 2
        #waf_cloudfront_dict = load_toml_values(os.expand('../services/WAF/templates/waf-cloudfront-deploy.toml'))


        #debugging 
        print("debugging")
        print(waf_template)
        print(waf_api_dict)

        #invoke cloudformation to deploy waf here
        c_form = self.aws_session.client('cloudformation')
    
        #deploy the api waf stack template
        '''
        c_form.create_stack(
             StackName=service_type,
             TemplateBody=waf_template,
             Parameters=waf_value_dict,

        )
        '''

    #generate a play to be executed after parsing user input
    def execute_play(self):
        pass

#helper functions
def load_cloudform_template(target_file):
    res = None

    try:
        with open(target_file, 'r') as f:
            f.read()
    except Exceptiona as e:
        print(f"Unable to load template, {e}")
    
    return res

def load_toml_values(target_file):
    values_arr = []
    config = configparser.ConfigParser()

    config.read(target_file)

    if 'default.deploy.parameters' in config.sections():
        for i in config['default.deploy.parameters']:
            values_arr.push({'ParameterKey':i})
            values_arr.push({'ParameterValue':config['default.deploy.parameters'][i]})
    else:
        print("Other toml formated templates, currently not supported...Please put parameters under default.deploy.paramters")

    return values_dict

def new_toml_read(target_file):
    to_parse = ''
    parsed_data = []
    #reserved cli word list
    reserve_list = ['capabilities', 'region', 'stack_name']
    template_args = {}
    try: 
        with open(target_file, 'r') as f:
            to_parse =  f.read()

        #clean up the auto generated configurations
        #get rid of the first line as it is not valid syntax
        parsed = re.sub('^(version = .*)\n', '', to_parse)  
        #convert "" to nothing
        parsed = re.sub('\"', '', parsed) 
        config = configparser.ConfigParser()
        config.read_file(io.StringIO(parsed))
        #print(f"sections {config.sections()}")
        
        
        if 'default.deploy.parameters' in config.sections():
            for i in config['default.deploy.parameters']:
                if not(i in reserve_list):
                    parsed_data.append({
                        'ParameterKey':i,
                        'ParameterValue':config['default.deploy.parameters'][i]
                    })
                else:
                    template_args[i] = config['default.deploy.parameters'][i]
            
        else:
            print("Other toml formated templates, currently not supported...Please put parameters under default.deploy.paramters")

        
    except Exception as e:
        print(f"Unable to load template, {e}")
    
    return template_args,parsed_data
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