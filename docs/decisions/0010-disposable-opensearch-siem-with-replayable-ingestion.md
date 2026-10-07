# 0010: Use a Disposable OpenSearch SIEM with Replayable Ingestion

## Status
Accepted

## Context
Detection rules are written in Sigma and must be converted, tested, and deployed to a SIEM. Amazon OpenSearch Service fits the project's AWS-native design, and pySigma's OpenSearch backend can convert rules both to Lucene queries and to Piped Processing Language (PPL), including Sigma correlation rules that count events or distinct values over a time window. OpenSearch's Alerting plugin can run PPL queries as scheduled monitors; Amazon documents this for its Optimized engine, while support on standard managed domains is unconfirmed. A managed domain running continuously costs more than the project's monthly budget, even at the smallest instance size. Organization trail logs are retained in S3 in a separate log archive account (0009). Data Prepper, OpenSearch's ingestion tool, reads S3 either from event notifications or by scanning objects within a time range, supports cross-account buckets, and runs as a container or as the managed Amazon OpenSearch Ingestion service.

## Decision
Treat the SIEM as disposable and the S3 log archive as the permanent source of truth. Detection rules are developed and tested against OpenSearch and Data Prepper running as containers, locally and in CI, at no AWS cost. A managed Amazon OpenSearch Service domain and an OpenSearch Ingestion pipeline are created with Terraform only when a live environment is needed, such as for attack simulations or demonstrations, and are destroyed afterward. The same Data Prepper pipeline configuration is used in both environments, reading new log files through SQS notifications and replaying chosen time windows by scanning the log archive. Converted rules are deployed as alerting monitors, using PPL for correlation rules.

## Consequences
- AWS cost for the SIEM is limited to the hours it runs; continuous log storage in S3 remains inexpensive.
- Rules are tested against a real OpenSearch engine in CI rather than a mock, and testing does not depend on the managed domain existing.
- No evidence is lost when the SIEM is destroyed. Any period can be reloaded from the log archive.
- There is no continuous monitoring: activity is detected only while the SIEM is running or when its time window is replayed.
- Each live session requires creating the domain, redeploying rules from Git, and replaying the relevant logs, which adds setup time.
- Scan replay selects files by when they were written to S3, not by event time, so replay windows must be padded to account for CloudTrail delivery delay.
- Container and managed environments can drift apart in version or behavior, so differences must be checked when rules are first run against the managed domain.
- If standard managed domains do not support PPL monitors, correlation rules require either the Optimized engine, at higher hourly cost, or a different deployment path. That would be recorded as a new decision.
