build:
	sam build

deploy_qa: build
	AWS_PROFILE=qa sam deploy --config-env qa --parameter-overrides "ParameterKey=AwsEnvironment,ParameterValue=qa"

invoke: build
	sam local invoke -e events/s4_put.json
