# QuantumZero Diagram Index (Deliverable #1)

**Project:** QuantumZero - Decentralized Zero-Trust Identity Wallet  
**Scope:** Unified UML/DFD set for QuantumZero-mobile (Flutter/Dart) and QuantumZero-server (Rust/Actix-Web + Indy) proof of concept  
**Notation References (required):**
- UML Class Diagram Tutorial: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/uml-class-diagram-tutorial/
- UML Diagrams Reference: https://www.uml-diagrams.org/
- DFD (Yourdon) Tutorial: https://online.visual-paradigm.com/knowledge/software-design/dfd-tutorial-yourdon-notation
- Mermaid Notation - Sequence: https://mermaid.ai/open-source/syntax/sequenceDiagram.html
- Mermaid Notation - Class: https://mermaid.ai/open-source/syntax/classDiagram.html
- Mermaid Notation - Entity Relationship: https://mermaid.ai/open-source/syntax/entityRelationshipDiagram.html
- Mermaid Notation - Flowchart: https://mermaid.ai/open-source/syntax/flowchart.html
- Mermaid Notation - C4 Component Diagram: https://mermaid.ai/open-source/syntax/c4.html#c4-component-diagram-c4component
**Metadata Location (required):** All narratives, priorities (A/B/C), preconditions, triggers, post-conditions, and actor descriptions are centralized in `DIAGRAMS.md`.

---

## Use Case Diagrams (UML)
- `diagrams/usecase-mobile-app-unlock.puml`
- `diagrams/usecase-mobile-external-authentication.puml`
- `diagrams/usecase-mobile-prove-fact.puml`
- `diagrams/usecase-server-admin-management.puml`
- `diagrams/usecase-server-api-suite.puml`

## Data Flow Diagrams (DFD - Gane-Sarson)
### Admin Registry System
- `diagrams/dfd-server-admin-registry-L0.mmd` (Level 0 - Context)
- `diagrams/dfd-server-admin-registry-L1.mmd` (Level 1 - Manage Issuers)
- `diagrams/dfd-server-admin-registry-L1-schemas.mmd` (Level 1 - Manage Schemas)
- `diagrams/dfd-server-admin-registry-L1-cred-defs.mmd` (Level 1 - Manage Credential Definitions)
- `diagrams/dfd-server-admin-registry-L1-sync.mmd` (Level 1 - Sync From Ledger)
- `diagrams/dfd-server-admin-registry-L1-audit.mmd` (Level 1 - Audit Logging)

### Ledger Query & Monitoring System
- `diagrams/dfd-server-ledger-queries-L0.mmd` (Level 0 - Context)
- `diagrams/dfd-server-ledger-queries-L1.mmd` (Level 1 - Health & Metrics Monitoring)
- `diagrams/dfd-server-ledger-queries-L1-pool-nodes.mmd` (Level 1 - Query Pool Nodes)
- `diagrams/dfd-server-ledger-queries-L1-import-schema.mmd` (Level 1 - Import Schema By ID)
- `diagrams/dfd-server-ledger-queries-L1-sync.mmd` (Level 1 - Full Ledger Sync)
- `diagrams/dfd-server-ledger-queries-L2-sync.mmd` (Level 2 - Full Ledger Sync Detailed)

### Trust Registry Administration System
- `diagrams/dfd-server-trust-registry-admin-L0.mmd` (Level 0 - Context)
- `diagrams/dfd-server-trust-registry-admin-L1.mmd` (Level 1 - Issuer Onboarding)
- `diagrams/dfd-server-trust-registry-admin-L1-schema-requests.mmd` (Level 1 - Approve Schema Requests)
- `diagrams/dfd-server-trust-registry-admin-L1-cred-def-requests.mmd` (Level 1 - Approve Cred Def Requests)
- `diagrams/dfd-server-trust-registry-admin-L1-policy.mmd` (Level 1 - Manage Trust Policies)
- `diagrams/dfd-server-trust-registry-admin-L1-audit.mmd` (Level 1 - Audit Logging)
- `diagrams/dfd-server-trust-registry-admin-L2-issuer.mmd` (Level 2 - Issuer Onboarding Detailed)
- `diagrams/dfd-server-trust-registry-admin-L2-policy.mmd` (Level 2 - Manage Trust Policies Detailed)

## Class Diagrams (UML)
- `diagrams/class-mobile-models.mmd`
- `diagrams/class-mobile-repositories.mmd`
- `diagrams/class-mobile-services.mmd`
- `diagrams/class-mobile-state-management.mmd`
- `diagrams/class-mobile-qr.mmd`
- `diagrams/class-mobile-selective-disclosure.mmd`
- `diagrams/class-mobile-ui-screens.mmd`
- `diagrams/class-server-models.mmd`
- `diagrams/class-server-models-admin-api.mmd`
- `diagrams/class-server-models-issuance-api.mmd`
- `diagrams/class-server-models-revocation-api.mmd`
- `diagrams/class-server-models-verification-api.mmd`
- `diagrams/class-server-models-common.mmd`
- `diagrams/class-server-handlers.mmd`
- `diagrams/class-server-issuance-handlers.mmd`
- `diagrams/class-server-verification-handlers.mmd`
- `diagrams/class-server-revocation-handlers.mmd`
- `diagrams/class-server-ledger-client.mmd`

## Component Diagrams (UML - Mermaid approximation using stereotypes)
- `diagrams/component-system-complete.mmd`
- `diagrams/component-mobile-layers.mmd`
- `diagrams/component-mobile-services.mmd`
- `diagrams/component-server-overview.mmd`
- `diagrams/component-server-microservices.mmd`
- `diagrams/component-server-core-services.mmd`

## Deployment Diagrams (UML - Mermaid approximation using stereotypes)
- `diagrams/deployment-server-infrastructure.mmd`
- `diagrams/deployment-ledger-indy-network.mmd`
- `diagrams/deployment-ledger-demo-acapy-agents.mmd`

## Architecture Diagrams (system view)
- `diagrams/architecture-server-system-overview.mmd`
- `diagrams/architecture-server-trusted-ledger.mmd`

## Entity Relationship Diagrams (data model)
- `diagrams/erdiagram-server-admin-db.mmd`
- `diagrams/erdiagram-server-request-tables.mmd`
- `diagrams/erdiagram-server-request-registry.mmd`
- `diagrams/erdiagram-server-request-ops.mmd`
- `diagrams/erdiagram-server-trust-registry-db.mmd`
- `diagrams/erdiagram-server-trust-registry-core.mmd`
- `diagrams/erdiagram-server-trust-registry-policy.mmd`
- `diagrams/erdiagram-mobile-local-db.mmd`

## Interface Diagrams (UI Flow - Window Navigation)
- `diagrams/interface-mobile.mmd`
- `diagrams/interface-mobile-did.mmd`
- `diagrams/interface-mobile-credentials.mmd`
- `diagrams/interface-mobile-presentation.mmd`
- `diagrams/interface-mobile-settings.mmd`
- `diagrams/interface-server-1.mmd`
- `diagrams/interface-server-2.mmd`

## Activity Diagrams (optional UML)
- `diagrams/activity-mobile-attribute-minimization.mmd`
- `diagrams/activity-mobile-navigation.mmd`
- `diagrams/activity-server-sdk-evaluation.mmd`
- `diagrams/activity-server-zkp-tooling-comparison.mmd`

## Sequence Diagrams (optional UML)
- Mobile:
  - `diagrams/sequence-mobile-biometric-authentication.mmd`
  - `diagrams/sequence-mobile-crypto-validation.mmd`
  - `diagrams/sequence-mobile-did-generation.mmd`
  - `diagrams/sequence-mobile-vc-storage.mmd`
  - `diagrams/sequence-mobile-vp-presentation.mmd`
  - `diagrams/sequence-mobile-android-key-generation.mmd`
  - `diagrams/sequence-mobile-ios-key-generation.mmd`
  - `diagrams/sequence-mobile-local-storage-setup.mmd`
  - `diagrams/sequence-mobile-non-exportable-keys.mmd`
  - `diagrams/sequence-mobile-offline-verification.mmd`
  - `diagrams/sequence-mobile-online-sync.mmd`
  - `diagrams/sequence-mobile-proof-generation.mmd`
  - `diagrams/sequence-mobile-replay-protection.mmd`
  - `diagrams/sequence-mobile-revocation-check.mmd`
  - `diagrams/sequence-mobile-selective-disclosure.mmd`
  - `diagrams/sequence-mobile-vc-signature-verification.mmd`
  - `diagrams/sequence-mobile-vc-workflow.mmd`
  - `diagrams/sequence-mobile-vp-creation.mmd`
  - `diagrams/sequence-mobile-zkp-circuits.mmd`
  - `diagrams/sequence-mobile-zkp-failure-handling.mmd`
- Server:
  - `diagrams/sequence-server-auth-session.mmd`
  - `diagrams/sequence-server-issuer-management.mmd`
  - `diagrams/sequence-server-schema-management.mmd`
  - `diagrams/sequence-server-cred-def-management.mmd`
  - `diagrams/sequence-server-ledger-sync.mmd`
  - `diagrams/sequence-server-replay-protection.mmd`
  - `diagrams/sequence-server-revocation-check.mmd`

## Other Diagrams
- `diagrams/feasability.mmd`
