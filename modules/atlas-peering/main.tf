terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.6.0"
    }
  }
}

provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key  = var.mongodbatlas_private_key
}

data "aws_caller_identity" "current" {}

resource "mongodbatlas_network_container" "this" {
  project_id       = var.atlas_project_id
  atlas_cidr_block = var.atlas_cidr_block
  provider_name    = var.backing_provider
  region_name      = var.region
}

# Create the peering connection request
resource "mongodbatlas_network_peering" "this" {
  accepter_region_name   = var.region
  project_id             = var.atlas_project_id
  container_id           = mongodbatlas_network_container.this.container_id
  provider_name          = var.backing_provider
  route_table_cidr_block = var.route_table_cidr_block
  vpc_id                 = var.vpc_id
  aws_account_id         = data.aws_caller_identity.current.account_id
}

# the following assumes an AWS provider is configured
# Accept the peering connection request
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = mongodbatlas_network_peering.this.connection_id
  auto_accept = true
}

resource "aws_route" "atlas_cidr_block" {
  route_table_id = var.route_table_connected.id
  destination_cidr_block = mongodbatlas_network_container.this.atlas_cidr_block
  vpc_peering_connection_id = mongodbatlas_network_peering.this.connection_id
  depends_on = [
    var.route_table_connected,
    mongodbatlas_network_peering.this
  ]
}