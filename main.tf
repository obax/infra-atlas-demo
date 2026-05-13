terraform {
  # Creates a workspace with these specs when running
  # $ terraform workspace new new-workspace
  cloud {
    organization = "sharebee"
    workspaces {
      tags = ["sharebee-backend-infra"]
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.12"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Owner       = "sharebee"
      TFWorkspace = terraform.workspace
    }
  }
}

locals {
  atlas_region           = replace(upper(var.aws_region), "-", "_")
  vpc_cidr_block         = "10.0.0.0/16"
  vpc_cidr_block_private = "10.0.0.0/24"
  vpc_cidr_block_public  = "10.0.1.0/24"
  atlas_vpc_cidr_range   = "10.8.0.0/21"
  cname_uploads = {
    "next" = "next-uploads-next.sharebee.co.uk"
    "prod" = "uploads.sharebee.co.uk"
  }
  cname_backend = {
    "next" = "s.api"
    "prod" = "api"
  }
  client_host = {
    "next" = "https://next.sharebee.co.uk"
    "prod" = "https://sharebee.co.uk"
  }
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "region-name"
    values = ["${var.aws_region}"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

module "atlas" {
  environment              = var.environment
  source                   = "./modules/atlas"
  name                     = "serverless-${var.environment}"
  region                   = local.atlas_region
  mongodbatlas_public_key  = var.mongodbatlas_public_key
  mongodbatlas_private_key = var.mongodbatlas_private_key
  mongodbatlas_org_id      = var.mongodbatlas_org_id
  mongodbatlas_key_id      = var.mongodbatlas_key_id
  aws_user_role_arn        = module.functions.aws_lambda_role_arn
}

module "aws_networking" {
  source                        = "./modules/aws-networking"
  environment                   = var.environment
  project                       = "serverless-${var.environment}"
  aws_region                    = var.aws_region
  vpc_cidr_block                = local.vpc_cidr_block
  cidr_block_private_cidr_block = local.vpc_cidr_block_private
  cidr_block_public_cidr_block  = local.vpc_cidr_block_public
  zone_ids                      = data.aws_availability_zones.available.names
}
module "atlas_peering" {
  source                   = "./modules/atlas-peering"
  region                   = local.atlas_region
  mongodbatlas_public_key  = var.mongodbatlas_public_key
  mongodbatlas_private_key = var.mongodbatlas_private_key
  route_table_connected    = module.aws_networking.public_route_table
  route_table_cidr_block   = local.vpc_cidr_block_public
  vpc_id                   = module.aws_networking.vpc_id
  atlas_project_id         = module.atlas.project_id
  atlas_cidr_block         = local.atlas_vpc_cidr_range
}

module "functions" {
  source          = "./modules/functions"
  environment     = var.environment
  hostname        = var.domain_root
  aws_region      = var.aws_region
  name            = "api-${var.environment}"
  api_domain_name = "${local.cname_backend[var.environment]}.${var.domain_root}"
  # cname_backend = local.cname_backend
  # project       = "sharebee-backend-${var.environment}"
  vpc_id             = module.aws_networking.vpc_id
  public_subnet_ids  = module.aws_networking.public_subnet_ids
  private_subnet_ids = module.aws_networking.private_subnet_ids
  env_vars = {
    MONGODB_HOSTNAME     = module.atlas.mongo_host
    STRIPE_CLIENT_SECRET = var.env_stripe_client_secret
    CLIENT_HOST          = local.client_host[var.environment]
    ROLLBAR_ACCESS_TOKEN = var.env_rollbar_token
    MAILER_AUTH_PASSWORD = var.env_mailer_password
    JWT_SECRET           = var.env_jwt_secret
    SERVICE_HOST         = "https://${local.cname_backend[var.environment]}.${var.domain_root}"
  }
  inline_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${module.backend-s3.uploads_buckets_id}/*"
      },
    ]
  })
}

module "dns-records" {
  source              = "./modules/dns-records"
  cloudflare_api_key  = var.cloudflare_api_key
  cloudflare_email    = var.cloudflare_email
  cloudflare_zone_id  = var.cloudflare_zone_id
  domain_root         = var.domain_root
  cname_uploads       = local.cname_uploads[var.environment]
  cname_uploads_value = module.backend-s3.uploads_bucket_host
  cname_backend       = local.cname_backend[var.environment]
}

module "backend-s3" {
  source        = "./modules/backend-s3"
  domain_root   = var.domain_root
  cname_uploads = local.cname_uploads[var.environment]
}
