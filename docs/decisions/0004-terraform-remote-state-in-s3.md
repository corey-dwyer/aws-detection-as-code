# 0004: Store Terraform State Remotely in S3 with Native Locking

## Status
Accepted

## Context
All AWS infrastructure in this project is managed with Terraform, which records what it manages in a state file. Local state is fragile here: development happens in disposable GitHub Codespaces, so a local state file disappears with the Codespace, and state cannot be committed to git because it may contain sensitive values. A remote backend is needed that survives any single environment and is accessible to both a human operator and CI. Terraform's S3 backend has historically required a separate DynamoDB table for state locking; Terraform 1.10 introduced native locking in S3 itself. Using S3 also creates a bootstrapping problem: the bucket that stores state must itself be created before any configuration can use it.

## Decision
Store all Terraform state in a single, shared S3 bucket in the project account, using S3 native state locking (`use_lockfile`) instead of DynamoDB. A dedicated `bootstrap/` configuration creates the bucket using local state, after which its own state is migrated into that bucket. Every root configuration uses its own state key in the bucket (for example `bootstrap/` and `github-oidc/`). The bucket is versioned, encrypted at rest with S3-managed keys (SSE-S3), blocked from public access, restricted to TLS-only requests by bucket policy, protected from deletion with `prevent_destroy`, and expires noncurrent state versions after 90 days. The bucket name, which contains the account ID, is supplied through a gitignored partial backend configuration rather than committed. Provider lock files are committed.

## Consequences
- State survives the loss of any Codespace and can be used by both the operator and CI.
- Locking requires only S3; there is no DynamoDB table to provision, secure, or pay for. Terraform 1.10 or later is required.
- Separate state keys contain the blast radius of a bad apply or corrupted state to a single configuration, and allow IAM access to be scoped per key prefix.
- Versioning allows recovery from a corrupted or incorrect state file within the 90-day retention window.
- SSE-S3 adds no key-management cost or complexity. If state ever needs to hold application secrets, customer-managed KMS keys should be reconsidered.
- Each `terraform init` requires `-backend-config=backend.hcl`, and the gitignored file must be recreated from its committed `.example` in any fresh environment.
- The bootstrap configuration is a one-time, rarely changed component whose own state lives in the bucket it manages.
