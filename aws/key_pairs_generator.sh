#!/bin/bash

aws ec2 create-key-pair --key-name my-key-pair --query "KeyMaterial" --output text > my-key-pair.pem
chmod 400 my-key-pair.pem
aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName"