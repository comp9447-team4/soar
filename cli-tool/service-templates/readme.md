### Notes:

After deploy successfully deployment from the SAM cli, you may dump the cloudformation templates here and integrate it with the cli tool.

To dump the cloudformation template from running template:

```bash 
    aws cloudformation get-template --stack-name <name of the stack found on aws management console> --template-stage Original
    
    aws cloudformation describe-stacks --stack-name <name of the stack found on aws management console> #same the out as json
```

Using the local translate 

```bash 
    mkdir env
    python -m venv env
    source env/
    python sam_translate.py 
```