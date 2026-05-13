resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:PutObject"]
        Resource = [
          "${aws_s3_bucket.this.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket" "this" {
  bucket        = "${var.cname_uploads}.${var.domain_root}"
  force_destroy = false
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.this.id
  redirect_all_requests_to {
    host_name = "${var.cname_uploads}.${var.domain_root}"
    protocol  = "https"
  }
}
