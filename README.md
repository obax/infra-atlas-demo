# backend-infra

Terraform configuration for the Sharebee backend. Provisions AWS (networking, Lambda-backed API, S3) and Cloudflare DNS, with MongoDB Atlas for the database. State is managed in Terraform Cloud under the `sharebee` organisation.

## Layout

- `main.tf`, `variables.tf`, `outputs.tf` — root module composing the stack
- `modules/atlas` — MongoDB Atlas serverless cluster
- `modules/atlas-peering` — VPC peering between AWS and Atlas
- `modules/aws-networking` — VPC, subnets, gateways
- `modules/backend-s3` — uploads bucket
- `modules/dns-records` — Cloudflare DNS records
- `modules/functions` — Lambda functions and API Gateway

## Usage

Each environment is a Terraform Cloud workspace tagged `sharebee-backend-infra`. Create one with:

```
terraform workspace new <name>
```

Then run `terraform init`, `terraform plan`, `terraform apply` as usual.

Run `terraform fmt` before committing.

## References

- [Remote state data source](https://www.terraform.io/language/state/remote-state-data)
- [Graceful shutdown on AWS](https://circleci.com/blog/graceful-shutdown-using-aws/)
