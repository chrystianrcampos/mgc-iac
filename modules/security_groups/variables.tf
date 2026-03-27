variable "name" {
  description = "Nome do security group"
  type        = string
}

variable "description" {
  description = "Descrição do security group"
  type        = string
}

variable "vpc_subnets_cidrs" {
  type = list(string)
}
