variable "name" {
  description = "Name of the serverless instance"
}

variable "backing_provider" {
  default = "AWS"
}

variable "mongodbatlas_public_key" {
  description = "The MongoDB Atlas API public key"
  type = string
}

variable "mongodbatlas_private_key" {
  description = "The MongoDB Atlas API private key"
  type = string
}

variable "mongodbatlas_org_id" {
  description = "The MongoDB Atlas organization ID"
  type = string
}

variable "region" {}

variable "environment" {
  description = "The environment to deploy to"
}

variable "mongodbatlas_key_id" {
  description = "The MongoDB Atlas API key ID, not the public key"
}

variable "aws_user_role_arn" {
  description = "The ARN of the AWS role used for the authentication"
  type = string
}