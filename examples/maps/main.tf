##############################################################
# Modulo WAF - Configuración inteligente
##############################################################
module "waf-vulcano" {
  source = "../../"
  providers = {
    aws.project = aws.principal
  }
  client      = var.client
  project     = var.project
  environment = var.environment

  waf_config = {
    "vulcano-api" = {
      scope         = "REGIONAL"
      description   = "WAF protection for Vulcano API ALB"
      default_allow = true

      rules = [

        {
          enabled  = true
          name     = "AWSManagedRulesCommon"
          priority = 1
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesCommonRuleSet"
              vendor_name = "AWS"
            }
          }
        },
        {
          enabled  = false
          name     = "RateLimitRule"
          priority = 2
          allow    = false
          statement = {
            rate_based_statement = {
              limit = 1000
            }
          }
        },
        {
          enabled  = false
          name     = "SQLInjectionRule"
          priority = 3
          allow    = false
          statement = {
            sqli_match_statement = {
              all_query_match      = true
              text_transformations = ["URL_DECODE"]
            }
          }
        },
        {
          enabled   = false
          name      = "GeoBlockRule"
          priority  = 4
          allow     = false
          statement = {}
        },
        {
          enabled  = true
          name     = "GeoRestrictionsRule"
          priority = 5
          allow    = false
          statement = {
            geo_match_statement = {
              country_codes = ["CN", "RU"]
            }
          }
        }
      ]
    },

    "vulcano-web" = {
      scope         = "CLOUDFRONT"
      description   = "WAF protection for Vulcano Web CloudFront"
      default_allow = true

      rules = [
        {
          enabled  = true
          name     = "AWSManagedRulesCommon"
          priority = 1
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesCommonRuleSet"
              vendor_name = "AWS"
            }
          }
        },
        {
          enabled  = false
          name     = "BotControlRule"
          priority = 2
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesBotControlRuleSet"
              vendor_name = "AWS"
            }
          }
        }
      ]
    }
  }
}

################################################################
# Module WAF - Versión MAP (mucho más limpia)
################################################################
module "waf" {
  source = "../../"
  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  waf_config = {
    "vulcano-bs" = {
      scope         = var.scope
      description   = var.description
      default_allow = var.default_allow

      rules = [
        {
          name     = "AWSManagedRulesCommonRuleSet"
          enabled  = var.AWSManagedRulesCommonRuleSet
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
          name     = "AWSManagedRulesKnownBadInputsRuleSet"
          enabled  = var.AWSManagedRulesKnownBadInputsRuleSet
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

        {
          name     = "AWSManagedRulesAmazonIpReputationList"
          enabled  = var.AWSManagedRulesAmazonIpReputationList
          priority = 2
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesAmazonIpReputationList"
              vendor_name = "AWS"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # AWS Managed Rules - Anonymous IP List
        {
          name     = "AWSManagedRulesAnonymousIpList"
          enabled  = var.AWSManagedRulesAnonymousIpList
          priority = 3
          allow    = false
          statement = {
            managed_rule_group_statement = {
              rule_name   = "AWSManagedRulesAnonymousIpList"
              vendor_name = "AWS"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # AWS Managed Rules - SQL injection prevention
        {
          name     = "AWSManagedRulesSQLiRuleSet"
          enabled  = var.AWSManagedRulesSQLiRuleSet
          priority = 4
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
          enabled  = var.CustomSQLiProtection
          priority = 5
          allow    = false
          statement = {
            sqli_match_statement = {
              all_query_match      = var.CustomSQLi_all_query_match
              text_transformations = var.CustomSQLi_text_transformations
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # Geo-blocking high-risk countries
        {
          name     = "GeoBlockHighRiskCountries"
          enabled  = var.GeoBlockHighRiskCountries
          priority = 6
          allow    = false
          statement = {
            geo_match_statement = {
              country_codes = var.GeoBlockHighRiskCountries_country_codes
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # Rate limiting for API endpoints
        {
          name     = "RateLimitAPIEndpoints"
          enabled  = var.RateLimitAPIEndpoints
          priority = 7
          allow    = false
          statement = {
            rate_based_statement = {
              limit                 = var.RateLimitAPIEndpoints_limit
              evaluation_window_sec = var.RateLimitAPIEndpoints_evaluation_window_sec
              aggregate_key_type    = "IP"
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # Block specific request patterns
        {
          name     = "BlockSuspiciousUserAgents"
          enabled  = var.BlockSuspiciousUserAgents
          priority = 8
          allow    = false
          statement = {
            byte_match_statement = {
              positional_constraint = var.BlockSuspiciousUserAgents_positional_constraint
              field_to_match = {
                single_header = var.BlockSuspiciousUserAgents_single_header
              }
              search_string        = var.BlockSuspiciousUserAgents_search_string
              text_transformations = var.BlockSuspiciousUserAgents_text_transformations
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # Strict geo-restriction allow Colombia only
        {
          name     = "GeoAllowOnlyColombia"
          enabled  = var.GeoAllowOnlyColombia
          priority = 10
          allow    = true
          statement = {
            geo_match_statement = {
              country_codes = ["CO"]
            }
          }
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = true
        },

        # Block specific URI patterns
        {
          name     = "BlockSuspiciousURIs"
          enabled  = var.BlockSuspiciousURIs
          priority = 9
          allow    = false
          statement = {
            regex_pattern = {
              regex_strings        = var.BlockSuspiciousURIs_regex_strings
              text_transformations = var.BlockSuspiciousURIs_text_transformations
              field_to_match = {
                uri_path = var.BlockSuspiciousURIs_uri_path
              }
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
