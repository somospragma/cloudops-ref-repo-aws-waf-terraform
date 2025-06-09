# AWS WAF Terraform Module

This Terraform module deploys AWS Web Application Firewall (WAF) resources to protect your web applications from common web exploits and attacks.

## Architecture

![AWS WAF Architecture](./docs/images/waf-architecture.svg)

## Features

- Creates AWS WAF Web ACLs with customizable rules
- Supports multiple rule types:
  - AWS Managed Rules
  - IP Set Rules
  - Geo-matching Rules
  - Rate-based Rules
  - SQL Injection Protection
  - Regex Pattern Matching
  - Byte Matching
- Configurable default actions (allow/block)
- CloudWatch metrics integration
- Tagging support

## Usage

```hcl
module "waf" {
  source       = "git::https://github.com/somospragma/cloudops-ref-repo-aws-waf-terraform.git?ref=v1.0.0"
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
        }
      ]
      
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  ]
}
```

## Deployment Flow

1. **Plan & Prepare**
   - Define WAF configuration requirements
   - Identify applications to protect
   - Determine rule types needed

2. **Configure Module**
   - Set module variables
   - Define WAF configurations
   - Configure rules with appropriate statements

3. **Deploy Resources**
   - Run `terraform init` to initialize the module
   - Run `terraform plan` to preview changes
   - Run `terraform apply` to deploy WAF resources

4. **Validate & Test**
   - Verify WAF deployment in AWS Console
   - Test rule functionality
   - Monitor CloudWatch metrics

5. **Maintain & Update**
   - Update rules as needed
   - Monitor for false positives
   - Adjust rate limits based on traffic patterns

## Input Parameters

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| client | Client name for resource naming | string | yes | - |
| functionality | Functionality identifier for resource naming | string | yes | - |
| environment | Deployment environment (dev, test, prod) | string | yes | - |
| waf_config | List of WAF configurations | list(object) | yes | - |

### WAF Configuration Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| application | Application identifier | string | yes | - |
| scope | WAF scope (REGIONAL or CLOUDFRONT) | string | yes | - |
| description | WAF description | string | yes | - |
| default_allow | Whether to allow by default | bool | yes | - |
| rules | List of WAF rules | list(object) | yes | - |
| cloudwatch_metrics_enabled | Enable CloudWatch metrics | bool | yes | - |
| sampled_requests_enabled | Enable sampled requests | bool | yes | - |

### Rule Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| enabled | Whether the rule is enabled | bool | no | true |
| name | Rule name | string | yes | - |
| priority | Rule priority (lower number = higher priority) | number | yes | - |
| allow | Whether to allow matching requests | bool | yes | - |
| statement | Rule statement configuration | object | yes | - |
| cloudwatch_metrics_enabled | Enable CloudWatch metrics for this rule | bool | yes | - |
| sampled_requests_enabled | Enable sampled requests for this rule | bool | yes | - |

### Statement Types

The module supports the following statement types:

1. **IP Set Statement**
   ```hcl
   statement = {
     ip_set = {
       description = "Allowed IPs"
       scope = "REGIONAL"
       ip_address_version = "IPV4"
     }
   }
   ```

2. **Managed Rule Group Statement**
   ```hcl
   statement = {
     managed_rule_group_statement = {
       rule_name   = "AWSManagedRulesCommonRuleSet"
       vendor_name = "AWS"
     }
   }
   ```

3. **SQL Injection Match Statement**
   ```hcl
   statement = {
     sqli_match_statement = {
       all_query_match = true
       text_transformations = ["URL_DECODE", "HTML_ENTITY_DECODE"]
     }
   }
   ```

4. **Geo Match Statement**
   ```hcl
   statement = {
     geo_match_statement = {
       country_codes = ["RU", "CN", "IR"]
     }
   }
   ```

5. **Rate Based Statement**
   ```hcl
   statement = {
     rate_based_statement = {
       limit = 1000
       evaluation_window_sec = 300
       aggregate_key_type = "IP"
     }
   }
   ```

6. **Byte Match Statement**
   ```hcl
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
   ```

7. **Regex Pattern Statement**
   ```hcl
   statement = {
     regex_pattern = {
       regex_strings = [".*malicious.*", ".*suspicious.*"]
       text_transformations = ["NONE"]
     }
   }
   ```

## Output Values

| Name | Description |
|------|-------------|
| waf_info | Map of WAF ARNs by application |

## Examples

- [Basic WAF Configuration](./examples/basic/README.md)
- [Advanced WAF Configuration](./examples/advanced/README.md)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## License

This module is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.