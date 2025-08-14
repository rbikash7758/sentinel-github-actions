```bash
# Sentinel Policy Suite for Terraform Infrastructure Compliance

## Table of Contents
## Table of Contents
- [Policy Validations](#policy-validations)
- [Testing Framework](#testing-framework)
- [Mock Testing Guide](#mock-testing-guide)
- [Implementation Examples](#implementation-examples)

## Policy Validations

### 1. Provider Validation 🛡️ 

**Purpose:** Only allow specific providers in root module

**Allowed Providers:**
- aws
- azurerm
- google
- kubernetes
- helm
- random
- local
- null
- tls
- template

=== Provider Validation Started ===
📋 Found 5 provider configurations
✅ Allowed providers: ["aws" "azurerm" "google" "kubernetes" "helm" "random" "local" "null" "tls" "template"]

=== Checking Root Provider Compliance ===
Checking root provider: aws
  ✅ Allowed provider in root module

Checking root provider: kubernetes
  ✅ Allowed provider in root module

Checking root provider: datadog
  ❌ VIOLATION: Disallowed provider 'datadog' found in root module

### 2. Module Provider Source Validation 📦

**Purpose:** Ensure modules use organization sources, not public registry

**Allowed Sources:** 
git@github.com:rbikash7758/terraform-*

=== Module Provider Source Validation Started ===
📋 Checking 3 modules for provider source compliance

Checking module: ec2_instance
  ✅ Module uses rbikash7758 organization source

Checking module: public_registry_vpc
  ❌ VIOLATION: Module public_registry_vpc uses public registry source: terraform-aws-modules/vpc/aws
     Expected: git@github.com:rbikash7758/terraform-*

### 3. Module Source Validation 🔍

**Required Format:** 
git@github.com:rbikash7758/terraform-*.git?ref=v#.#.#-ga

=== Module Source Validation Started ===
📋 Found 3 modules

Processing module: ec2_instance
  ✅ Module source is valid

Processing module: public_s3_module
  ❌ Module public_s3_module: Invalid source format (missing ?ref=)

### 4. Resource Location Validation 📍

**Rule:** All managed resources must be in modules, not root

=== Resource Location Validation Started ===
🚫 === Resource Validation Failed ===
Found 2 resources in root module:
  ❌ aws_instance.direct_ec2
  ❌ aws_vpc.direct_vpc

### 5. Data Block Validation 📄

**Rule:** No data blocks allowed anywhere

=== Data Block Validation Started ===
📋 Found 4 data blocks in configuration

=== Data Block Analysis ===
❌ VIOLATION: Data block not allowed: data.aws_ami.ubuntu
❌ VIOLATION: Data block not allowed: data.aws_availability_zones.available

### 6. Instance Compliance Validation ⚙️

**Allowed Instance Types:**
- t2.micro
- t2.small
- t2.medium

**Required Tags:** Name

=== Instance Compliance Validation Started ===
📋 Found 2 EC2 instances to validate

=== Instance Type Analysis ===
Instance: aws_instance.direct_ec2
  Type: t2.micro
  ✅ Instance type is allowed
  ✅ Required tag 'Name' is present

Instance: module.ec2_instance.aws_instance.ec2_instance
  Type: c5.xlarge
  ❌ VIOLATION: Instance uses disallowed type: c5.xlarge

## Testing Framework

### Test Configuration Examples

pass.hcl:
mock "tfplan/v2" {
  module {
    source = "./mock-tfplan-pass.sentinel"
  }
}

test {
  rules = {
    main = true    # Expect PASS
  }
}

### Directory Structure
sentinel-policies/
├── enforce-policy-consolidated.sentinel    # Main policy
└── test/
    └── enforce-policy-consolidated/
        ├── pass.hcl                       # Pass test
        ├── fail.hcl                       # Fail test  
        ├── mock-tfplan-pass.sentinel      # Good data
        └── mock-tfplan-fail.sentinel      # Bad data

## Benefits ✨

✅ Safe: No real infrastructure affected
✅ Fast: No real Terraform planning needed
✅ Controlled: Create exact test scenarios
✅ Repeatable: Consistent test data

## Getting Started

1. Clone the repository
git clone git@github.com:rbikash7758/sentinel-cli-github-actions-tf.git

2. Install Sentinel
brew install sentinel

3. Run tests
cd sentinel-policies
sentinel test

## License
MIT License - See [LICENSE](LICENSE) file
```
