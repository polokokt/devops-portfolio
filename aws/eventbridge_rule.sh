#!/bin/bash

# Script to setup EventBridge rule via AWSCLI, to run lambda every 5 minutes, and check if there are
# instances to switch on

AWS_REGION="eu-west-1"
AWS_ACCOUNT_ID="0123456789"  ### need to replace

echo "Setup new event..."
aws events put-rule --schedule-expression "rate(5 minutes)" --name StartEC2Scheduler

# Grant permission to run lambda by EventBridge
echo "Granting permission to run lambda..."
aws lambda add-permission --function-name StartEC2Instances \
    --statement-id ec2-start-permission --action lambda:InvokeFunction \
    --principal events.amazonaws.com --source-arn arn:aws:events::${AWS_ACCOUNT_ID}:rule/StartEC2Scheduler

echo "Setup target for the event..."
aws events put-targets --rule StartEC2Scheduler --targets "Id"="1","Arn"="arn:aws:lambda:${AWS_REGION}:${AWS_ACCOUNT_ID}:function:StartEC2Instances"
