variable "vpc_name" {
  description = "Nome da VPC"
  type        = string
}

variable "subnetpool_name" {
  description = "Nome do subnet pool"
  type        = string
}

variable "subnetpool_description" {
  type = string
}

variable "dns_nameservers" {
  description = "Lista de servidores DNS para as subnets"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}
