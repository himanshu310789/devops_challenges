/*
    AWS Resource Output
*/

# Public LB DNS
output "DNS_NAME" {
  description = "ALB DNS name"
  value       = aws_lb.alb.dns_name
}
