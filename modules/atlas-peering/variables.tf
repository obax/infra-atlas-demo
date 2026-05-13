variable "region" {}
variable "mongodbatlas_public_key" {}
variable "mongodbatlas_private_key" {}
variable "route_table_cidr_block" {}
variable "vpc_id" {}
variable "atlas_project_id" {}
variable "aws_account_id" {
  default = "0"
}
variable "backing_provider" {
  default = "AWS"
}

variable route_table_connected {}
variable "atlas_cidr_block" {}