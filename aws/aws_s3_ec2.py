# Python script to firsty list ec2 instances and s3 buckets.
# At the second step, there is s3 bucket created and then 
# ec2 instance, with SwitchOn=true tag.
# At the end, there is output with DNS address to the newly created ec2 instance. 

import boto3
import time

s3 = boto3.client('s3')
ec2_resources = boto3.resource('ec2')

def list_s3_buckets():
    """ Function to list all S3 buckets """
    response_s3 = s3.list_buckets()
    print("List of S3 buckets:")
    
    if 'Buckets' in response_s3:
        for bucket in response_s3['Buckets']:
            print(f" - {bucket['Name']}")
    else:
        print("No buckets found.")

list_s3_buckets()

#list ec2 instances
def list_ec2_instances():
    """Function to list all ec2 instances"""
    print("\nList of EC2 Instances before creation:")
    for instance in ec2_resources.instances.all():
        print(f"Instance ID: {instance.id}, , state: {instance.state['Name']}")

list_ec2_instances()

bucket_name = "my-devops-bucket-1313"
s3.create_bucket(
    Bucket=bucket_name, 
    CreateBucketConfiguration ={
        'LocationConstraint': 'eu-west-1'
    } 
)
print(f"Bucket {bucket_name} created!")

instance = ec2_resources.create_instances(
    ImageId = 'ami-09095b454ca5da4e2',
    MinCount=1,
    MaxCount=1,
    InstanceType='t2.micro',
    KeyName='my-key-pair',
    TagSpecifications=[
        {
            'ResourceType': 'instance',
            'Tags': [   # Tags to identify ec2 instance to switch on/off
                {'Key': 'Name', 'Value': 'DevOps-Instance'},
                {'Key': 'SwitchOn', 'Value': 'true'}
            ]
        }
    ]
)[0]
print(f"EC2 instance created: {instance.id}")

print(f"Wait till the instance will be running...")

instance.wait_until_running()
print(f"EC2 instance {instance.id} now is running !")

instance.reload()

# Check again list of instances
list_ec2_instances()

public_dns = instance.public_dns_name
print(f"EC2 Public IP: {public_dns}")

print(f"Waiting for SSH service...")
time.sleep(30)

print(f"Now You can connect to your server using: ssh -i my-key-pair.pem ubuntu@{public_dns}")




