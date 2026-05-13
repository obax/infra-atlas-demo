data "aws_availability_zones" "available" {
    state = "available"

    filter {
        name   = "region-name"
        values = ["${var.aws_region}"]
  }
    filter {
        name = "state"
        values = ["available"]
    }
}