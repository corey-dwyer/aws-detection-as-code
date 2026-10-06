# 0007: Constrain the AI Coding Agent to File Edits, with No Direct Git or AWS Access

## Status
Accepted

## Context
This project is built with an AI coding agent (Claude Code) running inside the development environment. The agent can edit files and run shell commands, including git and AWS CLI commands, and the environment holds the operator's AWS SSO credentials. During AWS CLI setup, the operator was also offered an MCP server that would let an AI agent call AWS APIs directly using those credentials, triggered by natural-language requests. The project's controls depend on changes being reviewable and attributable: infrastructure changes go through Terraform and pull requests (see 0006), and every commit on `main` is signed (see 0002).

## Decision
The AI coding agent may propose and make file edits only. Every proposed change is reviewed by the operator before it is accepted. All git operations (staging, committing, pushing, opening and merging pull requests) and all AWS and Terraform commands are performed by the operator. The AWS MCP server was declined: no AI agent is given direct access to AWS APIs. These boundaries are configured in the repository's committed Claude Code settings (`.claude/settings.json`), which deny the agent's git history operations, the GitHub CLI, the AWS CLI, and Terraform, and disable the permission modes that skip per-action approval.

## Consequences
- Every AWS change continues to flow through reviewed Terraform code, so there is no unreviewed, ad hoc path from an AI request to a live API call.
- Each signed commit represents a change the operator has reviewed and chosen to commit, keeping authorship and accountability unambiguous.
- Because the settings are committed, the boundary applies automatically in every development environment created from this repository.
- The deny rules are a guardrail, not a security boundary: they match commands as typically written, and an unusual invocation (for example, through another shell) may not match. Per-action approval remains in force as the backstop for anything the rules do not catch. OS-level sandboxing or command-inspection hooks are possible future hardening.
- The agent cannot run Terraform at all, including read-only commands such as `terraform fmt` or `validate`. Development is slower as a result.
- Loosening either boundary (for example, allowing the agent to commit, or granting read-only AWS access) would be recorded as a new decision superseding this one.
- AI used as a feature of the detection pipeline itself, calling a model API from application code, is a separate concern and out of scope here.