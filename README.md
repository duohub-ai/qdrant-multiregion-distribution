# Qdrant Multi-Region Distributed Deployment 

Qdrant is a vector database designed for high-performance, production-ready applications.

While Qdrant supports [distributed deployments](https://qdrant.tech/documentation/guides/distributed_deployment/), one must allow network flow between regional VPCs for secondary clusters to communicate with the primary cluster. Without this, the RAFT consensus algorithm will fail and the secondary cluster tasks will terminate.

This repo provides a modularised way to deploy Qdrant across multiple regions using VPC peering. While Transit Gateways are more scaleable and generally the better option, they are far more expensive being billed per attachment per hour. You can easily adapt this repo to Transit Gateway - alternatively, look at the commit history as this project started with a Transit Gateway configuration. 

Three regions are used in this example: 

- **`eu-west-2`** (London) - Primary Region
- **`us-east-1`** (N. Virginia) - Secondary Region
- **`us-west-1`** (California) - Secondary Region

The infrastructure is deployed using Terraform. No console access is required. 

Please note, this repo does not cover EFS. It is assumed that you will add an EFS mount to your tasks for persistence.

## Table of Contents

- [Qdrant Multi-Region Distributed Deployment](#qdrant-multi-region-distributed-deployment)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Setting up with Terraform](#setting-up-with-terraform)
    - [Set Up Variables](#set-up-variables)
      - [AWS ACCOUNT ID \& PROFILE](#aws-account-id--profile)
      - [ORGANISATION](#organisation)
      - [REGIONS](#regions)
    - [Create Foundational Infrastructure - Init Module](#create-foundational-infrastructure---init-module)
    - [Edit backend.conf](#edit-backendconf)
    - [Plan \& Apply - First Create](#plan--apply---first-create)
    - [Plan \& Apply - Subsequent Creates](#plan--apply---subsequent-creates)
  - [Development](#development)
    - [Hardcoded Values](#hardcoded-values)
    - [Adding Additional Services](#adding-additional-services)
  - [Project Structure](#project-structure)


## Prerequisites

- An AWS account, logged in with SSO
- AWS CLI
- Terraform CLI

Setting up dependencies is outside the scope of this README. It is assumed that you are already familiar with Terraform and AWS and your machine is configured with the necessary credentials and dependencies.

## Setting up with Terraform

### Set Up Variables

There are some variables which you MUST change for this module to deploy. These are specified below. 

#### AWS ACCOUNT ID & PROFILE

Perform a search for the following text and replace them with the correct variables: 

- `AWS_ACCOUNT_ID`
- `AWS_PROFILE_NAME` 

#### ORGANISATION

The organisation name is used in the naming of resources. You do not need to use this - it is a variable I use to organise my AWS account, though if you do not use it, you will need to update resource names and remove the organisation variables throughout the project. 

#### REGIONS

Perform a search for `region_cidr_blocks`. There are two top-level definitions located at: 

- `variables.tf` - root module
- `modules/init/region/variables.tf` - initialisation module

These are independent of each other, but they need to match. 

You will see other results for `region_cidr_blocks` throughout the project - these have default values but have their actual values passed through. 

### Create Foundational Infrastructure - Init Module

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
terraform init -backend-config=backend.conf
terraform plan -var="stage=dev" -var="first_create=true"
terraform apply -var="stage=dev" -var="first_create=true"
```

!!! IMPORTANT !!!

You should set `first_create` to `true` when creating the infrastructure for the first time. 

It prevents the `/modules/regional/modules/qdrant` module from trying to run tasks before the network configuration has been completed to allow the clusters to communicate. 

### Plan & Apply - Subsequent Creates

```bash
terraform plan -var="stage=dev"
terraform apply -var="stage=dev"
```

## Development

### Hardcoded Values

Please note, there is one location where values are hardcoded. 

`modules/regional/main.tf`

Since primary cluster is in `eu-west-2`, all secondary clusters need to bootstrap from the primary. 
```hcl
module "qdrant" {
  source = "./modules/qdrant"
 ...
  primary_service_discovery_name = "qdrant-test-qdrant-eu-west-2"
  primary_namespace_name        = "qdrant-test.eu-west-2.internal"
}
```

### Adding Additional Services

You may find yourself in a position where you need to add additional services to your clusters that use the same regional private DNS namespace. 

If this is the case, you can define multiple `service_discovery_${name}` modules in `/modules/regional/main.tf`, for example: 

```hcl 
module "service_discovery_qdrant" {
  source         = "./modules/service-discovery"
  organisation   = var.organisation
  region         = var.region
  namespace_id = module.namespace.namespace_id
  service_name = "${var.organisation}-qdrant-${var.region}"
}

module "service_discovery_falkordb" {
  source         = "./modules/service-discovery"
  organisation   = var.organisation
  region         = var.region
  namespace_id = module.namespace.namespace_id
  service_name = "${var.organisation}-falkordb-${var.region}"
}
```


## Project Structure

```txt
├── README.md
├── backend.conf
├── backend.tf
├── locals.tf
├── main.tf
├── modules
│   ├── global
│   │   ├── main.tf
│   │   ├── modules
│   │   │   └── iam
│   │   │       ├── main.tf
│   │   │       ├── outputs.tf
│   │   │       └── variables.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── init
│   │   ├── access.tf
│   │   ├── dynamodb.tf
│   │   ├── locals.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── region
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── vpc.tf
│   │   ├── s3.tf
│   │   └── variables.tf
│   └── regional
│       ├── main.tf
│       ├── modules
│       │   ├── namespace
│       │   │   ├── main.tf
│       │   │   ├── outputs.tf
│       │   │   └── variables.tf
│       │   ├── network
│       │   │   ├── main.tf
│       │   │   ├── outputs.tf
│       │   │   └── variables.tf
│       │   ├── qdrant
│       │   │   ├── main.tf
│       │   │   ├── outputs.tf
│       │   │   └── variables.tf
│       │   └── service-discovery
│       │       ├── main.tf
│       │       ├── output.tf
│       │       └── variables.tf
│       ├── outputs.tf
│       └── variables.tf
└── variables.tf
```
