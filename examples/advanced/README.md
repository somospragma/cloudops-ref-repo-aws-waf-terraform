# Advanced AWS WAF Configuration Example

This example demonstrates an advanced configuration of the AWS WAF Terraform module with multiple rule types and complex protection strategies.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "waf" {
  source       = "../../"
  client       = "pragma"
  functionality = "api"
  environment  = "prod"
  
  waf_config = [
    {
      application   = "ecommerce-api"
      scope         = "REGIONAL"
      description   = "WAF for E-commerce API with advanced protection"
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
          name     = "AWSManagedRulesSQLiRuleSet"
          priority = 1
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesSQLiRuleSet"
              vendor_name = "AWS"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "GeoBlockRule"
          priority = 2
          allow    = false
          statement = {
            geo_match_statement = {
              country_codes = ["RU", "CN", "IR", "KP"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "RateBasedRule"
          priority = 3
          allow    = false
          statement = {
            rate_based_statement = {
              limit = 2000
              evaluation_window_sec = 300
              aggregate_key_type = "IP"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "BadBotBlocker"
          priority = 4
          allow    = false
          statement = {
            byte_match_statement = {
              positional_constraint = "CONTAINS"
              field_to_match = {
                single_header = "user-agent"
              }
              search_string = "BadBot"
              text_transformations = ["NONE"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "SuspiciousPathBlocker"
          priority = 5
          allow    = false
          statement = {
            regex_pattern = {
              regex_strings = [".*\\.\\./.*", ".*%2e%2e/.*", ".*exec\\(.*"]
              text_transformations = ["URL_DECODE", "HTML_ENTITY_DECODE"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        {
          name     = "AllowInternalIPs"
          priority = 6
          allow    = true
          statement = {
            ip_set = {
              description = "Internal IPs"
              scope = "REGIONAL"
              ip_address_version = "IPV4"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        }
      ]
      
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    },
    {
      application   = "marketing-site"
      scope         = "CLOUDFRONT"
      description   = "WAF for Marketing Website"
      default_allow = true
      
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
          name     = "RateBasedRule"
          priority = 1
          allow    = false
          statement = {
            rate_based_statement = {
              limit = 5000
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

1. Creating multiple WAF Web ACLs (regional and CloudFront)
2. Implementing multiple AWS Managed Rules
3. Configuring geo-blocking for specific countries
4. Setting up rate-based protection with different limits
5. Using byte match statements to block bad bots
6. Using regex pattern matching to block suspicious paths
7. Configuring IP set rules to allow specific IPs
8. Different default actions (block vs allow)
9. Enabling CloudWatch metrics and sampled requests

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

- This example creates two WAFs with different configurations
- The first WAF is configured to protect a regional resource with comprehensive protection
- The second WAF is configured to protect a CloudFront distribution with basic protection
- Multiple rule types are demonstrated to show the flexibility of the module