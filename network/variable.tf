variable "project_name" {
  description = "Nome do projeto usado como prefixo em recursos"
  type        = string
}

variable "region" {
  description = "Região da AWS para criar os recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type       = string
}

variable "vpc_additional_cidrs" {
  type        = list(string)
  description = "Lista de CIDR's adicionais da VPC"
  default     = []
}

variable "public_subnets" {
  description = "Mapeamento de subnets públicas"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Mapeamento de subnets privadas com NAT associado"
  type = map(object({
    cidr            = string
    az              = string
    nat_gateway_id  = string
  }))
}

variable "database_subnets" {
  description = "Mapeamento de subnets para bancos de dados"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "azs" {
  description = "Zonas de disponibilidade onde o NAT Gateway será criado"
  type        = set(string)
}
