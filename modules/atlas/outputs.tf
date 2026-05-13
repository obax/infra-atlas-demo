output "mongo_host" {
  value = mongodbatlas_serverless_instance.this.connection_strings_standard_srv
}

output "mongo_user" {
  value = mongodbatlas_database_user.root.username
}

output "project_id" {
  value = mongodbatlas_project.this.id
}