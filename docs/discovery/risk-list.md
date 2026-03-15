# Risk List

**Purpose:** Log migration risks and mitigations. Review in planning and before each wave/cutover.

**How to use:** Add rows as risks are identified. Owner = person or team responsible for mitigation. Status = Open / Mitigated / Accepted.

| ID | Risk | Impact | Likelihood | Mitigation | Owner | Status |
|----|------|--------|------------|-------------|-------|--------|
| R1 | Data loss during cutover | High | Medium | Replication + final sync; checksum validation; retain source read-only post-cutover | Platform / DBA | Open |
| R2 | Network bandwidth limits transfer speed | Medium | Medium | Use Partner/Dedicated Interconnect for large data; parallelize Storage Transfer; schedule off-peak | Platform | Open |
| R3 | Application downtime exceeds window | High | Low | Rehearse cutover; runbooks; rollback plan; lower DNS TTL before cutover | App team | Open |
| R4 | Wrong migration order (dependency break) | High | Medium | Dependency map; migrate DB and storage before app; validate connectivity to Cloud SQL and GCS | Platform | Open |
| R5 | Insufficient IAM blocks transfer or DB replication | Medium | Medium | Storage Transfer SA (objectViewer/objectCreator); DMS SA; test in non-prod | Platform | Open |
| R6 | VPN/Interconnect outage during migration | High | Low | Redundant tunnel or Partner Interconnect; runbook for failover | Network / Platform | Open |

**Impact** – High / Medium / Low.  
**Likelihood** – High / Medium / Low.  
**Status** – Open, Mitigated, Accepted (or Closed).
