variable "environment" {
 description = "The environment to deploy to"
}
variable "region" {
  default = "eu-west-1"
}

variable "private_subnet_ids" {
  type = list(string)
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "aws_region" {}

variable "env_vars" {
  type = map(string)
}

variable "vpc_id" {}
variable "hostname" {}

variable "inline_role_policy" {
  type        = string
  description = "Policy document for the lambda function"
}

variable "api_domain_name" {
  description = "The full domain name to deploy this api onto"
}

variable "name" {
  type = string
  description = "The name to give the lambda function"
}