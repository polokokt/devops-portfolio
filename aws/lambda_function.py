# Lambda function to start ec2 instances with SwithOn=true tag

import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    response = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:SwitchOn', 'Values': ['true']},
            {'Name': 'instance-state-name', 'Values': ['stopped']}
        ]
    )

    instances_to_start = []

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instances_to_start.append(instance['InstanceId'])
    
    if instances_to_start:
        print(f"Starting instances {instances_to_start}")
        ec2.start_instances(InstanceIds=instances_to_start)
    else:
        print("No stopped instances to start with SwitchOn=true tag")

    return {
        'statusCode': 200,
        'body': f"Checked and started instances: {instances_to_start}"
    }