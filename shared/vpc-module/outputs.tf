output "vpc_id" {
    value = aws_vpc.dev.id
}

output "cidr_allow_all_traffic" {
    value = var.cidr_allow_all_traffic
}

output "public_subnet_ids" {
    value = aws_subnet.public-subnets[*].id
}

output "private_subnet_ids" {
    value = aws_subnet.private-subnets[*].id
}
