# Boto3 and AWSCLI , used to manage AWS infrastructure

This is directory with python and bash scripts to manage AWS infrastructure, using boto3 library and aws cli commmands. 

In `aws_s3_ec2.py` file, I printed available s3 buckets and ec2 instances.
Then I created a ne s3 bucket and new ec2 instance with dedicated tag.
After the ec2 instance was ready, I prnted DNS address to login. 

By bash scripts (`lambda_functions_create_aws_resources.sh`), I created lambda function with all necessary resources, like IAM role, to check if there are any stopped ec2 instances with  dedicated tag. If yes, then the lampda swtih them on. 
At the end there ais scipt to create EventBridge rule, to trigger lambda every 10 minutes.
Python script for lambda is in the `lambda_function.py` file.

