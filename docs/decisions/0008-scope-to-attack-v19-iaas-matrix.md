# 0008: Scope Detection Coverage to the MITRE ATT&CK v19 IaaS Matrix

## Status
Accepted

## Context
This project builds detections for an AWS environment and maps them to MITRE ATT&CK. The coverage claim must be precise and defensible. ATT&CK v19 defines 15 Enterprise tactics, having split Defense Evasion into Stealth and Defense Impairment. Not all of them are observable in an AWS control-plane environment: Reconnaissance and Resource Development mostly occur outside the defender's telemetry, and Command and Control is host and network traffic rather than cloud API activity. ATT&CK's Cloud matrix is broader than this project's environment, as it combines IaaS with SaaS, Office Suite, and Identity Provider platforms such as Microsoft 365. Its IaaS matrix describes cloud infrastructure specifically and contains 12 tactics. The attack simulation tool used in this project covers most, but not all, of those tactics, and some of its technique IDs predate ATT&CK v19.

## Decision
Scope detection coverage to the ATT&CK v19 IaaS matrix. The project commits to at least one detection for each of its 12 tactics, with one technique per tactic as the baseline; additional techniques are optional. Rules are tagged with ATT&CK v19 technique IDs, mapped independently of the simulation tool's labels. Where a technique ID changed in v19, the previous ID is noted in the rule description. Techniques are simulated with an established attack simulation tool where it supports them, and with purpose-written scripts where it does not. Reconnaissance, Resource Development, and Command and Control are out of scope.

## Consequences
- The coverage claim matches a published MITRE matrix exactly, with no project-specific extensions to justify.
- Network- and host-level detection, including Command and Control, is not demonstrated by this project.
- Coverage is pinned to ATT&CK v19. Adopting a later version requires reviewing every rule's mapping and is recorded as a new decision.
- Some tactics require custom simulation scripts, which must be written, tested, and maintained alongside the rules.
- Several techniques are visible only with logging beyond CloudTrail's defaults, such as multi-region trails and S3 data events, which the infrastructure must provide.
- The specific technique chosen for each tactic is recorded in the repository's coverage table rather than in this decision, so a technique can be replaced without superseding it.