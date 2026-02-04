###############################################################
# Variables Globales
###############################################################
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "La región debe tener un formato válido, por ejemplo: us-east-1, eu-west-1, etc."
  }
}

variable "profile" {
  description = "Perfil de AWS CLI a utilizar"
  type        = string
}

variable "environment" {
  description = "Entorno en el que se desplegarán los recursos (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "client" {
  description = "Nombre del cliente o empresa"
  type        = string
  
  validation {
    condition     = length(var.client) > 2 && length(var.client) <= 10
    error_message = "El nombre del cliente debe tener entre 3 y 10 caracteres."
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

# La variable service_name_kms ya no es necesaria ya que se eliminó del módulo

variable "common_tags" {
  description = "Etiquetas comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

###############################################################
# Variables WAF
###############################################################
variable "scope" {
  description = "Scope del WAF (CLOUDFRONT o REGIONAL)"
  type        = string
  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "Scope debe ser CLOUDFRONT o REGIONAL."
  }
}

variable "description" {
  description = "Descripción del WAF"
  type        = string
}

variable "default_allow" {
  description = "Acción por defecto del WAF (true = allow, false = block)"
  type        = bool
  default     = true
}

# AWS Managed Rules
variable "AWSManagedRulesCommonRuleSet" {
  description = "Habilitar AWS Managed Rules Common Rule Set"
  type        = bool
  default     = false
}

variable "AWSManagedRulesKnownBadInputsRuleSet" {
  description = "Habilitar AWS Managed Rules Known Bad Inputs Rule Set"
  type        = bool
  default     = false
}

variable "AWSManagedRulesAmazonIpReputationList" {
  description = "Habilitar AWS Managed Rules Amazon IP Reputation List"
  type        = bool
  default     = false
}

variable "AWSManagedRulesAnonymousIpList" {
  description = "Habilitar AWS Managed Rules Anonymous IP List"
  type        = bool
  default     = false
}

variable "AWSManagedRulesSQLiRuleSet" {
  description = "Habilitar AWS Managed Rules SQLi Rule Set"
  type        = bool
  default     = false
}

# Geo Rules
variable "GeoAllowOnlyColombia" {
  description = "Habilitar regla para permitir solo Colombia"
  type        = bool
  default     = false
}

variable "GeoBlockHighRiskCountries" {
  description = "Habilitar bloqueo de países de alto riesgo"
  type        = bool
  default     = false
}

variable "GeoBlockHighRiskCountries_country_codes" {
  description = "Lista de códigos de países a bloquear"
  type        = list(string)
  default     = ["RU", "CN", "IR", "KP", "VE"]
}

# Custom SQL Injection Protection
variable "CustomSQLiProtection" {
  description = "Habilitar protección personalizada contra SQLi"
  type        = bool
  default     = false
}

variable "CustomSQLi_all_query_match" {
  description = "Aplicar protección SQLi a todos los query parameters"
  type        = bool
  default     = true
}

variable "CustomSQLi_text_transformations" {
  description = "Transformaciones de texto para protección SQLi"
  type        = list(string)
  default     = ["URL_DECODE", "HTML_ENTITY_DECODE"]
}

# Rate Limiting
variable "RateLimitAPIEndpoints" {
  description = "Habilitar rate limiting para endpoints de API"
  type        = bool
  default     = false
}

variable "RateLimitAPIEndpoints_limit" {
  description = "Límite de requests por ventana de evaluación"
  type        = number
  default     = 2000
}

variable "RateLimitAPIEndpoints_evaluation_window_sec" {
  description = "Ventana de evaluación en segundos para rate limiting"
  type        = number
  default     = 300
}

# User Agent Blocking
variable "BlockSuspiciousUserAgents" {
  description = "Habilitar bloqueo de User Agents sospechosos"
  type        = bool
  default     = false
}

variable "BlockSuspiciousUserAgents_positional_constraint" {
  description = "Constraint de posición para búsqueda de User Agent"
  type        = string
  default     = "CONTAINS"
  validation {
    condition = contains([
      "EXACTLY", "STARTS_WITH", "ENDS_WITH", "CONTAINS", "CONTAINS_WORD"
    ], var.BlockSuspiciousUserAgents_positional_constraint)
    error_message = "Constraint debe ser uno de: EXACTLY, STARTS_WITH, ENDS_WITH, CONTAINS, CONTAINS_WORD."
  }
}

variable "BlockSuspiciousUserAgents_single_header" {
  description = "Nombre del header a analizar"
  type        = string
  default     = "user-agent"
}

variable "BlockSuspiciousUserAgents_search_string" {
  description = "String a buscar en el User Agent"
  type        = string
  default     = "suspicious-bot"
}

variable "BlockSuspiciousUserAgents_text_transformations" {
  description = "Transformaciones de texto para análisis de User Agent"
  type        = list(string)
  default     = ["LOWERCASE"]
}

# URI Pattern Blocking
variable "BlockSuspiciousURIs" {
  description = "Habilitar bloqueo de URIs sospechosas"
  type        = bool
  default     = false
}

variable "BlockSuspiciousURIs_regex_strings" {
  description = "Patrones regex para URIs sospechosas"
  type        = list(string)
  default     = [".*\\.php$", ".*\\.aspx$", ".*/wp-admin/.*"]
}

variable "BlockSuspiciousURIs_text_transformations" {
  description = "Transformaciones de texto para análisis de URI"
  type        = list(string)
  default     = ["URL_DECODE", "LOWERCASE"]
}

variable "BlockSuspiciousURIs_uri_path" {
  description = "Analizar el path de la URI"
  type        = bool
  default     = true
}

