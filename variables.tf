variable "waf_config" {
  type = list(object({
    application   = string
    scope         = string
    description   = string
    default_allow = bool
    rules = list(object({
      enabled = optional(bool, true)
      name     = string
      priority = number
      allow    = bool
      statement = object({
        ip_set = optional(object({
          description = string
          scope = string
          ip_address_version = string
        }),{
          description = ""
          scope = null
          ip_address_version = null
        })
        managed_rule_group_statement = optional(object({
          rule_name   = string
          vendor_name = string
        }),{
          rule_name = null
          vendor_name = null
        })
        sqli_match_statement = optional(object({
          all_query_match      = bool
          text_transformations = list(string)
        }),{
          all_query_match = false
          text_transformations = null
        })
        geo_match_statement = optional(object({
          country_codes = list(string)
        }),{
          country_codes = null
        })
        rate_based_statement = optional(object({
          limit = number
          evaluation_window_sec = optional(number,0)
          aggregate_key_type = optional(string,"")
        }),{
          limit = -1
        })
        byte_match_statement = optional(object({
          positional_constraint = string
          field_to_match = object({
            single_header = string
          })
          search_string = string
          text_transformations = list(string)
        }))
        regex_pattern = optional(object({
          regex_strings  = list(string)
          text_transformations = list(string)
          field_to_match = optional(object({
            uri_path = bool
          }))
        }))
      })
      cloudwatch_metrics_enabled = bool
      sampled_requests_enabled   = bool
    }))
    cloudwatch_metrics_enabled = bool
    sampled_requests_enabled   = bool
  }))
}


variable "functionality" {
  type = string
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}
