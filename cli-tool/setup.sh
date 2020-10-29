#!/bin/usr/bash

#Quick and simple bash script to help install all the dependencies for the cli tool

#TODO:
# - Setup the sso and keys
# - Install all python dependencies 

#some global vars on the top to make life easier 
RFILE="./requirements.txt"

if [ -d "./env" ]
then
    echo "python env dir already exist."
else
    mkdir env
fi

#create a new virtual environment and source it
python3 -m venv env/
source env/bin/activate

if [ -f "$RFILE" ]
then 
    pip3 install -r requirements.txt
else
    echo "$FILE does not exist, check "
fi







