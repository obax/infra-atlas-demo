output "uploads_bucket_host" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
}
output "uploads_buckets_id" {
  value = aws_s3_bucket.this.id
}