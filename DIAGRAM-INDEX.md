# QuantumZero Diagram Index (Deliverable #1)

**Project:** QuantumZero - Decentralized Zero-Trust Identity Wallet  
**Scope:** Unified UML/DFD set for QuantumZero-mobile (Flutter/Dart) and QuantumZero-server (Rust/Actix-Web + Indy) proof of concept  
**Notation References (required):**
- UML Class Diagram Tutorial: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/uml-class-diagram-tutorial/
- UML Diagrams Reference: https://www.uml-diagrams.org/
- DFD (Yourdon) Tutorial: https://online.visual-paradigm.com/knowledge/software-design/dfd-tutorial-yourdon-notation

**Metadata Location (required):** All narratives, priorities (A/B/C), preconditions, triggers, post-conditions, and actor descriptions are centralized in `DIAGRAMS.md`.

---

## Use Case Diagrams (UML)
- `diagrams/usecase-mobile-app-unlock.mmd`
- `diagrams/usecase-mobile-external-authentication.mmd`
- `diagrams/usecase-mobile-prove-fact.mmd`
- `diagrams/usecase-server-admin-management.mmd`
- `diagrams/usecase-server-api-suite.mmd`

## Data Flow Diagrams (DFD - Yourdon)
- `diagrams/dfd-server-admin-registry.mmd`
- `diagrams/dfd-server-ledger-queries.mmd`
- `diagrams/dfd-server-trust-registry-admin.mmd`

## Class Diagrams (UML)
- `diagrams/class-mobile-models.mmd`
- `diagrams/class-mobile-repositories.mmd`
- `diagrams/class-mobile-services.mmd`
- `diagrams/class-mobile-state-management.mmd`
- `diagrams/class-mobile-qr.mmd`
- `diagrams/class-mobile-selective-disclosure.mmd`
- `diagrams/class-mobile-ui-screens.mmd`
- `diagrams/class-server-models.mmd`
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
- `diagrams/component-server-core-services-planned.mmd`

## Deployment Diagrams (UML - Mermaid approximation using stereotypes)
- `diagrams/deployment-server-infrastructure.mmd`
- `diagrams/deployment-ledger-indy-network.mmd`
- `diagrams/deployment-ledger-demo-acapy-agents.mmd`

## Architecture Diagrams (system view)
- `diagrams/architecture-server-system-overview.mmd`
- `diagrams/architecture-server-trusted-ledger.mmd`

## Entity Relationship Diagrams (data model)
- `diagrams/erdiagram-server-admin-db.mmd`
- `diagrams/erdiagram-server-trust-registry-db.mmd`
- `diagrams/erdiagram-mobile-local-db.mmd`

## Activity Diagrams (optional UML)
- `diagrams/activity-mobile-attribute-minimization.mmd`
- `diagrams/activity-mobile-navigation.mmd`
- `diagrams/activity-server-sdk-evaluation.mmd`
- `diagrams/activity-server-zkp-tooling-comparison.mmd`

## Sequence Diagrams (optional UML)
- Mobile:
  - `diagrams/sequence-mobile-android-key-generation.mmd`
  - `diagrams/sequence-mobile-biometric-authentication.mmd`
  - `diagrams/sequence-mobile-crypto-validation.mmd`
  - `diagrams/sequence-mobile-did-generation.mmd`
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
  - `diagrams/sequence-mobile-vc-storage.mmd`
  - `diagrams/sequence-mobile-vc-workflow.mmd`
  - `diagrams/sequence-mobile-vp-creation.mmd`
  - `diagrams/sequence-mobile-vp-presentation.mmd`
  - `diagrams/sequence-mobile-zkp-circuits.mmd`
  - `diagrams/sequence-mobile-zkp-failure-handling.mmd`
- Server:
  - `diagrams/sequence-server-auth-session.mmd`
  - `diagrams/sequence-server-issuer-management.mmd`
  - `diagrams/sequence-server-schema-management.mmd`
  - `diagrams/sequence-server-cred-def-management.mmd`
  - `diagrams/sequence-server-ledger-sync.mmd`
