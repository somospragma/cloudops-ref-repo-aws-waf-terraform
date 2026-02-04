##############################################################
# Outputs para usar los WAF ARNs
##############################################################
output "waf_info" {
  description = "Información de ambas Web ACLs"
  value       = module.waf-vulcano.waf_info
}