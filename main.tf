resource "aws_wafv2_web_acl" "waf" {
  # checkov:skip=CKV_AWS_192: Se añade excepción ya que por variables se enviará el valor del parámetro
  for_each    = { for item in var.waf_config : item.application => item }
  name        = join("-", tolist([var.client, var.functionality, var.environment, "waf", each.key]))
  description = each.value["description"]
  scope       = each.value["scope"]
  default_action {
    dynamic "allow" {
      for_each = each.value["default_allow"] ? [1] : []
      content {

      }
    }
    dynamic "block" {
      for_each = !each.value["default_allow"] ? [1] : []
      content {

      }
    }
  }

  dynamic "rule" {
    #for_each = each.value["rules"]
    for_each = [for rule in each.value.rules : rule if rule.enabled == true]
    content {
      name     = rule.value["name"]
      priority = rule.value["priority"]
      dynamic "action" {
        for_each = rule.value["statement"].managed_rule_group_statement.rule_name == null || rule.value["statement"].managed_rule_group_statement.rule_name == "" ? [1] : []
        content {
          dynamic "allow" {
          for_each = rule.value["allow"] ? [1] : []
          content {

          }
        }
        dynamic "block" {
          for_each = !rule.value["allow"] ? [1] : []
          content {

          }
        }
        }
      }


      dynamic "override_action" {
        for_each = rule.value["statement"].managed_rule_group_statement.rule_name != null && rule.value["statement"].managed_rule_group_statement.rule_name != "" ? [1] : []
        content {
          dynamic "count" {
          for_each = rule.value["allow"] ? [1] : []
          content {

          }
        }
        dynamic "none" {
          for_each = !rule.value["allow"] ? [1] : []
          content {

          }
        }
        }
      }
      statement {
        dynamic "ip_set_reference_statement" {
          for_each = rule.value["statement"].ip_set.scope != null &&  rule.value["statement"].ip_set.scope != ""? [rule.value["statement"].ip_set] : []
          content {
            arn = aws_wafv2_ip_set.ip_set["${each.key}-${rule.value["name"]}"].arn
          }
        }
        dynamic "managed_rule_group_statement" {
          for_each = rule.value["statement"].managed_rule_group_statement.rule_name != null && rule.value["statement"].managed_rule_group_statement.rule_name != "" ? [rule.value["statement"].managed_rule_group_statement] : []
          content {
            name        = managed_rule_group_statement.value["rule_name"]
            vendor_name = managed_rule_group_statement.value["vendor_name"]
          }
        }

        dynamic "sqli_match_statement" {
          for_each = rule.value["statement"].sqli_match_statement.text_transformations != null && length(rule.value["statement"].sqli_match_statement.text_transformations) != 0 ? [rule.value["statement"].sqli_match_statement] : []
          content {
            dynamic "field_to_match" {
              for_each = sqli_match_statement.value["all_query_match"] ? [1] : []
              content {
                all_query_arguments {

                }
              }
            }
            dynamic "text_transformation" {
              for_each = sqli_match_statement.value["text_transformations"]
              content {
                priority = index(sqli_match_statement.value["text_transformations"], text_transformation.value) + 1
                type     = text_transformation.value
              }
            }
          }
        }

        dynamic "geo_match_statement" {
          for_each = rule.value["statement"].geo_match_statement.country_codes != null && length(rule.value["statement"].geo_match_statement.country_codes) != 0 ? [rule.value["statement"].geo_match_statement] : []
          content {
            country_codes = geo_match_statement.value["country_codes"]
          }
        }

        dynamic "rate_based_statement" {
          for_each = rule.value["statement"].rate_based_statement.limit >= 0 ? [rule.value["statement"].rate_based_statement] : []
          content {
            limit                 = rate_based_statement.value["limit"]
            evaluation_window_sec = rate_based_statement.value["evaluation_window_sec"]
            aggregate_key_type    = rate_based_statement.value["aggregate_key_type"]
          }
        }

        dynamic "byte_match_statement" {
          for_each = rule.value["statement"].byte_match_statement != null ? [rule.value["statement"].byte_match_statement] : []
          content {
            positional_constraint = byte_match_statement.value["positional_constraint"]
            field_to_match {
              single_header {
                name = byte_match_statement.value["field_to_match"].single_header
              }
            }
            search_string = byte_match_statement.value["search_string"]
            dynamic "text_transformation" {
              for_each = byte_match_statement.value["text_transformations"]
              content {
                priority = index(byte_match_statement.value["text_transformations"], text_transformation.value) + 1
                type     = text_transformation.value
              }
            }
          }
        }

        dynamic "regex_pattern_set_reference_statement" {
          for_each = rule.value["statement"].regex_pattern != null ? [rule.value["statement"].regex_pattern] : []
          content {
            arn = aws_wafv2_regex_pattern_set.regex_pattern["${each.value["application"]}-${rule.value["name"]}"].arn
            field_to_match {
              uri_path {}
            }
            dynamic "text_transformation" {
              for_each = regex_pattern_set_reference_statement.value["text_transformations"]
              content {
                priority = index(regex_pattern_set_reference_statement.value["text_transformations"], text_transformation.value) + 1
                type     = text_transformation.value
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = rule.value["cloudwatch_metrics_enabled"]
        metric_name                = join("-", tolist([var.client, var.functionality, var.environment, "rule","log", rule.value["name"]]))
        sampled_requests_enabled   = rule.value["sampled_requests_enabled"]
      }
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = each.value["cloudwatch_metrics_enabled"]
    metric_name                = join("-", tolist([var.client, var.functionality, var.environment, "waf","log", each.key]))
    sampled_requests_enabled   = each.value["sampled_requests_enabled"]
  }

  tags = merge({ name = join("-", tolist([var.client, var.functionality, var.environment, "waf", each.key])) },
  { application = each.value.application })
}

/*
resource "aws_wafv2_web_acl_logging_configuration" "logs" {
  for_each = { for item in var.waf_config :
    item.application => {
      "application" : item.application
      "destination" : item.destination
    }
  }
  log_destination_configs = each.value["destination"]
  resource_arn            = aws_wafv2_web_acl.waf["each.key"].arn
}
*/

resource "aws_wafv2_ip_set" "ip_set" {
  for_each = { for item in flatten([for waf in var.waf_config : [for rule in waf.rules : {
    "application" : waf.application
    "rule_name" : rule.name
    "ip_set" : rule.statement.ip_set
    } if rule.statement.ip_set.scope != "" && rule.statement.ip_set.scope != null]]): "${item.application}-${item.rule_name}" => item
  }
  name               = join("-", tolist([var.client, var.functionality, var.environment, "ip","set", each.value["rule_name"]]))
  description        = each.value["ip_set"].description
  scope              = each.value["ip_set"].scope
  ip_address_version = each.value["ip_set"].ip_address_version
  addresses          = []

  tags = merge({ name = join("-", tolist([var.client, var.functionality, var.environment, "ip","set", each.value["rule_name"]])) },
  { application = each.value.application })
}


resource "aws_wafv2_regex_pattern_set" "regex_pattern" {
  for_each = { for item in flatten([for waf in var.waf_config : [for rule in waf.rules : {
    "application" : waf.application
    "scope" : waf.scope
    "rule_name" : rule.name
    "regex_strings" : rule.statement.regex_pattern.regex_strings
    } if rule.statement.regex_pattern != null]]): "${item.application}-${item.rule_name}" => item
  }
  name  = join("-", tolist([var.client, var.functionality, var.environment, "pattern", each.value["rule_name"]]))
  scope = each.value["scope"]

  dynamic "regular_expression" {
    for_each = each.value["regex_strings"]
    content {
      regex_string = regular_expression.value
    }
  }
}