# TODO -- use the same environment variables as ECS

locals {
  lambda_timeout = 3
}

data "archive_file" "dummy_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_payload.zip"

  source {
    content  = "hello"
    filename = "dummy"
  }
}

resource "aws_security_group" "sg_for_lambda" {
  name        = "${var.name}-lamda-sg"
  description = "Lambda SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}LambdaSG"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_lambda_function" "this" {
  filename      = data.archive_file.dummy_lambda.output_path
  function_name = "${var.name}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "handler.handler"
  runtime       = "nodejs16.x"
  publish       = false
  timeout       = local.lambda_timeout
  memory_size   = 512

  tags = {
    "Service" = "Sharebee"
  }

  environment {
    variables = merge({
      LAMBDA_TIMEOUT_MS = local.lambda_timeout * 1000,
      "APP_ENV" : "prod", // TODO -- REVIEW
      "MONGODB_DB_NAME" : "Sharebee",
      "SERVER_PORT" : "3000",
      "SERVICE_NAME" : "sharebee-backend",
      "MAILER_PORT" : "587",
      "MAILER_AUTH_USER" : "apikey", // From Sendgrid
      "MAILER_HOST" : "smtp.sendgrid.net",
      "MAILCHIMP_API_KEY" : "abc-123",
      "MAILCHIMP_LIST_ID" : "def123",
    }, var.env_vars)
  }
}