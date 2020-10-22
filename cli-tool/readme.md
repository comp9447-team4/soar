### CLI Tool

AWS CLI tool, uses utilise a number of packages to make security deployment easy


### Prequisites
- Python3
- Connectivity to AWS account
- Pip3

### To-Setup
```
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