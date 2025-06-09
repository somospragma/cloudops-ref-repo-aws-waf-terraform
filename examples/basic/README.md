# Basic AWS WAF Configuration Example

This example demonstrates a basic configuration of the AWS WAF Terraform module.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "waf" {
  source       = "../../"
  client       = "pragma"
  functionality = "api"
  environment  = "dev"
  
  waf_config = [
    {
      application   = "payment-api"
      scope         = "REGIONAL"
      description   = "WAF for Payment API"
      default_allow = false
      
      rules = [
        {
          name     = "AWSManagedRulesCommonRuleSet"
          priority = 0
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesCommonRuleSet"
              vendor_name = "AWS"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "GeoBlockRule"
          priority = 1
          allow    = false
          statement = {
            geo_match_statement = {
              country_codes = ["RU", "CN", "IR"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "RateBasedRule"
          priority = 2
          allow    = false
          statement = {
            rate_based_statement = {
              limit = 1000
              evaluation_window_sec = 300
              aggregate_key_type = "IP"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        }
      ]
      
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  ]
}
```

## Features Demonstrated

This example demonstrates:

1. Creating a regional WAF Web ACL
2. Implementing AWS Managed Rules (Common Rule Set)
3. Configuring geo-blocking for specific countries
4. Setting up rate-based protection
5. Enabling CloudWatch metrics and sampled requests

## Deployment Steps

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Review the plan:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

4. To destroy the resources:
   ```
   terraform destroy
   ```

## Notes

- This example creates a WAF that blocks traffic by default
- The WAF is configured to protect a regional resource (like an ALB or API Gateway)
- Three rule types are demonstrated: managed rules, geo-blocking, and rate limiting