# resource "aws_s3_bucket" "lb_logs" {
#   bucket = "medium-nginx-app"  # Change this to a unique bucket name

#   tags = {
#     Name        = "medium-nginx-app-bucket"
#     Environment = "dev"  # Change as necessary
#   }
# }
# # Data source for AWS caller identity
# # data "aws_caller_identity" "current" {}

# # Data source for AWS region
# data "aws_region" "current" {}

# resource "aws_s3_bucket_public_access_block" "lb_logs" {
#   bucket = aws_s3_bucket.lb_logs.id

#   block_public_acls   = true
#   block_public_policy = true
#   ignore_public_acls  = true
#   restrict_public_buckets = true
# }
# resource "aws_s3_bucket_policy" "lb_logs_policy" {
#   bucket = aws_s3_bucket.lb_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect    = "Allow",
#         Principal = {
#           Service = "delivery.logs.amazonaws.com"
#         },
#         Action    = "s3:PutObject",
#         Resource  = "${aws_s3_bucket.lb_logs.arn}/AWSLogs/${aws_s3_bucket.lb_logs.bucket}/*",
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id
#           },
#           ArnLike = {
#             "aws:SourceArn" = "arn:aws:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/${aws_lb.medium_nginx_app_alb.name}/${aws_lb.medium_nginx_app_alb.id}"
#           }
#         }
#       }
#     ]
#   })
# }