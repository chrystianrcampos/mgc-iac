terraform {
  required_providers {
    mgc = {
      source = "magalucloud/mgc"
    }
  }
}

resource "mgc_network_vpcs" "vpc" {
  name        = var.vpc_name
}

resource "mgc_network_subnetpools" "vpc_subnetpool" {
  name        = var.subnetpool_name
  description = var.subnetpool_description
  cidr        = "10.0.0.0/16"
}

resource "mgc_network_vpcs_subnets" "vpc_subnet_ipv4_a" {
  cidr_block        = "10.0.1.0/24"
  dns_nameservers   = var.dns_nameservers
  ip_version        = "IPv4"
  name              = "vpc_subnet_ipv4_a"
  subnetpool_id     = mgc_network_subnetpools.vpc_subnetpool.id
  vpc_id            = mgc_network_vpcs.vpc.id
  availability_zone = "br-ne1-a"
}

resource "mgc_network_vpcs_subnets" "vpc_subnet_ipv4_b" {
  cidr_block        = "10.0.2.0/24"
  dns_nameservers   = var.dns_nameservers
  ip_version        = "IPv4"
  name              = "vpc_subnet_ipv4_b"
  subnetpool_id     = mgc_network_subnetpools.vpc_subnetpool.id
  vpc_id            = mgc_network_vpcs.vpc.id
  availability_zone = "br-ne1-b"
}