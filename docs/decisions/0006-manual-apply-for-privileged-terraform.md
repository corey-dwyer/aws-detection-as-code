# 0006: Apply Privileged Terraform Configurations Manually, Never from CI

## Status
Accepted

## Context
Two Terraform configurations define this project's security foundation. `bootstrap/` manages the S3 bucket holding every configuration's state (see 0004). `infra/github-oidc/` manages the OIDC provider, deploy role, and permissions that CI uses to access AWS (see 0005). CI is intended to apply infrastructure changes after merge. If CI could also apply these two configurations, any change merged to `main` could widen the deploy role's trust or permissions, or weaken the state bucket's protections, and CI would apply that change using its own credentials. With a single maintainer, pull request review is self-review rather than an independent control, so it cannot be relied on alone to catch such a change.

## Decision
`bootstrap/` and `infra/github-oidc/` are applied only by a human operator from an authenticated terminal session, never by CI. Changes to them still go through pull requests like all other code. The CI deploy role is never granted access to these configurations' state keys, and its permissions must never allow it to modify its own role, its policies, the OIDC provider, or the state bucket's configuration. This is enforced through the deploy role's IAM permissions rather than workflow configuration, because workflow files can be changed by any merged pull request.

## Consequences
- CI cannot escalate its own privileges; widening its access always requires a deliberate human apply.
- Merged changes to these configurations take effect only when the operator applies them. Applies should be run from an up-to-date `main`, so that applied infrastructure always matches reviewed code.
- These configurations have no automated plan or apply, so drift between code and AWS must be checked manually with `terraform plan`.
- When the lab requires IAM resources of its own, the deploy role will need some IAM permissions. Those must be constrained, for example with explicit `Deny` statements or a permissions boundary, so they cannot affect the deploy role, its policies, or the OIDC provider.
- Expanding CI's permissions is deliberately slower, since every expansion is a manual, reviewed change.
