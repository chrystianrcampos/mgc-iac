variable "name" {
  description = "Nome da VM"
  type        = string
}

variable "machine_type" {
  description = "Tipo de máquina"
  type        = string
}

variable "image" {
  description = "Imagem do SO"
  type        = string
}

variable "availability_zone" {
  description = "Zona de disponibilidade"
  type        = string
}

variable "ssh_key_name" {
  description = "Nome da chave SSH"
  type        = string
}

variable "security_group_id" {
  description = "ID do security group"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}
