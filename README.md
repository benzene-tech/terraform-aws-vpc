# VPC

Terraform module to create VPC.

## Usage

```terraform
module "vpc" {
  source = "github.com/benzene-tech/vpc?ref=v1.0"

  name_prefix    = "example"
  vpc_cidr_block = "10.0.0.0/24"
}
```
