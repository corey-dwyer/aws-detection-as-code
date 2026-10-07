# Architecture Decision Records

A short record of significant technical decisions for this project: the situation, what was decided, and the trade-offs. New entries are numbered sequentially and never edited after being merged - a changed decision gets a new entry that supersedes the old one.

- [0001: Isolate AWS-Touching Projects via AWS Organizations](0001-aws-account-per-project-via-organizations.md)
- [0002: Protect `main` with GitHub Rulesets, Signed Commits, and Squash-Only Merges](0002-protect-main-with-rulesets-and-signed-commits.md)
- [0003: Use IAM Identity Center for Human Access to AWS](0003-human-access-via-iam-identity-center.md)
- [0004: Store Terraform State Remotely in S3 with Native Locking](0004-terraform-remote-state-in-s3.md)
- [0005: Authenticate GitHub Actions to AWS via OIDC Federation](0005-github-actions-aws-oidc.md)
- [0006: Apply Privileged Terraform Configurations Manually, Never from CI](0006-manual-apply-for-privileged-terraform.md)
- [0007: Constrain the AI Coding Agent to File Edits, with No Direct Git or AWS Access](0007-ai-agent-boundaries.md)
- [0008: Scope Detection Coverage to the MITRE ATT&CK v19 IaaS Matrix](0008-scope-to-attack-v19-iaas-matrix.md)
