# Sentinel Policy Testing Guide

This directory contains comprehensive unit tests for our consolidated Sentinel policy that validates Terraform configurations.

## 📁 Test Structure

```
test/
├── enforce-policy-consolidated/
│   ├── pass.hcl                     # Overall passing scenario
│   ├── fail.hcl                     # Overall failing scenario
│   ├── provider-validation-fail.hcl # Provider validation failure
│   ├── instance-type-fail.hcl       # Instance type validation failure
│   ├── data-blocks-fail.hcl         # Data blocks validation failure
│   ├── module-source-fail.hcl       # Module source validation failure
│   ├── mock-tfplan-pass.sentinel    # Mock data for passing tests
│   ├── mock-tfplan-fail.sentinel    # Mock data for failing tests
│   ├── mock-provider-fail.sentinel  # Mock data for provider failures
│   ├── mock-instance-fail.sentinel  # Mock data for instance failures
│   ├── mock-data-blocks-fail.sentinel # Mock data for data block failures
│   └── mock-module-source-fail.sentinel # Mock data for module failures
└── README.md                        # This file
```

## 🧪 Test Cases

### 1. Overall Integration Tests

#### **pass.hcl** - Complete Passing Scenario
Tests a fully compliant Terraform configuration:
- ✅ Only allowed providers (`aws`, `kubernetes`)
- ✅ All modules use `git@github.com:rbikash7758/terraform-*.git?ref=v#.#.#-ga` format
- ✅ No resources in root module
- ✅ No data blocks
- ✅ EC2 instances use allowed types (`t2.micro`) with proper tags

#### **fail.hcl** - Complete Failing Scenario  
Tests multiple violations simultaneously:
- ❌ Disallowed providers (`datadog`, `newrelic`)
- ❌ Public registry modules (`terraform-aws-modules/*`)
- ❌ Resources in root module
- ❌ Data blocks present
- ❌ Disallowed instance types (`c5.xlarge`)

### 2. Specific Validation Tests

#### **provider-validation-fail.hcl**
Tests provider validation with only disallowed providers:
- ❌ `datadog`, `newrelic`, `splunk` providers

#### **instance-type-fail.hcl**
Tests instance type and tag validation:
- ❌ `c5.4xlarge`, `m5.large` instance types
- ❌ Missing `Name` tag

#### **data-blocks-fail.hcl**
Tests data block prohibition:
- ❌ Multiple data blocks: `aws_ami`, `aws_availability_zones`, `aws_vpc`, etc.

#### **module-source-fail.hcl**
Tests module source validation:
- ❌ Public registry sources
- ❌ Missing version references
- ❌ Wrong version formats
- ❌ Non-rbikash7758 organization

## 🚀 Running Tests

### Method 1: Using the Test Script
```bash
# Run all tests
./run-tests.sh

# Make executable if needed
chmod +x run-tests.sh
```

### Method 2: Using Makefile
```bash
# Run all tests
make test

# Run with verbose output
make test-verbose

# Run specific test
make test-specific TEST=pass

# Test individual validation rules
make test-providers
make test-instances
make test-data-blocks
make test-modules

# Validate policy syntax
make validate

# Format policy files
make format
```

### Method 3: Direct Sentinel Commands
```bash
# Run all tests
sentinel test enforce-policy-consolidated.sentinel

# Run specific test
sentinel test -run="pass" enforce-policy-consolidated.sentinel

# Run with verbose output
sentinel test -verbose enforce-policy-consolidated.sentinel

# Run without color (for CI/CD)
sentinel test -no-color enforce-policy-consolidated.sentinel
```

## 📊 Expected Test Results

When running `make test` or `./run-tests.sh`, you should see:

```
🧪 Running Sentinel Policy Tests
=================================

🔍 Testing Consolidated Policy...

Running test: pass
----------------------------------------
✅ PASSED: pass

Running test: fail  
----------------------------------------
✅ PASSED: fail

Running test: provider-validation-fail
----------------------------------------
✅ PASSED: provider-validation-fail

Running test: instance-type-fail
----------------------------------------
✅ PASSED: instance-type-fail

Running test: data-blocks-fail
----------------------------------------
✅ PASSED: data-blocks-fail

Running test: module-source-fail
----------------------------------------
✅ PASSED: module-source-fail

📊 Test Summary
===============
Total Tests: 6
Passed: 6
Failed: 0

🎉 All tests passed!
```

## 🔧 Adding New Tests

To add a new test case:

1. **Create test configuration** (`.hcl` file):
```hcl
mock "tfplan/v2" {
  module {
    source = "./mock-your-test.sentinel"
  }
}

test {
  rules = {
    main = false  # or true for passing tests
  }
}
```

2. **Create mock data** (`.sentinel` file):
```hcl
import "strings"

resource_changes = {
  # Your test resources
}

raw = {
  "configuration": {
    # Your test configuration
  }
}
```

3. **Update test runner** to include your new test.

## 🐛 Troubleshooting

### Common Issues:

1. **Test fails unexpectedly**
   - Check mock data structure matches actual tfplan format
   - Verify resource addresses and types are correct
   - Ensure all required fields are present

2. **Policy syntax errors**
   - Run `make validate` to check syntax
   - Use `make format` to auto-format files

3. **Mock data issues**
   - Compare with working examples
   - Check that all nested objects have proper structure
   - Verify string values are properly quoted

### Debug Tips:

1. **Add debug prints** to policy:
```hcl
print("Debug:", some_variable)
```

2. **Run single test** with verbose output:
```bash
sentinel test -verbose -run="test-name" policy.sentinel
```

3. **Check actual tfplan structure**:
```bash
terraform show -json tfplan > debug-plan.json
```

## 📚 References

- [Sentinel Testing Documentation](https://docs.hashicorp.com/sentinel/writing/testing)
- [Terraform Plan JSON Format](https://www.terraform.io/docs/internals/json-format.html)
- [Sentinel Language Guide](https://docs.hashicorp.com/sentinel/language/)
- [Blog Reference](https://mattias.engineer/blog/2024/hashicorp-sentinel-with-terraform/)