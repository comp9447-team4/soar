# Docker Content Trust with Amazon ECR

## Prerequisite
Install Docker and Docker Compose on your local machine. 

## Instructions
1. Run the script:\
WARNING: Pull your unsigned Docker images into your local Docker client first before running the script. 
```
./docker-content-trust.sh
```

2. Ensure environment variables have been updated by running `. ~/.bashrc` or opening a new terminal

3. Push your image tag up to ECR:
```
docker push MY_ACCOUNT.dkr.ecr.us-east-2.amazonaws.com/my/repo:latest
```
In the first push it should prompt you for passphrases

4. Verify that the tag has been signed:
```
docker trust inspect --pretty MY_ACCOUNT.dkr.ecr.us-east-2.amazonaws.com/my/repo:latest
```


