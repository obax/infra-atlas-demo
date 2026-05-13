variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas Public Key"
}

variable "environment" {
  description = "the environment to deploy to"
}

variable "mongodbatlas_private_key" {
  description = "PK for Mongo Atlas"
  sensitive   = true
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "mongodbatlas_org_id" {
  description = "Mongo Atlas Org ID"
}

variable "mongodbatlas_key_id" {
  description = "Mongo Atlas API Key ID"
}

# module: dns-records
variable "cloudflare_api_key" {
  type        = string
  description = "The API key for the Cloudflare account."
}
variable "cloudflare_email" {
  type        = string
  description = "The email address for the Cloudflare account."
}
variable "cloudflare_zone_id" {
  type        = string
  description = "The ID of the Cloudflare zone to create the record in."
}
variable "env_stripe_client_secret" {}

variable "env_mailer_password" {}
variable "env_rollbar_token" {}

variable "env_jwt_secret" {
  description = "Preferably a randomly generated string"
  validation {
    condition     = length(var.env_jwt_secret) >= 32
    error_message = "The JWT secret must be at least 32 characters long."
  }
}

variable "domain_root" {
  description = "value of the domain root, e.g. 'sharebee.co.uk'"
}
