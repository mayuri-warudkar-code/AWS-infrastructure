# AWS Infrastructure with Terraform

This repository contains Terraform code to set up a specified AWS infrastructure, including a VPC, EC2 Auto Scaling Group with NGINX, and a Route 53 A Record. This setup is designed as part of an interview assignment to demonstrate proficiency in infrastructure as code using Terraform.

## Infrastructure Details

### VPC Configuration
- **Name**: `ionginx-vpc`
- **Public Subnets**: 3
- **Private Subnets**: 3
- **Internet Gateway**: 1
- **NAT Gateway**: 1

### EC2 Auto Scaling Group
- **Minimum Instances**: 2
- **Maximum Instances**: 4
- **Subnets**: Only Private Subnets
- **Instance Configuration**: NGINX on Ubuntu
- **Public IPv4**: Not assigned to EC2 Instances
- **SSH Access**: Not allowed

### Route 53 A Record
- Points to the NAT Gateway and allows NGINX to serve the default webpage.

## Repository Structure

.
├── main.tf
├── variables.tf
├── outputs.tf
├── userdata.sh
└── README.md

main.tf
This file contains the main Terraform code for setting up the VPC, subnets, internet gateway, NAT gateway, security groups, EC2 auto scaling group, and Route 53 record.

variables.tf
This file contains variable definitions used in the Terraform configuration.

outputs.tf
This file contains the output definitions to display useful information after the infrastructure is created.

userdata.sh
This file contains the user data script to install and start NGINX on the EC2 instances.

Getting Started
Prerequisites
Terraform installed on your local machine.
AWS CLI configured with appropriate credentials.
A registered domain name in AWS Route 53.

1. Clone the repository:
git clone https://github.com/your-username/aws-terraform-infrastructure.git
cd aws-terraform-infrastructure

2. Initialize Terraform:
terraform init

3. Plan the infrastructure:
terraform plan

4. Apply the configuration:
terraform apply

5. Clean up resources:
terraform destroy
