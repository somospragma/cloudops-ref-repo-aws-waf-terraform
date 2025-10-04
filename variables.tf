variable "waf_config" {
  type = map(object({
    scope         = string
    description   = string
    default_allow = bool
    rules = list(object({
      enabled  = optional(bool, false)  # DEFAULT: false
      name     = string
      priority = number
      allow    = optional(bool, false)
      statement = object({
        # IP Set - DEFAULT: valores que validen pero indiquen "no usar"
        ip_set = optional(object({
          description        = string
          scope             = string
          ip_address_version = string
        }), {
          description        = ""  # VACÍO = no crear
          scope             = ""   # VACÍO = no crear
          ip_address_version = "IPV4"  # Para validación
        })
        
        # Managed Rule Group - DEFAULT: null = no crear
        managed_rule_group_statement = optional(object({
          rule_name   = string
          vendor_name = string
          rule_action_override = optional(list(object({
            name = string
            action_to_use = object({
              allow = optional(bool, false)
              block = optional(bool, false)
              count = optional(bool, false)
            })
          })), [])
        }), {
          rule_name   = ""  # VACÍO = no crear
          vendor_name = ""  # VACÍO = no crear
          rule_action_override = []
        })
        
        # SQL Injection - DEFAULT: null = no crear
        sqli_match_statement = optional(object({
          all_query_match      = bool
          text_transformations = list(string)
        }), {
          all_query_match      = false
          text_transformations = []  # LISTA VACÍA = no crear
        })
        
        # Geo Match - DEFAULT: null = no crear
        geo_match_statement = optional(object({
          country_codes = list(string)
        }), {
          country_codes = []  # LISTA VACÍA = no crear
        })
        
        # Rate Based - DEFAULT: -1 = no crear
        rate_based_statement = optional(object({
          limit                 = number
          evaluation_window_sec = optional(number, 300)
          aggregate_key_type    = optional(string, "IP")
        }), {
          limit                 = -1  # NEGATIVO = no crear
          evaluation_window_sec = 300
          aggregate_key_type    = "IP"
        })
        
        # Byte Match - DEFAULT: null = no crear
        byte_match_statement = optional(object({
          positional_constraint = string
          field_to_match = object({
            single_header = string
          })
          search_string        = string
          text_transformations = list(string)
        }))  # NULL completo = no crear
        
        # Regex Pattern - DEFAULT: null = no crear
        regex_pattern = optional(object({
          regex_strings        = list(string)
          text_transformations = list(string)
          field_to_match = optional(object({
            uri_path = bool
          }), {
            uri_path = true
          })
        }))  # NULL completo = no crear
      })
      cloudwatch_metrics_enabled = optional(bool, true)
      sampled_requests_enabled   = optional(bool, true)
    }))
    cloudwatch_metrics_enabled = optional(bool, true)
    sampled_requests_enabled   = optional(bool, true)
  }))
  
  validation {
    condition = alltrue([
      for k, waf in var.waf_config : 
      contains(["CLOUDFRONT", "REGIONAL"], waf.scope)
    ])
    error_message = "Scope debe ser CLOUDFRONT o REGIONAL."
  }
}

variable "client" {
  type        = string
  description = "Nombre del cliente"
}

variable "environment" {
  type        = string
  description = "Entorno (dev, qa, pdn)"
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  
  validation {
    condition     = length(var.project) > 2 && length(var.project) <= 15
    error_message = "El nombre del proyecto debe tener entre 3 y 15 caracteres."
  }
}