output "waf_info" {
  value = {for waf in aws_wafv2_web_acl.waf : waf.tags_all.application => {"waf_arn" : waf.arn}}
}