variable "name_prefix" {
  description = "Prefix to name resources and tags"
  type        = string
  nullable    = false
}

variable "vpc_cidr_block" {
  description = "VPC CIDR"
  type        = string
  nullable    = false
}

variable "additional_public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = null
}

variable "additional_private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = null
}

variable "enable_nat_gateway" {
  description = "Flag to enable or disable NAT gateway"
  type        = bool
  default     = true
  nullable    = false
}
