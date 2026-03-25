terraform {
  required_providers {
    mgc = {
      source = "magalucloud/mgc"
    }
  }
}

resource "mgc_virtual_machine_instances" "this" {
  name                     = var.name
  machine_type             = var.machine_type
  image                    = var.image
  availability_zone        = var.availability_zone
  allocate_public_ipv4     = true
  creation_security_groups = [var.security_group_id]
  ssh_key_name             = var.ssh_key_name
  vpc_id                   = var.vpc_id
  user_data = base64encode(<<-EOF
    #!/bin/bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker ubuntu
  EOF
  )
}
