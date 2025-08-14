terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# ✅ AWS provider in root → Should be allowed
provider "aws" {
  region = "us-east-1"
}

# ❌ Datadog provider in root → Should be blocked (not in allowed list)
provider "datadog" {
  api_key = "test-key"
  app_key = "test-app-key"
}

# ❌ New Relic provider in root → Should be blocked (not in allowed list)
provider "newrelic" {
  account_id = "12345"
  api_key    = "test-api-key"
}

# ✅ Kubernetes provider in root → Should be allowed
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# This is allowed (using module)
module "ec2_instance" {
  source = "git::https://github.com/rbikash7758/terraform-aws-ec2.git?ref=v1.1.1-ga"

  ami_id        = "ami-04681163a08179f28"
  instance_type = "c5.xlarge"
  name          = "Module Resource EC2"
}



# ❌ Module using public registry (should fail)
module "public_registry_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "test-vpc"
  cidr = "10.0.0.0/16"
}

# ❌ Another public registry module (should fail)
module "public_s3_module" {
  source  = "registry.terraform.io/terraform-aws-modules/s3-bucket/aws"
  version = "3.0.0"

  bucket = "test-bucket"
}

# module "vpc" {
#   # Replace with your actual GitHub username and repository
#   source = "git@github.com:rbikash7758/terraform-aws-vpc.git?ref=v1.1.3"

#   vpc_name            = "prod-vpc"
#   vpc_cidr_block      = "10.0.0.0/16"
#   public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
#   private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
# }

# This will cause the policy to fail (direct resource)
resource "aws_instance" "direct_ec2" {
  ami           = "ami-04681163a08179f28"
  instance_type = "t2.micro"
  tags = {
    Name = "Direct Resource - Not Allowed"
  }
}

# Direct VPC
resource "aws_vpc" "direct_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Direct VPC - Not Allowed"
  }
}

# ❌ Data blocks (should be blocked by policy)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ❌ Another data block (should be blocked)
data "aws_availability_zones" "available" {
  state = "available"
}

# ❌ Data block for VPC (should be blocked)
data "aws_vpc" "default" {
  default = true
}

# ❌ Data block for subnets (should be blocked)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

