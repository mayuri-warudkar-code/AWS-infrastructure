output "vpc_id" {
  value = aws_vpc.ionginx_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnets" {
  value = aws_subnet.private_subnet[*].id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.nginx_asg.name
}

output "nginx_dns" {
  value = aws_route53_record.nginx.fqdn
}
