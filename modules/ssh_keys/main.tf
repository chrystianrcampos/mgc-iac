terraform {
  required_providers {
    mgc = {
      source = "magalucloud/mgc"
    }
  }
}

resource "mgc_ssh_keys" "this" {
  name = var.key_name
  key  = var.public_key
}
