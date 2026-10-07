# 0012: Divide Terraform Root Configurations by Apply Mode, Lifecycle, and Account

## Status
Accepted

## Context
This project's infrastructure spans its own account and a separate target account where attack simulations run (see 0009). Terraform applies a root configuration as a whole, and each configuration has its own state key in the shared state bucket (see 0004). Some configurations must only ever be applied by a human operator (see 0006), while others are intended to be applied by CI, whose deploy role can access only the `lab/` prefix of the state bucket (see 0005). The SIEM is created and destroyed repeatedly, while everything else is permanent (see 0010). Grouping resources into configurations by convenience would cause three problems: a configuration mixing human-applied and CI-applied resources would require CI to hold permissions for the privileged ones; a configuration mixing disposable and permanent resources would put the permanent ones at risk on every destroy; and a configuration spanning several accounts widens what a single apply can affect.

## Decision
Each root configuration has a single apply mode (human or CI) and a single lifecycle (permanent or disposable), and by default targets a single account. A configuration spans accounts only when its resources form one tightly coupled unit that cannot be designed or reviewed separately. State keys follow the apply mode: configurations applied by CI keep their state under the `lab/` prefix, and configurations applied by a human keep theirs outside it. The repository has four root configurations:

- `bootstrap/`: the Terraform state bucket. Human-applied, permanent.
- `infra/github-oidc/`: the OIDC provider, the CI deploy role, and the role in the target account that the deploy role assumes. Human-applied, permanent. It spans both accounts because these resources form a single trust chain.
- `infra/lab/target/`: decoy resources in the target account. CI-applied, permanent.
- `infra/lab/siem/`: the OpenSearch domain, the ingestion pipeline, and the queue subscribed to the shared log notification topic. CI-applied, disposable.

Resources created by attack simulation tooling are managed by that tooling, not by this repository's Terraform.

## Consequences
- The deploy role's existing state permissions enforce which configurations CI can apply: it cannot write the state of any human-applied configuration.
- The state prefix restricts only state access. The deploy role's permissions for AWS resources must still be scoped separately so that CI cannot modify resources belonging to human-applied configurations.
- Destroying the SIEM cannot affect permanent resources, because they are not in its state.
- A failed apply or corrupted state is contained to a single configuration.
- Moving a configuration between human and CI application requires moving its state key, which makes the change deliberate and visible.
- The cross-account configuration needs credentials for two accounts in a single apply.
- Configurations depend on each other and must be applied in order: the trust chain before any CI-applied configuration, and the shared security baseline (see 0011) before the SIEM.