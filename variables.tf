variable "environment" {
  description = "The environment to deploy to. Must match a key in the local CNAME and client-host maps in main.tf."
  type        = string
  validation {
    condition     = contains(["next", "prod"], var.environment)
    error_message = "environment must be one of: next, prod."
  }
}

variable "aws_region" {
  description = "AWS region for all regional resources."
  type        = string
  default     = "eu-west-1"
}

variable "domain_root" {
  description = "Root domain, e.g. 'sharebee.co.uk'."
  type        = string
}

variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas API public key."
  type        = string
  sensitive   = true
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas API private key."
  type        = string
  sensitive   = true
}

variable "mongodbatlas_org_id" {
  description = "MongoDB Atlas organisation ID."
  type        = string
}

variable "mongodbatlas_key_id" {
  description = "MongoDB Atlas API key ID (not the public key)."
  type        = string
}

variable "cloudflare_api_key" {
  description = "API key for the Cloudflare account."
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Email address for the Cloudflare account."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "ID of the Cloudflare zone to create the record in."
  type        = string
}

variable "env_stripe_client_secret" {
  description = "Stripe secret API key passed to the API Lambda as STRIPE_CLIENT_SECRET."
  type        = string
  sensitive   = true
}

variable "env_mailer_password" {
  description = "SMTP password passed to the API Lambda as MAILER_AUTH_PASSWORD."
  type        = string
  sensitive   = true
}

variable "env_rollbar_token" {
  description = "Rollbar server access token passed to the API Lambda as ROLLBAR_ACCESS_TOKEN."
  type        = string
  sensitive   = true
}

variable "env_jwt_secret" {
  description = "Secret used to sign JWTs. Preferably a randomly generated string of at least 32 characters."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.env_jwt_secret) >= 32
    error_message = "The JWT secret must be at least 32 characters long."
  }
}
