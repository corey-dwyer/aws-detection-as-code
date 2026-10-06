# 0005: Authenticate GitHub Actions to AWS via OIDC Federation

## Status
Accepted

## Context
The CI/CD pipeline running in GitHub Actions needs AWS credentials to manage infrastructure. The traditional approach stores an IAM user's access keys as repository secrets. Those keys are long-lived and remain valid until manually revoked, wherever they may have leaked. GitHub Actions can instead act as an OpenID Connect (OIDC) identity provider, issuing a short-lived signed token for each workflow run that AWS can verify and exchange for temporary credentials. How the trust is scoped also matters. Trust policies have commonly matched the token's `sub` claim against repository names, but names can be freed and reused by unrelated parties. GitHub introduced immutable subject claims embedding numeric owner and repository IDs, the default for repositories created after July 15, 2026. This repository issues the new format, so a name-only trust policy would never match.

## Decision
Create an IAM OIDC identity provider for `token.actions.githubusercontent.com` in the project account and a single deploy role, `github-actions-detection-lab-deploy`, assumable only through `sts:AssumeRoleWithWebIdentity`. The role's trust policy requires all of: an audience of `sts.amazonaws.com`; an exact match on the token's `repository_id` claim, pinning trust to this repository's immutable numeric ID; and a `sub` claim matching the `main` branch. The role's permissions start minimal (read/write to the `lab/` prefix of the Terraform state bucket only) and are expanded incrementally, in reviewed changes, as infrastructure is added. Each session name includes the GitHub Actions run ID.

## Consequences
- No long-lived AWS credentials are stored in GitHub. Each run receives temporary credentials that expire automatically, so there is nothing to rotate or leak.
- Trust survives a repository rename but is not inherited by a different repository reusing this name. Deleting and recreating the repository would require updating the trust policy with the new ID.
- The `sub` condition uses a wildcard for the repository portion because identity pinning is handled by `repository_id`. The two conditions must always be kept together; the wildcard alone would be unsafe.
- Workflows on any branch other than `main`, including pull requests from this repository, cannot assume the role. Any CI step needing AWS access before merge (for example a `terraform plan` on pull requests) will require a separate, more restricted role with its own trust conditions.
- Every workflow using the role must explicitly request the `id-token: write` permission.
- The role cannot create any infrastructure until its policy is deliberately expanded, so each new resource type requires an explicit, reviewable permission change.
- CloudTrail entries from CI sessions can be traced to the specific workflow run that created them.
