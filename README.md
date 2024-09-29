# Qdrant Multi-Region Distributed Deployment 

Qdrant is a vector similarity search engine designed for high-performance, production-ready applications.

While it supports distributed deployments out of the box, one must allow for network flow between regional VPCs for secondary clusters to communicate with the primary cluster and for the RAFT consensus algorithm to function.

This repo provides a modularised way to deploy Qdrant across multiple regions. 

Three regions are used in this example: 

- **`eu-west-2`** (London) - Primary Region
- **`us-east-1`** (N. Virginia) - Secondary Region
- **`us-west-1`** (California) - Secondary Region

The infrastructure is deployed using Terraform. No console access is required. However, step by step instructions on setting up the infrastructure through the console is also included at the bottom of this README.

## Table of Contents

- [Qdrant Multi-Region Distributed Deployment](#qdrant-multi-region-distributed-deployment)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Setting up with Terraform](#setting-up-with-terraform)
    - [Setting up vars](#setting-up-vars)
      - [AWS ACCOUNT ID \& PROFILE](#aws-account-id--profile)
      - [ORGANISATION](#organisation)
      - [REGIONS](#regions)
    - [Initial Setup](#initial-setup)
    - [Edit backend.conf](#edit-backendconf)
    - [Plan \& Apply - First Create](#plan--apply---first-create)
    - [Plan \& Apply - Subsequent Creates](#plan--apply---subsequent-creates)
  - [Setting up through the console](#setting-up-through-the-console)


## Prerequisites

- An AWS account, logged in with SSO
- AWS CLI
- Terraform CLI

Setting up dependencies is outside the scope of this README. It is assumed that you are already familiar with Terraform and AWS and your machine is configured with the necessary credentials and dependencies.

## Setting up with Terraform

### Setting up vars

#### AWS ACCOUNT ID & PROFILE

Perform a search for the following text and replace them with the correct variables: 

- `AWS_ACCOUNT_ID`
- `AWS_PROFILE_NAME` 

#### ORGANISATION

The organisation name is used in the naming of resources. You do not need to use this - it is a variable I use to organise my AWS account, though if you do not use it, you will need to update resource names and variables through the repo. 

#### REGIONS

Perform a search for `region_cidr_blocks`. There are two top-level definitions. 

- `variables.tf`
- `modules/init/region/variables.tf`

These are independent of each other, but they need to match. The other definitions have values as defaults, but the values utilised by terraform are otherwise passed through through "prop drilling".

### Initial Setup

Navigate to `modules/init` and run the following commands: 

```bash
terraform init
terraform plan
terraform apply -var="stage=dev"
```

This will set up the infrastructure to manage terraform state and lock as well as the VPCs which you can reference by name later on. 

### Edit backend.conf

Navigate to `modules/init/region/` and edit the `backend.conf` file to include the following with correct values: 

```hcl
bucket         = "qdrant-test-terraform-bucket-dev"
dynamodb_table = "qdrant-test-terraform-lock-table-dev"
role_arn       = "arn:aws:iam::AWS_ACCOUNT_ID:role/qdrant-test-terraform-assumed-role-dev"
```

### Plan & Apply - First Create

Go back to the root of the repo and run the following commands: 

```bash
terraform init -backend-config-backend.conf
terraform plan -var="stage=dev" -var="first_create=true"
terraform apply -var="stage=dev" -var="first_create=true"
```

!!! IMPORTANT !!!

You must set `first_create` to `true` when creating the infrastructure for the first time. 

Setting this to true prevents the `/modules/regional/modules/transit-gateway` module from trying to create routes for an attachment that is in the 'Pending' state. 

Additionally, it prevents the `/modules/regional/modules/qdrant` module from trying to run tasks before the network configuration has been completed to allow the clusters to communicate. 

### Plan & Apply - Subsequent Creates

```bash
terraform plan -var="stage=dev"
terraform apply -var="stage=dev"
```

## Setting up through the console 

Step 1. Create new VPCs in your preferred regions with different CIDR blocks. 

In `modules/init/region/variables.tf` you can see an example of this: 

```hcl
variable "region_cidr_blocks" {
  type = map(string)
  default = {
    us-east-1      = "10.0.0.0/16"
    us-west-1      = "10.1.0.0/16"
    eu-west-2      = "10.3.0.0/16"
  }
  description = "CIDR blocks for each region's VPC"
}
```


Step 2. Create a new security group for each VPC that either allows all traffic or allows traffic on ports 80, 443, 6333, 6334, 6335 from anywhere. Optionally, allow all traffic from within the VPC CIDR


Step 3: Create a Transit Gateway

1. Open the AWS Management Console and navigate to the VPC dashboard.
2. In the left navigation pane, under "Transit Gateways", click "Transit Gateways".
3. Click "Create Transit Gateway".
4. Provide a name for your Transit Gateway (e.g., "Qdrant-TGW").
5. Leave "Amazon side ASN" as default unless you have specific BGP requirements.
6. Enable "DNS support" and "VPN ECMP support".
7. Choose "Default route table association" and "Default route table propagation" based on your network design preferences. For simplicity, you can leave these enabled.
8. Click "Create Transit Gateway".

Step 4: Create Transit Gateway Attachments

1. Once the Transit Gateway is created, go to "Transit Gateway Attachments" in the left navigation pane.
2. Click "Create Transit Gateway Attachment".
3. Select the Transit Gateway you just created.
4. For "Attachment type", choose "VPC".
5. Select the VPC you want to attach (e.g., the VPC where Qdrant is deployed).
6. Select the subnets in which you want to create the attachment points.
7. Provide a name for this attachment (e.g., "Qdrant-VPC-Attachment").
8. Click "Create attachment".
9. Repeat this process for each VPC you want to connect (including VPCs for AWS Batch and ECS).

Step 5: Update VPC Route Tables

1. Go to "Route Tables" in the left navigation pane.
2. Select the route table associated with the subnet where your Qdrant instances are located.
3. Click "Edit routes".
4. Add a new route:
    - For "Destination", enter the CIDR block of the VPC where AWS Batch/ECS is running.
    - For "Target", select the Transit Gateway you created.
5. Click "Save routes".
6. Repeat this process for each VPC, pointing the route for other VPCs' CIDR blocks to the Transit Gateway.

Step 6: Configure Transit Gateway Route Tables

1. In the left navigation pane, click on "Transit Gateway Route Tables".
2. You should see a default route table created with your Transit Gateway. Select it.
3. Click on the "Associations" tab and ensure all your VPC attachments are associated.
4. Click on the "Propagations" tab and ensure all your VPC attachments are propagating.

Step 7: Set up a private DNS namespace in Cloud Map

1. Go to the AWS Management Console and navigate to the AWS Cloud Map dashboard.
2. Click on "Create namespace".
3. Provide a name for your namespace (e.g., "Qdrant-Namespace").
4. Choose "DNS" as the type.
5. Click "Create namespace".

Step 8: Update hosted zones with each VPC

1. Go to the AWS Management Console and navigate to the Route 53 dashboard.
2. Click on "Hosted zones".
3. Select the hosted zone for your new namespace.
4. Click on "Edit Hosted Zone".
5. Add each of your regional VPCs as VPCs within the hosted zone.

Step 9: Create a new cluster in ECS

1. Go to the AWS Management Console and navigate to the ECS dashboard.
2. Click on "Clusters".
3. Click on "Create cluster".
4. Provide a name for your cluster (e.g., "Qdrant-Cluster").
5. Click "Create cluster".


Step 10: Create a new task in the cluster

1. In the left navigation pane, click on "Tasks".
2. Click on "Create task".
3. Provide a name for your task (e.g., "Qdrant-Task") and use the definitions found at `modules/regional/modules/qdrant/main.tf`
   1. Note how the commands are different depending on whether the task is primary or secondary. The secondary tasks must boostrap from the primary. 

Step 11: Create a new service in the cluster with Service Discovery enabled

1. In the left navigation pane, click on "Services".
2. Click on "Create service".
3. Provide a name for your service (e.g., "Qdrant-Service").
4. Select the cluster you created in the previous step.
5. Under "Service discovery configuration", select "Enable service discovery".
6. Select the namespace you created in the previous step.


Step 12: Testing & debugging

If your tasks are not running, check the following: 

- VPC route tables for your regional VPC should include a route for each of the other VPCs' CIDR blocks pointing to the Transit Gateway.
- Transit Gateway Route Tables should include a route for each of the other VPCs' CIDR blocks pointing to the Transit Gateway.
- The security group for your VPC should allow all outbound traffic and inbound traffic on ports 6333, 6334, 6335.
- The ECS service should be correctly discoverable using Service Discovery and the correct DNS namespace. 
- The Hosted Zone for each region should be attached to each of your VPCs.
