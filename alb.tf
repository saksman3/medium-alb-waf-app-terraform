#define loadbalancer
resource "aws_lb" "medium_app_alb" {
  name               = "${var.env}-medium-nginx-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.medium_app_alb_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "medium-nginx-app-alb"
#     enabled = true
#   }

  tags = {
    Name = "medium_app_alb"
  }
  depends_on = [aws_lb_target_group_attachment.target]
}

#define target group
resource "aws_lb_target_group" "medium_app_alb_tg" {
    name = "${var.env}-medium-app-alb-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-299"
  }
  depends_on = [aws_instance.medium_app]
}

# define listener
resource "aws_lb_listener" "medium_app_alb_listener"{
    load_balancer_arn = aws_lb.medium_app_alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
    type             = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
    }
   #depends_on = [aws_lb.medium_app_alb]
}
# HTTPS Listener Rule
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.medium_app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.medium_app_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.medium_app_alb_tg.arn
  }
}

# Create Target group target attachment
resource "aws_lb_target_group_attachment" "target" {
  count              = 2
  target_group_arn   = aws_lb_target_group.medium_app_alb_tg.arn
  target_id          = element(aws_instance.medium_app[*].id, count.index)
  port               = 80
  #depends_on = [aws_instance.medium_app]
}

