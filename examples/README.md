# AWS WAF Terraform Module Examples

This directory contains examples demonstrating various configurations of the AWS WAF Terraform module.

## Available Examples

- [Basic Example](./basic/): Demonstrates a simple WAF configuration with common rule types
- [Advanced Example](./advanced/): Demonstrates a comprehensive WAF configuration with multiple rule types and complex protection strategies

## How to Use These Examples

Each example directory contains:

1. A `main.tf` file with the Terraform configuration
2. An `outputs.tf` file showing the outputs from the module
3. A `README.md` file with detailed information about the example

To run an example:

1. Navigate to the example directory:
   ```
   cd examples/basic
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Review the plan:
   ```
   terraform plan
   ```

4. Apply the configuration:
   ```
   terraform apply
   ```

5. To destroy the resources:
   ```
   terraform destroy
   ```

## Example Selection Guide

- **Basic Example**: Start here if you're new to AWS WAF or this module. It demonstrates the fundamental features with a straightforward configuration.

- **Advanced Example**: Use this example if you need more complex protection strategies, multiple WAF configurations, or want to see all the supported rule types in action.

## Notes

- These examples are for demonstration purposes and may need to be adjusted for production use
- Remember to review and customize the configurations to meet your specific security requirements
- The examples use placeholder values for some parameters that should be replaced with actual values in a real deployment