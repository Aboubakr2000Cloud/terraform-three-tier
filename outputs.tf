output "alb_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "rds_endpoint" {
  value     = module.rds.rds_endpoint
  sensitive = true
}

output "asg_name" {
  value = module.asg.asg_name
}
