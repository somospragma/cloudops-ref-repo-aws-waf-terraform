output "waf_arns" {
  description = "ARNs of the created WAF Web ACLs"
  value       = module.waf.waf_info
}
