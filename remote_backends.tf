# data "terraform_remote_state" "networking" {
#   backend = "remote"
#   config = {
#     organization = "simfy-africa-pty-ltd"
#     workspaces = {
#       name = "networking-${var.env}"
#     }
#   }
# }

# data "terraform_remote_state" "commons" {
#   backend = "remote"
#   config = {
#     organization = "simfy-africa-pty-ltd"
#     workspaces = {
#       name = "commons-${var.env}"
#     }
#   }
# }