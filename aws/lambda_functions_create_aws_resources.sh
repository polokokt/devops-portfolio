#!/bin/bash

AWS_ACCOUNT_ID="0123456789"  ##  need to replace
LAMBDA_ROLE_NAME="LambdaEC2Role"

# Create IAM role for Lambda

echo "Creating Lambda Role..."

aws iam create-role --role-name ${LAMBDA_ROLE_NAME} \
    --assume-role-policy-document file://<(echo '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }')

# Grant access to EC2 resources
echo "Granting acceess to EC2 resources..."

aws iam attach-role-policy --role-name ${LAMBDA_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-role-policy --role-name ${LAMBDA_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

echo "Waiting for IAM role to propagate..."
sleep 15

# Create Lambda function
echo "Creating Lambda function..."

aws lambda create-function --function-name StartEC2Instances \
    --runtime python3.13 \
    --role arn:aws:iam::${AWS_ACCOUNT_ID}:role/${LAMBDA_ROLE_NAME} \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://lambda_function.zip

# Check the list of available lambda functions
echo "List of lambda functions:\n"
aws lambda list-functions