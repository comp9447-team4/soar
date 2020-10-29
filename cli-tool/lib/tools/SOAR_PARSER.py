import sys


#Parses class which parses the user import and deploy AWS security stack. 
class SOAR_PARSER():
    def __init__(self, inventory_folder,template_folder=None, mapping_cfg=None):
        self.template_folder = template_folder
        self.inventory_folder = inventory_folder
        self.mapping_yml = mapping_yml
    
    #generate a play to be executed after parsing user input
    def execute_play(self):
        pass

#Using click prompts to generate an interactive cli form for users to select the type of deployment
def prompt_user():
    pass

#Parse std input that can be used for advance users
def parse_args():
    pass