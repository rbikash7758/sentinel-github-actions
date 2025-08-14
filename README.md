1. Provider Validation
Purpose: Only allow specific providers in root module Allowed Providers: aws, azurerm, google, kubernetes, helm, random, local, null, tls, template

Sample Output:

=== Provider Validation Started ===
📋 Found 5 provider configurations
✅ Allowed providers: ["aws" "azurerm" "google" "kubernetes" "helm" "random" "local" "null" "tls" "template"]

=== Checking Root Provider Compliance ===
Checking root provider: aws
  ✅ Allowed provider in root module

Checking root provider: kubernetes
  ✅ Allowed provider in root module

Checking root provider: datadog
  ❌ VIOLATION: Disallowed provider 'datadog' found in root module: datadog
     Allowed providers: ["aws" "azurerm" "google" "kubernetes" "helm" "random" "local" "null" "tls" "template"]

🚫 === Provider Validation Failed ===
2. Module Provider Source Validation
Purpose: Ensure all modules use rbikash7758 organization sources, not public registry Allowed Sources: git@github.com:rbikash7758/terraform-*

Sample Output:

=== Module Provider Source Validation Started ===
📋 Checking 3 modules for provider source compliance

Checking module: ec2_instance
  ✅ Module uses rbikash7758 organization source

Checking module: public_registry_vpc
  ❌ VIOLATION: Module public_registry_vpc uses public registry source: terraform-aws-modules/vpc/aws
     Expected: git@github.com:rbikash7758/terraform-*

🚫 === Module Provider Source Validation Failed ===
3. Module Source Validation
Purpose: Enforce proper Git source format with versioning Required Format: git@github.com:rbikash7758/terraform-*.git?ref=v#.#.#-ga

Sample Output:

=== Module Source Validation Started ===
📋 Found 3 modules

Processing module: ec2_instance
  ✅ Module source is valid

Processing module: public_s3_module
  ❌ Module public_s3_module: Invalid source format (missing ?ref=)

🚫 === Module Source Validation Failed ===
4. Resource Location Validation
Purpose: Prevent resources from being defined in root module (must use modules) Rule: All managed resources must be in modules, not root

Sample Output:

=== Resource Location Validation Started ===

🚫 === Resource Validation Failed ===
Found 2 resources in root module:
  ❌ aws_instance.direct_ec2
  ❌ aws_vpc.direct_vpc
5. Data Block Validation
Purpose: Prohibit all data blocks in Terraform configuration Rule: No data blocks allowed anywhere

Sample Output:

=== Data Block Validation Started ===
📋 Found 4 data blocks in configuration

=== Data Block Analysis ===
❌ VIOLATION: Data block not allowed: data.aws_ami.ubuntu (type: aws_ami)
   Data blocks are prohibited in this configuration
❌ VIOLATION: Data block not allowed: data.aws_availability_zones.available (type: aws_availability_zones)
   Data blocks are prohibited in this configuration

🚫 === Data Block Validation Failed ===
6. Instance Compliance Validation
Purpose: Enforce allowed EC2 instance types and mandatory tags Allowed Instance Types: t2.micro, t2.small, t2.medium Mandatory Tags: Name

Sample Output:

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
  ✅ Allowed types: ["t2.micro" "t2.small" "t2.medium"]

🚫 === Instance Type Violations ===
❌ Instance module.ec2_instance.aws_instance.ec2_instance uses disallowed type: c5.xlarge
Final Validation Results Summary
Sample Complete Output:

🔍 Starting Consolidated Policy Validation

=== Final Validation Results ===
Provider Validation: ❌ Failed
Module Provider Source Validation: ❌ Failed  
Module Source Validation: ❌ Failed
Resource Location Validation: ❌ Failed
Data Block Validation: ❌ Failed
Instance Compliance Validation: ❌ Failed

Main Rule: ❌ FAILED


sentinel test vs sentinel apply - Key Differences
🧪 sentinel test
Purpose: Unit testing and development validation

What it does:

Runs mock data against your policy
Tests your policy logic with predefined scenarios
Validates that your policy behaves correctly under different conditions
Uses fake/simulated Terraform plan data
No real infrastructure is involved
When to use:

During policy development
Before deploying policies to production
Continuous Integration (CI/CD) pipelines
Regression testing after policy changes
Example:

sentinel test -run="pass" enforce-policy-consolidated.sentinel
# Uses mock-tfplan-pass.sentinel (fake data)
# Tests if policy correctly allows compliant configurations
🚀 sentinel apply
Purpose: Real-world policy enforcement

What it does:

Runs against actual Terraform plan data
Evaluates real infrastructure changes
Makes actual pass/fail decisions for deployments
Uses live tfplan.json from terraform plan
Blocks or allows real infrastructure changes
When to use:

In production Terraform workflows
As part of Terraform Cloud/Enterprise policy sets
Before terraform apply to validate real changes
In CI/CD pipelines with actual infrastructure
Example:

sentinel apply enforce-policy-consolidated.sentinel
# Uses actual tfplan.json from terraform plan
# Makes real decisions about infrastructure deployment


🎭 What is Mock Testing?
Think of mock testing like rehearsing a play with fake props instead of real ones:

Real Performance (sentinel apply) = Using real stage, real props, real audience
Rehearsal (sentinel test) = Using fake stage, cardboard props, no audience
📁 Your Test Structure
sentinel-policies/
├── enforce-policy-consolidated.sentinel    # The actual policy (like a script)
└── test/
    └── enforce-policy-consolidated/
        ├── pass.hcl                        # Test that should PASS
        ├── fail.hcl                        # Test that should FAIL  
        ├── mock-tfplan-pass.sentinel       # Fake "good" data
        └── mock-tfplan-fail.sentinel       # Fake "bad" data
🔄 How It Works Step by Step
Step 1: Test Configuration Files (.hcl)
pass.hcl tells Sentinel:

mock "tfplan/v2" {
  module {
    source = "./mock-tfplan-pass.sentinel"  # Use this fake data
  }
}

test {
  rules = {
    main = true    # I expect the policy to PASS (return true)
  }
}
fail.hcl tells Sentinel:

mock "tfplan/v2" {
  module {
    source = "./mock-tfplan-fail.sentinel"  # Use this fake data
  }
}

test {
  rules = {
    main = false   # I expect the policy to FAIL (return false)
  }
}
Step 2: Mock Data Files (.sentinel)
mock-tfplan-pass.sentinel contains fake "good" data:

raw = {
  "configuration": {
    "provider_config": {
      "aws": {                    # ✅ Allowed provider
        "name": "aws"
      },
      "kubernetes": {             # ✅ Allowed provider  
        "name": "kubernetes"
      }
    }
  }
}
mock-tfplan-fail.sentinel contains fake "bad" data:

raw = {
  "configuration": {
    "provider_config": {
      "datadog": {                # ❌ Disallowed provider
        "name": "datadog"
      },
      "newrelic": {               # ❌ Disallowed provider
        "name": "newrelic"  
      }
    }
  }
}
Step 3: What Happens When You Run Tests
sentinel test enforce-policy-consolidated.sentinel
For pass.hcl:

📥 Sentinel loads fake "good" data from mock-tfplan-pass.sentinel
🔄 Runs your policy against this fake data
✅ Policy sees only aws and kubernetes (allowed providers)
✅ Policy returns true (passes)
✅ Test expects main = true, gets true → TEST PASSES
For fail.hcl:

📥 Sentinel loads fake "bad" data from mock-tfplan-fail.sentinel
🔄 Runs your policy against this fake data
❌ Policy sees datadog and newrelic (disallowed providers)
❌ Policy returns false (fails)
✅ Test expects main = false, gets false → TEST PASSES
🎯 Key Concepts
Mock Data = Fake Terraform Plan
Real Terraform Plan          Mock Data
==================          =========
terraform plan               mock-tfplan-pass.sentinel
↓                           ↓
tfplan.json                 Fake JSON structure
↓                           ↓
sentinel apply              sentinel test
Test Logic
Test Name: "pass"
Expected: Policy should PASS (main = true)
Mock Data: Only good providers (aws, kubernetes)
Result: Policy passes ✅ → Test passes ✅

Test Name: "fail"  
Expected: Policy should FAIL (main = false)
Mock Data: Bad providers (datadog, newrelic)
Result: Policy fails ❌ → Test passes ✅
🔍 Your Test Results Explained
PASS - enforce-policy-consolidated.sentinel
  PASS - test/enforce-policy-consolidated/fail.hcl
  PASS - test/enforce-policy-consolidated/pass.hcl
1 tests completed in 11.087125ms
What this means:

✅ Overall: All tests passed
✅ fail.hcl: Policy correctly rejected bad providers (datadog, newrelic)
✅ pass.hcl: Policy correctly accepted good providers (aws, kubernetes)
⚡ Speed: Tests ran in 11ms (super fast because it's fake data)
🎭 Real World Analogy
Mock Testing is like:

🎬 Movie rehearsal with cardboard props vs real movie set
🍳 Cooking practice with play food vs real ingredients
🚗 Driving simulator vs real car on real road
Benefits:

✅ Safe: No real infrastructure affected
✅ Fast: No real Terraform planning needed
✅ Controlled: You create exact scenarios to test
✅ Repeatable: Same fake data every time
💡 Why This is Powerful
Test Edge Cases: Create fake data for rare scenarios
Test Failures: Safely test what happens when things go wrong
Fast Feedback: Know if your policy works before deploying
Regression Testing: Ensure changes don't break existing logic
Example Use Cases:

# Test what happens with 50 disallowed providers
# Test what happens with no providers at all  
# Test what happens with malformed provider config
# Test what happens with mixed good/bad providers
This way, you can be confident your policy works correctly before it starts blocking real infrastructure deployments!