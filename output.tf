output "waf_info" {
  description = "Información de las Web ACLs creadas"
  value = {
    for waf_key, waf in aws_wafv2_web_acl.waf : waf_key => {
      "waf_arn" = waf.arn
      "waf_id"  = waf.id
      "scope"   = waf.scope
    }
  }
}

output "ip_sets_info" {
  description = "Información de los IP Sets creados"
  value = {
    for ip_set_key, ip_set in aws_wafv2_ip_set.ip_set : ip_set_key => {
      "arn"   = ip_set.arn
      "id"    = ip_set.id
      "scope" = ip_set.scope
    }
  }
}

output "regex_patterns_info" {
  description = "Información de los Regex Pattern Sets creados"
  value = {
    for regex_key, regex in aws_wafv2_regex_pattern_set.regex_pattern : regex_key => {
      "arn"   = regex.arn
      "id"    = regex.id
      "scope" = regex.scope
    }
  }
}