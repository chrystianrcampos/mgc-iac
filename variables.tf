variable "api_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "br-se1"
}

variable "key_pair_id" {
  type      = string
  sensitive = true
}

variable "key_pair_secret" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "security_group_description" {
  type = string
}

variable "virtual_machines" {
  type = map(object({
    name              = string
    machine_type      = string
    image             = string
    availability_zone = string
  }))
}

variable "vpc_name" {
  type = string
}

variable "vpc_subnetpool_name" {
  type = string
}

variable "vpc_subnetpool_description" {
  type = string
}

variable "vpc_dns_nameservers" {
  type    = list(string)
  default = ["1.1.1.1", "8.8.8.8"]
}