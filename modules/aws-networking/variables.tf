variable "environment" {
    description = "The environment to deploy into, e.g. dev, test, prod"
}
variable "project" {}
variable "aws_region" {}
variable "vpc_cidr_block" {}
variable "cidr_block_private_cidr_block" {}
variable "cidr_block_public_cidr_block" {}
variable "zone_ids" {}