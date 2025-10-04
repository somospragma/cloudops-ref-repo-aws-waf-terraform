resource "aws_wafv2_web_acl" "waf" {
  provider            = aws.project
  for_each    = var.waf_config
  name        = join("-", [var.client, var.project, var.environment, "waf", each.key])
  description = each.value.description
  scope       = each.value.scope
  
  default_action {
    dynamic "allow" {
      for_each = each.value.default_allow ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = !each.value.default_allow ? [1] : []
      content {}
    }
  }

  dynamic "rule" {
    for_each = [for rule in each.value.rules : rule if rule.enabled == true]
    content {
      name     = rule.value.name
      priority = rule.value.priority
      
      # LÓGICA: Solo action si NO es managed rule
      dynamic "action" {
        for_each = rule.value.statement.managed_rule_group_statement.rule_name == "" ? [1] : []
        content {
          dynamic "allow" {
            for_each = rule.value.allow ? [1] : []
            content {}
          }
          dynamic "block" {
            for_each = !rule.value.allow ? [1] : []
            content {}
          }
        }
      }

      # LÓGICA: Solo override_action si ES managed rule
      dynamic "override_action" {
        for_each = rule.value.statement.managed_rule_group_statement.rule_name != "" ? [1] : []
        content {
          dynamic "count" {
            for_each = rule.value.allow ? [1] : []
            content {}
          }
          dynamic "none" {
            for_each = !rule.value.allow ? [1] : []
            content {}
          }
        }
      }
      
      statement {
        # SOLO crear si scope NO está vacío
        dynamic "ip_set_reference_statement" {
          for_each = rule.value.statement.ip_set.scope != "" ? [rule.value.statement.ip_set] : []
          content {
            arn = aws_wafv2_ip_set.ip_set["${each.key}-${rule.value.name}"].arn
          }
        }
        
        # SOLO crear si rule_name NO está vacío
        dynamic "managed_rule_group_statement" {
          for_each = rule.value.statement.managed_rule_group_statement.rule_name != "" ? [rule.value.statement.managed_rule_group_statement] : []
          content {
            name        = managed_rule_group_statement.value.rule_name
            vendor_name = managed_rule_group_statement.value.vendor_name
            
            dynamic "rule_action_override" {
              for_each = managed_rule_group_statement.value.rule_action_override
              content {
                name = rule_action_override.value.name
                action_to_use {
                  dynamic "allow" {
                    for_each = rule_action_override.value.action_to_use.allow ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = rule_action_override.value.action_to_use.block ? [1] : []
                    content {}
                  }
                  dynamic "count" {
                    for_each = rule_action_override.value.action_to_use.count ? [1] : []
                    content {}
                  }
                }
              }
            }
          }
        }

        # SOLO crear si transformations NO está vacía
        dynamic "sqli_match_statement" {
          for_each = length(rule.value.statement.sqli_match_statement.text_transformations) > 0 ? [rule.value.statement.sqli_match_statement] : []
          content {
            dynamic "field_to_match" {
              for_each = sqli_match_statement.value.all_query_match ? [1] : []
              content {
                all_query_arguments {}
              }
            }
            dynamic "text_transformation" {
              for_each = sqli_match_statement.value.text_transformations
              content {
                priority = index(sqli_match_statement.value.text_transformations, text_transformation.value) + 1
                type     = text_transformation.value
              }
            }
          }
        }

        # SOLO crear si country_codes NO está vacía
        dynamic "geo_match_statement" {
          for_each = length(rule.value.statement.geo_match_statement.country_codes) > 0 ? [rule.value.statement.geo_match_statement] : []
          content {
            country_codes = geo_match_statement.value.country_codes
          }
        }

        # SOLO crear si limit es positivo
        dynamic "rate_based_statement" {
          for_each = rule.value.statement.rate_based_statement.limit > 0 ? [rule.value.statement.rate_based_statement] : []
          content {
            limit                 = rate_based_statement.value.limit
            evaluation_window_sec = rate_based_statement.value.evaluation_window_sec
            aggregate_key_type    = rate_based_statement.value.aggregate_key_type
          }
        }

        # SOLO crear si NO es null
        dynamic "byte_match_statement" {
          for_each = rule.value.statement.byte_match_statement != null ? [rule.value.statement.byte_match_statement] : []
          content {
            positional_constraint = byte_match_statement.value.positional_constraint
            field_to_match {
              single_header {
                name = byte_match_statement.value.field_to_match.single_header
              }
            }
            search_string = byte_match_statement.value.search_string
            dynamic "text_transformation" {
              for_each = byte_match_statement.value.text_transformations
              content {
                priority = index(byte_match_statement.value.text_transformations, text_transformation.value) + 1
                type     = text_transformation.value
              }
            }
          }
        }

        # SOLO crear si NO es null
        dynamic "regex_pattern_set_reference_statement" {
          for_each = rule.value.statement.regex_pattern != null ? [rule.value.statement.regex_pattern] : []
          content {
            arn = aws_wafv2_regex_pattern_set.regex_pattern["${each.key}-${rule.value.name}"].arn
            field_to_match {
              uri_path {}
            }
            dynamic "text_transformation" {
              for_each = regex_pattern_set_reference_statement.value.text_transformations
              content {
                priority = index(regex_pattern_set_reference_statement.value.text_transformations, text_transformation.value) + 1
                type     = text_transformation.value
              }
            }
          }
        }
      }
      
      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = join("-", [var.client, var.project, var.environment, "rule", "log", rule.value.name])
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }
  
  visibility_config {
    cloudwatch_metrics_enabled = each.value.cloudwatch_metrics_enabled
    metric_name                = join("-", [var.client, var.project, var.environment, "waf", "log", each.key])
    sampled_requests_enabled   = each.value.sampled_requests_enabled
  }

  tags = merge(
    { name = join("-", [var.client, var.project, var.environment, "waf", each.key]) },
    { application = each.key }
  )
}

# SOLO crear IP Sets si scope NO está vacío Y regla está habilitada
resource "aws_wafv2_ip_set" "ip_set" {
  provider            = aws.project
  for_each = { for item in flatten([
    for waf_key, waf in var.waf_config : [
      for rule in waf.rules : {
        "application" : waf_key
        "rule_name" : rule.name
        "ip_set" : rule.statement.ip_set
      } if rule.statement.ip_set.scope != "" && 
           rule.enabled == true
    ]
  ]) : "${item.application}-${item.rule_name}" => item }
  
  name               = join("-", [var.client, var.project, var.environment, "ip", "set", each.value.rule_name])
  description        = each.value.ip_set.description
  scope              = each.value.ip_set.scope
  ip_address_version = each.value.ip_set.ip_address_version
  addresses          = []

  tags = merge(
    { name = join("-", [var.client, var.project, var.environment, "ip", "set", each.value.rule_name]) },
    { application = each.value.application }
  )
}

# SOLO crear Regex Patterns si NO es null Y regla está habilitada
resource "aws_wafv2_regex_pattern_set" "regex_pattern" {
  provider            = aws.project
  for_each = { for item in flatten([
    for waf_key, waf in var.waf_config : [
      for rule in waf.rules : {
        "application" : waf_key
        "scope" : waf.scope
        "rule_name" : rule.name
        "regex_strings" : rule.statement.regex_pattern.regex_strings
      } if rule.statement.regex_pattern != null && 
           rule.enabled == true
    ]
  ]) : "${item.application}-${item.rule_name}" => item }
  
  name  = join("-", [var.client, var.project, var.environment, "pattern", each.value.rule_name])
  scope = each.value.scope

  dynamic "regular_expression" {
    for_each = each.value.regex_strings
    content {
      regex_string = regular_expression.value
    }
  }
  
  tags = merge(
    { name = join("-", [var.client, var.project, var.environment, "pattern", each.value.rule_name]) },
    { application = each.value.application }
  )
}