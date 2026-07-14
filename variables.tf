variable "name" {
  description = "Name resources or add as tag"
  type        = string
  nullable    = false
}

variable "cidr_block" {
  description = "VPC CIDR"
  type        = string
  nullable    = false
}

variable "subnet_tags" {
  description = "Subnet tags"
  type = object({
    private   = optional(map(string), {})
    protected = optional(map(string), {})
    public    = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "Tags to be assigned to the resources"
  type        = map(string)
  default     = null
}
