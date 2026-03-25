variable "api_key" {
  description = "Chave de API da Magalu Cloud"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Região da Magalu Cloud"
  type        = string
  default     = "br-se1"
}

variable "availabiliy_zone" {
  description = "Zona de disponibilidade "
}

variable "key_pair_id" {
  description = "ID do par de chaves para autenticação"
  type        = string
  sensitive   = true
}

variable "key_pair_secret" {
  description = "Segredo do par de chaves para autenticação"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Chave pública SSH"
  type        = string
}

variable "vm_default_name" {
  description = "Nome padrão para VM"
  type        = string
}

variable "vm_default_machine_type" {
  description = "Tipo de máquina padrão para VM"
  type        = string
}

variable "vm_default_image" {
  description = "Imagem padrão para VMs"
  type        = string
}