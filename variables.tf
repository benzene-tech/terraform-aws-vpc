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

variable "subnet_tags" {
  description = "Subnet tags"
  type = object({
    public  = optional(map(string), {})
    private = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "enable_nat_gateway" {
  description = "Flag to enable or disable NAT gateway"
  type        = bool
  default     = true
  nullable    = false
}

variable "routes" {
  description = "Routes of route tables"
  type = object({
    public = optional(list(object({
      destination          = string
      gateway_id           = optional(string, null)
      network_interface_id = optional(string, null)
    })), [])
    private = optional(list(object({
      destination          = string
      gateway_id           = optional(string, null)
      network_interface_id = optional(string, null)
    })), [])
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "Tags to be assigned to the resources"
  type        = map(string)
  default     = null
}
