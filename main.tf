terraform {
  required_providers {
    mgc = {
      source  = "magalucloud/mgc"
      version = "0.46.0"
    }
  }

  backend "s3" {
    bucket = "mgc-iac"
    key    = "terraform/terraform.tfstate"
    region = "auto"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

provider "mgc" {
  api_key         = var.api_key
  region          = var.region
  key_pair_id     = var.key_pair_id
  key_pair_secret = var.key_pair_secret
}

data "mgc_network_vpcs" "default_vpc" {
}

locals {
  default_vpc = [
    for vpc in data.mgc_network_vpcs.default_vpc.items :
    vpc if vpc.name == "vpc_default"
  ][0]
}

module "ssh_keys" {
  source     = "./modules/ssh_keys"
  key_name   = "default-ssh-key"
  public_key = var.ssh_public_key
}

module "security_groups" {
  source      = "./modules/security_groups"
  name        = "default-sg"
  description = "Padrão"
}

module "virtual_machines" {
  source            = "./modules/virtual_machines"
  name              = var.vm_default_name
  machine_type      = var.vm_default_machine_type
  image             = var.vm_default_image
  availability_zone = var.availabiliy_zone
  ssh_key_name      = module.ssh_keys.name
  security_group_id = module.security_groups.id
  vpc_id            = local.default_vpc.id
}

output "vm_ipv4" {
  value = module.virtual_machines.ipv4
}
