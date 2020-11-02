import click
from lib.tools import SOAR_PARSER
from pyfiglet import Figlet

#global vars
cli_ver = "v0.01"
cli_name = "Team 04 SOAR"

def setup():
    pass

#print cool heading
def heading():
    head = Figlet (font="slant")
    print (head.renderText(cli_name))



if __name__ == "__main__":
    heading()
    setup()
    parser_object = SOAR_PARSER()
    parser_object.execute_play()
