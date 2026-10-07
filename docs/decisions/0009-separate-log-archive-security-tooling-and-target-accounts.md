# 0009: Separate Log Archive, Security Tooling, and Target Accounts

## Status
Accepted. Partially supersedes 0001: this project uses more than one member account.

## Context
ADR 0001 gave each AWS-touching project a single member account. This project runs attack simulations that behave like a real adversary, including stopping logging and deleting data, using administrator credentials. In a single account, those simulations would run alongside the Terraform state bucket, the CI deploy role, and the SIEM, and a sufficiently privileged attacker could tamper with the logs recording their own activity. AWS's Security Reference Architecture separates log storage, security tooling, and workloads into different accounts. CloudTrail organization trails can only be created or changed from the management account or a delegated administrator account; member accounts can see them but cannot stop, modify, or delete them. An organization trail records activity from every account in the Organization. AWS Control Tower can create a similar account structure automatically.

## Decision
Use three accounts in addition to the management account. A log archive account, shared across the Organization, holds only the organization trail's S3 bucket. The existing project account becomes the project's security tooling account: it keeps the Terraform state, the CI trust, and the deploy role, hosts the SIEM and ingestion pipeline, and is the delegated administrator for CloudTrail and GuardDuty. A new target account holds decoy resources and is the only account where attack simulations run. The organization trail is administered from the security tooling account and delivers to the log archive account. The log archive account is placed in a new Security organizational unit, separate from the project accounts in the existing organizational unit, so that each group can receive different service control policies. The structure is built with Terraform rather than AWS Control Tower, so every component is explicit and reviewable. The management account remains administrative only.

## Consequences
- Attack simulations cannot affect the state bucket, the CI trust, or the SIEM, and cannot stop or alter the trail recording them.
- Logs are stored outside both the attacked account and the SIEM's account.
- Every account in the Organization, including the management account and any future project accounts, is logged automatically.
- Logs cross account boundaries twice, from the target to the log archive and from the log archive to the security tooling account. Each crossing needs its own bucket, queue, or role policy, and a misconfiguration can cause logs to stop arriving without an error in the attacked account.
- CI deploys into the target account by assuming a narrowly scoped role there from the existing deploy role. The rule that CI cannot modify its own permissions (0006) extends to that role.
- All accounts are administered by the same person, so the separation protects against a compromised workload but does not provide separation of duties.
- The log archive account is shared infrastructure rather than a project account and is named outside the per-project numbering.
- Organizational units are grouped by the policies their accounts need. The Security organizational unit can carry stricter guardrails than the project accounts, whose target account must permit simulated attacks. Per-project organizational units are not created until a policy needs to apply to a single project.
- More accounts mean more identity assignments, budgets, and cross-account configuration to maintain.
