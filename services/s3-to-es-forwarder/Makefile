build:
	sam build

deploy_qa: build
	AWS_PROFILE=qa sam deploy --config-env qa --parameter-overrides "ParameterKey=AwsEnvironment,ParameterValue=qa"

package_qa: build
	AWS_PROFILE=qa sam package --template-file ./.aws-sam/build/template.yaml --output-template-file ./transformed.yaml --s3-bucket qa-comp9447-team4-lambda-artifacts 
	
# --s3-prefix artifacts

invoke: build
	sam local invoke -e events/s3_put.json
