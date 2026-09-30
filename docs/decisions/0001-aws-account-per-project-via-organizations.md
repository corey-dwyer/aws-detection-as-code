# 0001: Isolate AWS-Touching Projects via AWS Organizations

## Status
Accepted

## Context
This is the first of several portfolio repositories, with more AWS-touching projects planned. A single shared AWS account would let a misconfiguration or leaked credential in one project affect the others, makes per-project cost attribution hard, and doesn't reflect how professional AWS environments are actually structured.

## Decision
Create an AWS Organization with a dedicated management account that never runs project workloads, and one dedicated member account per AWS-touching project, grouped under a cv-projects Organizational Unit.

## Consequences
- Blast radius of any project is contained to its own account.
- Per-account billing makes cost attribution simpler.
- Each new project costs about 10 minutes of setup overhead (account + email alias + Identity Center assignment).
- The management account's root user cannot use the console's "Switch Role" feature - this is why IAM Identity Center (ADR 0003) is the access mechanism.
- Creating the Organization triggered an automatic, irreversible upgrade from AWS's credit-capped "Free Plan" to standard "Paid Plan" billing on the management account. This is worth knowing before repeating this pattern for future projects.
