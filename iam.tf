resource "aws_iam_instance_profile" "medium_app_iam_role" {
  name = "${local.name}-role-profile"
  role = aws_iam_role.medium_app_role.name
}

resource "aws_iam_role" "medium_app_role" {
  name = "${local.name}-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Sid       = ""
      }
    ]
  })
}
resource "aws_iam_policy" "ecr_policy" {
  name        = "${local.name}-ecr-policy"
  description = "Allows ECR actions"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ssm:SendCommand"
          
        ]
        Resource = "*"  // Adjust the Resource to limit to specific repositories if necessary
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.medium_app_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.medium_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}