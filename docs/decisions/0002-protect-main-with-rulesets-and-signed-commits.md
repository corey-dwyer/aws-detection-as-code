# 0002: Protect `main` with GitHub Rulesets, Signed Commits, and Squash-Only Merges

## Status
Accepted

## Context
This is a public, security-focused portfolio repository with a single maintainer. Without enforced rules, nothing stops an accidental direct push to `main`, a force push that rewrites history, or an unsigned commit whose authorship can't be verified. The integrity of the commit history itself matters as much as the code. GitHub offers two mechanisms for enforcing this: classic branch protection rules and Rulesets.

## Decision
Protect the default branch with a single Ruleset (`protect-main`) with an empty bypass list, so the rules apply to the repository owner too. The Ruleset restricts deletions, blocks force pushes, requires linear history, requires signed commits, and requires a pull request (0 approvals, conversation resolution required, squash merge only). At the repository level, squash merging is the only enabled merge method, and merged head branches are deleted automatically.

## Consequences
- Every change reaches `main` through a PR and lands as exactly one signed, verified commit, producing a linear, auditable history.
- Required approvals are 0 because GitHub does not allow approving your own PR; any higher number would make merging impossible for a solo maintainer. PR review is therefore a self-review discipline, not independent review.
- Commits must be signed. GPG verification is enabled for Codespaces on this repository, so commits made there sign automatically. Commits from any environment without signing configured are blocked from merging and must be re-signed.
- Squash merging discards feature-branch history, and git no longer recognizes those branches as merged, so local cleanup requires `git branch -D` rather than `-d`.
- With an empty bypass list there is no emergency shortcut; even urgent fixes go through a PR.
- Required status checks are not yet configured, because GitHub can only require a check after it has run at least once. They will be added once the CI pipeline exists.
