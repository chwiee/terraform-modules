variable "project_name" {
  description = "Nome do projeto usado como prefixo em recursos"
  type        = string
}

variable "region" {
  description = "Região da AWS para criar os recursos"
  type        = string
}

variable "vpc_block" {
  description = "Bloco de configuração da VPC"
  type = map(object({
    cidr_block             = string
    enabled_dns_support    = bool
    enabled_dns_hostnames  = bool
    tags                   = map(string)
    vpc_additional_cidrs   = optional(list(string), [])
  }))
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

variable "public_subnet_ids" {
  description = "IDs das subnets públicas onde os NAT Gateways serão criados"
  type        = map(string)
}

variable "vpc_id" {
  description = "ID da VPC, caso seja injetada de outro módulo"
  type        = string
}
