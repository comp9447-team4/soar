import sys
import click 
from os import path

#Parses class which parses the user import and deploy AWS security stack. 
class SOAR_PARSER():
    def __init__(self, args):
        self.template_folder = args.template_folder
        self.inventory_folder = args.inv_folder
        self.mapping_yml = args.mapping_cfg
    
    #generate a play to be executed after parsing user input
    def execute_play(self):
        pass

@click.command()
@click.option('--inv','-i', help="Location of the inventory folder",  fg="blue", bold=True, required=True)
@click.option('--tmp-folder','-t', help="Location of the inventory folder",  fg="red", bold=True, default=None)
@click.option('--map','-m', help="Location of the inventory folder",  fg="green", bold=True, default=None)
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


#checks if the directory exists
def dir_check(targetDir):
    if (path.exists(targetDir)):
        return True
    else:
        return False

if __name__ == '__main__':
    #
    
    args = prompt_user()
    soar_obj = SOAR_PARSER(args)