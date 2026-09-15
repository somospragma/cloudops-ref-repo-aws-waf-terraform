##############################################################
# Outputs para usar los WAF ARNs
##############################################################
output "waf_info" {
  description = "Información de ambas Web ACLs"
  value       = module.waf-vulcano.waf_info
}

output "ip_sets_info" {
  description = "Información de los IP Sets creados (ARN, ID y scope)"
  value       = module.waf-vulcano.ip_sets_info
}