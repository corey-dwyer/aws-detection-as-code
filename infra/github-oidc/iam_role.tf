resource "aws_iam_role" "github_actions_deploy" {
  name = "github-actions-detection-lab-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud"           = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:repository_id" = "1392220266"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:*:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "github-actions-detection-lab-deploy"
    Purpose = "Assumed by GitHub Actions on main to deploy aws-detection-as-code infrastructure"
  }
}
