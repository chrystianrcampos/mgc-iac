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
    region = "br-se1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

provider "mgc" {
  api_key         = var.api_key
  region          = var.region
  key_pair_id     = var.key_pair_id
  key_pair_secret = var.key_pair_secret
}

module "vpcs" {
  source                 = "./modules/vpcs"
  vpc_name               = var.vpc_name
  subnetpool_name        = var.vpc_subnetpool_name
  subnetpool_description = var.vpc_subnetpool_description
  dns_nameservers        = var.vpc_dns_nameservers
}

module "ssh_keys" {
  source     = "./modules/ssh_keys"
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

module "security_groups" {
  source            = "./modules/security_groups"
  name              = var.security_group_name
  description       = var.security_group_description
  vpc_subnets_cidrs = module.vpcs.subnet_cidrs
}

module "virtual_machines" {
  source   = "./modules/virtual_machines"
  for_each = var.virtual_machines

  name              = each.value.name
  machine_type      = each.value.machine_type
  image             = each.value.image
  availability_zone = each.value.availability_zone
  ssh_key_name      = module.ssh_keys.name
  security_group_id = module.security_groups.id
  vpc_id            = module.vpcs.vpc_id
}

output "vm_ipv4s" {
  value = { for k, vm in module.virtual_machines : k => vm.ipv4 }
}
