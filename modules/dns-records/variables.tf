variable "cloudflare_email" {
  default = ""
  type    = string
}
variable "cloudflare_api_key" {
  default = ""
  type    = string
}
variable "cloudflare_zone_id" {
  type = string
  description = "The ID of the Cloudflare zone to create the record in."
}
variable "cname_uploads_value" {
  type = string
}
variable "cname_backend" {
  description = "the subdomain of the backend (usually 'api')"
  type        = string
}
variable "cname_uploads" {
  type = string
}
variable "domain_root" {
  description = "the domain & tld"
  type = string
}
