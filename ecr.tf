resource "aws_ecr_repository" "mediuma_app_ecr" {
  name = "medium-app-repo"  # Replace with your desired ECR repository name

  # Optionally,configure lifecycle policies, tags, etc.
  image_tag_mutability = "MUTABLE"  # Default is "MUTABLE"
  force_delete = true
 
}