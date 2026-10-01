data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    sid    = "TerraformStateReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket_name}/lab/*",
    ]
  }

  statement {
    sid    = "TerraformStateList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket_name}",
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["lab/*"]
    }
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "github-actions-detection-lab-deploy"
  description = "Starter permissions for GitHub Actions CI. Deliberately minimal — scoped only to the lab/ state prefix. Expand in small, reviewed PRs as real infrastructure is added; bootstrap/ and github-oidc/ state stay off-limits to CI permanently."
  policy      = data.aws_iam_policy_document.github_actions_deploy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}
