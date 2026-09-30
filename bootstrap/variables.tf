variable "aws_profile" {
  description = "AWS CLI/SSO profile for authentication. Left unset in CI, where GitHub Actions' OIDC role is used instead."
  type        = string
  default     = null
}
