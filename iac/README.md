# Infrastructure as Code (IaC) - Terraform & Ansible

## Overview
This is directory, which contains Infrastructure as Code (IaC) configurations using **Terraform** and **Ansible**.
In this scenario I used ASG to setup new EC2 unstances to deploy webpage, available from the internet. 

## Terraform (terraform/)
I used terraform to provision AWS resources:
- **EC2 instances** with **Auto Scaling Group (ASG)**
- **Application Load Balancer (ALB)**
- **Security Groups**

## Ansible (ansible/)

I used for configuration management:
- Installs & configures **Nginx**
- Deploy a sample webpage
- Installs **AWS CloudWatch Agent** for monitoring
- Dynamically generates inventory using AWS EC2 plugin
