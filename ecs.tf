# resource "aws_ecs_cluster" "medium_app_cluster" {
#   name = "medium-app-cluster-${var.env}"
# }

# resource "aws_ecs_task_definition" "medium_app_task_definition" {
#   family                   = "medium-app-task"
#   container_definitions    = <<EOF
# [
#   {
#     "name": "medium-app-container-${var.env}",
#     "image": "nginx",
#     "cpu": 125,
#     "memory": 1024,
#     "portMappings": [
#       {
#         "containerPort": 3000,
#         "hostPort": 80,
#         "protocol": "tcp"
#       }
#     ]
#   }
# ]
# EOF
# }

# resource "aws_ecs_service" "medium_app_service" {
#   name            = "medium-app-service-${var.env}"
#   cluster         = aws_ecs_cluster.medium_app_cluster.id
#   task_definition = aws_ecs_task_definition.medium_app_task_definition.arn
#   desired_count   = 2  # Number of tasks/instances
#   launch_type = "EC2"
  
#   load_balancer {
#     elb_name = aws_lb.medium_nginx_app_alb.name
#     container_port = 3000 
#     container_name = "medium-app-container-${var.env}"
#     target_group_arn = aws_lb_target_group.medium_nginx_app_alb_tg.arn
#   }
# }
