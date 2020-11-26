### CLI Tool

AWS CLI tool, uses utilise a number of packages to make security deployment easy


### Prequisites
- Python3
- Connectivity to AWS account
- Pip3
- SSO AWS CLI tool setup, for more information refer to the user setup section at https://github.com/comp9447-team4/soar

### To-Setup
```bash
mkdir env
python3 -m venv env
pip3 install -r requirements.txt
```

### To-Run

Verbose: 
```
python3 cli-tool.py
```

Silent mode:
```
python3 cli-tool.py -c <configuration_location>
```