#===================Outputs==============================

output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}

output "db_server_ip" {
  value = aws_instance.db_server.private_ip
}
