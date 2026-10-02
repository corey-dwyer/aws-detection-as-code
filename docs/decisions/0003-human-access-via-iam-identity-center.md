# 0003: Use IAM Identity Center for Human Access to AWS

## Status
Accepted

## Context
The AWS Organization (see 0001) separates a management account from per-project member accounts, so a human needs a way to sign in to member accounts for console and CLI work. Three options exist. The root user cannot use the console's Switch Role feature and should be reserved for the few tasks that genuinely require it. IAM users would mean a separate user, password, and MFA device per account, and CLI access through long-lived access keys. IAM Identity Center provides one centrally managed identity with access assignable to any account in the Organization, and issues short-lived credentials for both console and CLI.

## Decision
Enable IAM Identity Center in the management account and use it as the only human access path to member accounts. A single Identity Center user, with its own password and MFA, is granted the `AdministratorAccess` permission set in each project account via an account assignment. CLI access uses `aws configure sso` with a reusable SSO session shared across all project account profiles. No IAM users or static access keys are created for human access, and the root user is not used for day-to-day work.

## Consequences
- No long-lived human credentials exist in any account; console and CLI sessions expire and are renewed with `aws sso login`.
- Onboarding a new project account requires only a new account assignment and CLI profile; the user, permission set, and SSO session are reused.
- `AdministratorAccess` is broad. It is acceptable for a single-operator lab account with no other stakeholders; narrower permission sets are possible future hardening.
- Identity Center's home region (`ap-southeast-2`) is set at enablement and differs from the workload region (`ap-northeast-1`). The two are independent: the home region hosts the identity service, not project resources.
- Machine access (CI/CD) is a separate mechanism and out of scope for this decision.
