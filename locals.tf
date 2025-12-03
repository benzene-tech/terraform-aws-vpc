locals {
  availability_zones_count = length(data.aws_availability_zones.this.names)

  # Calculate the VPC size
  vpc_size = pow(2, 32 - tonumber(split("/", var.cidr_block)[1]))

  # Calculate group allocations
  group_size = {
    private   = local.vpc_size / 2 # 50%
    protected = local.vpc_size / 4 # 25%
    public    = local.vpc_size / 4 # 25%
  }

  # Calculate size per subnet within each group
  subnet_size = {
    private   = local.group_size.private / local.availability_zones_count
    protected = local.group_size.protected / local.availability_zones_count
    public    = local.group_size.public / local.availability_zones_count
  }

  # Calculate prefix lengths for each subnet type
  # prefix_length = 32 - log2(subnet_size)
  prefix_length = {
    private   = 32 - floor(log(local.subnet_size.private, 2))
    protected = 32 - floor(log(local.subnet_size.protected, 2))
    public    = 32 - floor(log(local.subnet_size.public, 2))
  }

  # Calculate newbits for each group's base allocation
  group_newbit = {
    private   = ceil(log(100 / 50, 2))
    protected = ceil(log(100 / 25, 2))
    public    = ceil(log(100 / 25, 2))
  }

  # Calculate base CIDR blocks for each group
  # Private gets first half (netnum = 0)
  # Protected gets first quarter of second half (netnum = 2)
  # Public gets second quarter of second half (netnum = 3)
  subnet_base_cidrs = {
    private   = cidrsubnet(var.cidr_block, local.group_newbit.private, 0)
    protected = cidrsubnet(var.cidr_block, local.group_newbit.protected, pow(2, local.group_newbit.private))
    public    = cidrsubnet(var.cidr_block, local.group_newbit.public, pow(2, local.group_newbit.private) + 1)
  }

  # Calculate newbits for subnets within each group
  # This is the difference between the group's prefix and the subnet's prefix
  subnet_base_prefix = {
    private   = tonumber(split("/", local.subnet_base_cidrs.private)[1])
    protected = tonumber(split("/", local.subnet_base_cidrs.protected)[1])
    public    = tonumber(split("/", local.subnet_base_cidrs.public)[1])
  }

  subnet_newbits = {
    private   = local.prefix_length.private - local.subnet_base_prefix.private
    protected = local.prefix_length.protected - local.subnet_base_prefix.protected
    public    = local.prefix_length.public - local.subnet_base_prefix.public
  }

  # Generate subnet CIDR blocks for each group
  # Using sequential netnum values ensures full coverage with no gaps
  subnet_cidrs = {
    for subnet_type in keys(local.subnet_base_cidrs) : subnet_type => zipmap(
      data.aws_availability_zones.this.names,
      [for i in range(local.availability_zones_count) : cidrsubnet(local.subnet_base_cidrs[subnet_type], local.subnet_newbits[subnet_type], i)]
    )
  }
}
