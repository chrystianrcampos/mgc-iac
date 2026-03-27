output "vpc_id" {
  value = mgc_network_vpcs.vpc.id
}

output "subnet_cidrs" {
  value = [
    mgc_network_vpcs_subnets.vpc_subnet_ipv4_a.cidr_block,
    mgc_network_vpcs_subnets.vpc_subnet_ipv4_b.cidr_block,
  ]
}
