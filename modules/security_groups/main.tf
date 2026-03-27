terraform {
  required_providers {
    mgc = {
      source = "magalucloud/mgc"
    }
  }
}

resource "mgc_network_security_groups" "this" {
  name                  = var.name
  description           = var.description
  disable_default_rules = true
}

resource "mgc_network_security_groups_rules" "allow_ssh" {
  description       = "Permite tráfego SSH de entrada de toda internet via IPv4"
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_ssh_ipv6" {
  description       = "Permite tráfego SSH de entrada de toda internet via IPv6"
  direction         = "ingress"
  ethertype         = "IPv6"
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "::/0"
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_http" {
  description       = "Permite tráfego HTTP de entrada de toda internet via IPv4"
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = 80
  port_range_min    = 80
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_http_ipv6" {
  description       = "Permite tráfego HTTP de entrada de toda internet via IPv6"
  direction         = "ingress"
  ethertype         = "IPv6"
  port_range_max    = 80
  port_range_min    = 80
  protocol          = "tcp"
  remote_ip_prefix  = "::/0"
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_https" {
  description       = "Permite tráfego HTTPS de entrada de toda internet via IPv4"
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = 443
  port_range_min    = 443
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_https_ipv6" {
  description       = "Permite tráfego HTTPS de entrada de toda internet via IPv6"
  direction         = "ingress"
  ethertype         = "IPv6"
  port_range_max    = 443
  port_range_min    = 443
  protocol          = "tcp"
  remote_ip_prefix  = "::/0"
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_icmp" {
  for_each = toset(var.vpc_subnets_cidrs)

  description       = "Permite ICMP de entrada da subnet ${each.value}"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_egress" {
  description       = "Permite tráfego de saída de toda internet via IPv4"
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.this.id
}

resource "mgc_network_security_groups_rules" "allow_egress_ipv6" {
  description       = "Permite tráfego de saída de toda internet via IPv6"
  direction         = "egress"
  ethertype         = "IPv6"
  remote_ip_prefix  = "::/0"
  security_group_id = mgc_network_security_groups.this.id
}
