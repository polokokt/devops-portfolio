output "alb_dns_name" {
  value       = aws_alb.web_alb.dns_name
  description = "Public DNS of the ALB for accessing the web application"
}
