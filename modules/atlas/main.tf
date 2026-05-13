terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.6.0"
    }
  }
}

data "tfe_outputs" "common" {
  organization = "sharebee"
  workspace = "infra-common"
}

provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key  = var.mongodbatlas_private_key
}

resource "mongodbatlas_project" "this" {
  name   = "sharebee-serverless-${var.environment}"
  org_id = var.mongodbatlas_org_id
  with_default_alerts_settings = true

  teams {
    team_id = data.tfe_outputs.common.values.atlas_admin_team_id
    role_names = ["GROUP_OWNER", "GROUP_READ_ONLY", "GROUP_DATA_ACCESS_READ_WRITE"]
  }
  api_keys {
    api_key_id = var.mongodbatlas_key_id
    role_names = ["GROUP_OWNER", "GROUP_READ_ONLY", "GROUP_DATA_ACCESS_READ_WRITE"]
  }
}

resource "mongodbatlas_serverless_instance" "this" {
  project_id   = mongodbatlas_project.this.id
  name         = var.name

  provider_settings_backing_provider_name = var.backing_provider
  provider_settings_provider_name = "SERVERLESS"
  provider_settings_region_name = var.region
  depends_on = [
    mongodbatlas_project.this
  ]
}

# data "aws_ip_ranges" "ireland_ec2" {
#   regions  = ["eu-west-1"]
#   services = ["ec2"]
# }

# resource "mongodbatlas_project_ip_access_list" "this" {
#   project_id = mongodbatlas_project.this.id
#   for_each = toset(data.aws_ip_ranges.ireland_ec2.cidr_blocks)
#   cidr_block = each.value
#   comment    = "Instance range for AWS EC2 Ireland"
# }

resource "mongodbatlas_custom_dns_configuration_cluster_aws" "this" {
  project_id    = mongodbatlas_project.this.id
  enabled = true
}

resource "mongodbatlas_database_user" "root" {
  username           = var.aws_user_role_arn
  aws_iam_type       = "ROLE"
  project_id         = mongodbatlas_project.this.id
  auth_database_name = "$external"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}