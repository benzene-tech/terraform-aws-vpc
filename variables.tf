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

variable "availability_zones_count" {
  description = "Minimum number of availability zones to consider for creating each type of subnets (public, private)"
  type        = number
  default     = null

  validation {
    condition     = var.availability_zones_count != null ? signum(var.availability_zones_count) == 1 && var.availability_zones_count % 1 == 0 : true
    error_message = "Availability zones count should be a whole number"
  }
}

variable "public_subnet_tags" {
  description = "Additional public subnets tags"
  type        = map(string)
  default     = null
}

variable "private_subnet_tags" {
  description = "Additional private subnets tags"
  type        = map(string)
  default     = null
}

variable "enable_nat_gateway" {
  description = "Flag to enable or disable NAT gateway"
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "Tags to be assigned to the resources"
  type        = map(string)
  default     = null
}
