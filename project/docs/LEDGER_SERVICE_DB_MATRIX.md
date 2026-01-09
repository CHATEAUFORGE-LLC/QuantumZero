# Service-to-data responsibility matrix

**Version:** 1.0  
**Related Issue:** [#27](https://github.com/CHATEAUFORGE-LLC/QuantumZero/issues/27)  
**Last Updated:** 12.30.25 

## Legend
* `R` = Read
* `W` = Write
* `RW` = Read + Write
* `-` = Not used

| Component / Service | Indy Ledger (NYM / SCHEMA / CRED_DEF / REV_REG_*) | Trusted Registry DB (issuer / policy / templates) | Offline Cache (offline_cache_*) | Audit (audit_event) |
|---------------------|--------------------------------------------------|---------------------------------------------------|----------------------------------|---------------------|
| Issuance Service | RW (publish schema/cred-def/rev-reg-def as needed) | R (allowed issuers, allowed artifacts, templates) | — | W (ledger/admin/system event; no holder refs) |
| Verification Service | R (read schema/cred-def; check revocation every verify) | R (trust policy allow-lists; issuer status; template expectations) | R (only for offline verification mode) | W (system/verification outcome without holder identifiers) |
| Revocation Service | RW (write REV_REG_ENTRY updates; read current registry state) | R (revocation governance/allowed artifacts) | — | W (ledger/system event; no holder refs) |
| Admin UI / Admin API | — | RW (manage issuers, policies, templates, endpoints, roles) | W (trigger cache builds / publish packages) | RW (review + write admin events) |
| Offline Cache Exporter | — (typically uses ledger reads via verifier svc or direct client) | R (policy/templates + issuer metadata) | RW (generate signed packages + items) | W (system/admin event) |
| Ledger Observer / Indexer (optional) | R (poll/subscribe ledger for refs/snapshots) | — | W (populate revocation snapshots or ledger_ref items) | W (system event) |

