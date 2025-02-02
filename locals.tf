locals {
  name        = "${var.env}-${var.product}"
  account_id  = data.aws_caller_identity.current.account_id
  tags = {
    Name    = local.name
    Env     = var.env
    Product = var.product
  }
}