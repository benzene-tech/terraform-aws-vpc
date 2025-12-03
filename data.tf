data "aws_availability_zones" "this" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
