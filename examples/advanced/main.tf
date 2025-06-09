provider "aws" {
  region = "us-east-1"
}

module "waf" {
  source       = "../../"

  providers = {
    aws.project = aws.project
  }

  client       = "pragma"
  functionality = "payment"
  environment  = "prod"
  
  waf_config = [
    {
      application   = "payment-gateway"
      scope         = "REGIONAL"
      description   = "WAF for Payment Gateway API"
      default_allow = false
      
      rules = [
        # AWS Managed Rules - Core ruleset
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

        # AWS Managed Rules - Bad Inputs ruleset
        {
          name     = "AWSManagedRulesKnownBadInputsRuleSet"
          priority = 1
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesKnownBadInputsRuleSet"
              vendor_name = "AWS"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        
        # AWS Managed Rules - SQL injection prevention
        {
          name     = "AWSManagedRulesSQLiRuleSet"
          priority = 2
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
        
        # Custom SQL Injection Protection
        {
          name     = "CustomSQLiProtection"
          priority = 3
          allow    = false
          statement = {
            sqli_match_statement = {
              all_query_match      = true
              text_transformations = ["URL_DECODE", "HTML_ENTITY_DECODE"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        
        # Geo-blocking high-risk countries
        {
          name     = "GeoBlockHighRiskCountries"
          priority = 4
          allow    = false
          statement = {
            geo_match_statement = {
              country_codes = ["RU", "CN", "IR", "KP", "VE"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        
        # Rate limiting for API endpoints
        {
          name     = "RateLimitAPIEndpoints"
          priority = 5
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
        
        # Block specific request patterns
        {
          name     = "BlockSuspiciousUserAgents"
          priority = 6
          allow    = false
          statement = {
            byte_match_statement = {
              positional_constraint = "CONTAINS"
              field_to_match = {
                single_header = "user-agent"
              }
              search_string = "suspicious-bot"
              text_transformations = ["LOWERCASE"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        
        # Block specific URI patterns
        {
          name     = "BlockSuspiciousURIs"
          priority = 7
          allow    = false
          statement = {
            regex_pattern = {
              regex_strings = [".*\\.php$", ".*\\.aspx$", ".*/wp-admin/.*"]
              text_transformations = ["URL_DECODE", "LOWERCASE"]
              field_to_match = {
                uri_path = true
              }
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        }
      ]
      
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    },
    
    # Second WAF for Admin Portal
    {
      application   = "admin-portal"
      scope         = "REGIONAL"
      description   = "WAF for Admin Portal"
      default_allow = false
      
      rules = [
        # AWS Managed Rules
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
        
        # AWS Managed Rules - Bad Inputs ruleset
        {
          name     = "AWSManagedRulesKnownBadInputsRuleSet"
          priority = 1
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesKnownBadInputsRuleSet"
              vendor_name = "AWS"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # Strict geo-restriction for admin portal
        {
          name     = "GeoAllowOnlyColombia"
          priority = 2
          allow    = true
          statement = {
            geo_match_statement = {
              country_codes = ["CO"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },
        
        # Stricter rate limiting for admin portal
        {
          name     = "StrictRateLimit"
          priority = 3
          allow    = false
          statement = {
            rate_based_statement = {
              limit = 100
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
