# VPC
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_a_cidr" {
  type = string
}

variable "public_subnet_b_cidr" {
  type = string
}

variable "private_subnet_a_cidr" {
  type = string
}

variable "private_subnet_b_cidr" {
  type = string
}

# Route 53
variable "r53_public_domain" {
  type = string
}

variable "r53_private_domain" {
  type = string
}

# ALB
variable "allowed_customers_mngr_consumers" {
  type = list(string)
}

# Secrets Manager
variable "db_credentials_username" {
  type      = string
  sensitive = true
}

variable "db_credentials_password" {
  type      = string
  sensitive = true
}
