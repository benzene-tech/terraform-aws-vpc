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

variable "subnet_count" {
  description = "Minimum number of each type of subnet (public, private)"
  type        = number
  default     = null

  validation {
    condition     = var.subnet_count != null ? signum(var.subnet_count) == 1 && var.subnet_count % 1 == 0 : true
    error_message = "Subnet count should be a whole number"
  }
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
