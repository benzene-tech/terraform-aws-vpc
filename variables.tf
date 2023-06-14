variable "name_prefix" {
  description = "Prefix to name resources and tags"
  type        = string
  nullable    = false
}

variable "cidr_block" {
  description = "VPC CIDR"
  type        = string
  nullable    = false
}

variable "public_subnet_tags" {
  description = "Public subnets tags"
  type        = map(string)
  default     = null
}

variable "private_subnet_tags" {
  description = "Private subnets tags"
  type        = map(string)
  default     = null
}

variable "enable_nat_gateway" {
  description = "Flag to enable or disable NAT gateway"
  type        = bool
  default     = true
  nullable    = false
}
