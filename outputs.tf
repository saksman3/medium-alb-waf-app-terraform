output "alb_dns_name" {
  value = aws_lb.medium_app_alb.dns_name
}
output "app_domain"{
  value = aws_route53_record.medium_app_alb_record.name
}

# output "docdb_cluster_endpoint" {
#   value = aws_docdb_cluster.main.endpoint
# }