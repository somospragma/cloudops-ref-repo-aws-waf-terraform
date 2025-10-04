module "waf_with_overrides" {
  source       = "../"
  client       = "pragma"
  project      = "api"
  environment  = "dev"
  
  waf_config = {
    payment-api = {
      scope         = "REGIONAL"
      description   = "WAF for Payment API with rule overrides"
      default_allow = false
      
      rules = [
        {
          enabled  = true
          name     = "AWSManagedRulesCommonRuleSet"
          priority = 0
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesCommonRuleSet"
              vendor_name = "AWS"
              rule_action_override = [
                {
                  name = "SizeRestrictions_QUERYSTRING"
                  action_to_use = {
                    count = true
                    allow = false
                    block = false
                  }
                },
                {
                  name = "NoUserAgent_HEADER"
                  action_to_use = {
                    count = true
                    allow = false
                    block = false
                  }
                }
              ]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        }
      ]
      
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }
}
