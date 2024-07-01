resource "aws_security_group" "medium_app_sg" {
  name        = "${var.env}-medium_app_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

#define security group for port 80
resource "aws_security_group_rule" "allow_http_80" {
  security_group_id = aws_security_group.medium_app_sg.id
  type="ingress"
  from_port         = 80
  protocol       = "tcp"
  to_port           = 80
  source_security_group_id = aws_security_group.medium_app_alb_sg.id
}
#define security group for port 22
resource "aws_security_group_rule" "allow_ssh_22" {
  security_group_id = aws_security_group.medium_app_sg.id
  cidr_blocks        = ["0.0.0.0/0"]
  type = "ingress"
  from_port         = 22
  protocol       = "tcp"
  to_port           = 22
}
#define security group egress rule
resource "aws_security_group_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.medium_app_sg.id
  cidr_blocks         = ["0.0.0.0/0"]
  protocol       = "-1"
  to_port           = 0
  from_port = 0
  type = "egress"
}
############ ALB SECURITY GROUP #####################################
resource "aws_security_group" "medium_app_alb_sg" {
  name        = "medium-nginx-app-alb-sg"
  description = "Security group for my Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "medium-nginx-app-alb-sg"
  }
}
########### db cluster security group #####
# resource "aws_security_group" "docdb" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port   = 27017
#     to_port     = 27017
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }