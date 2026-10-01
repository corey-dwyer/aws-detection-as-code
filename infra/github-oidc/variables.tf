variable "aws_profile" {
  description = "AWS CLI/SSO profile for authentication. Left unset in the rare case this ever ran in CI — it won't, by design (see ADR)."
  type        = string
  default     = null
}

variable "tf_state_bucket_name" {
  description = "Name of the shared Terraform state bucket (created in bootstrap/). Needed so the deploy role's policy can be scoped to it without hardcoding the account ID into a committed file."
  type        = string
}
