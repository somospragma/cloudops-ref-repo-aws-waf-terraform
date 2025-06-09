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
