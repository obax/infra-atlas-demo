output "mongo_original_host" {
  value = module.atlas.mongo_host
}

output "uploads_bucket_host" {
  value = module.backend-s3.uploads_bucket_host
}