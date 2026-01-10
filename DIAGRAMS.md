# QuantumZero Diagram Narratives and Metadata (Deliverable #1)

This document centralizes the required per-diagram narratives, priorities (A/B/C), preconditions, triggers, post-conditions, and actor descriptions. The diagrams in `diagrams/` intentionally omit this text to keep UML/DFD visuals uncluttered.

## Notation References (required)
- UML Class Diagram Tutorial: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/uml-class-diagram-tutorial/
- UML Diagrams Reference: https://www.uml-diagrams.org/
- DFD (Yourdon) Tutorial: https://online.visual-paradigm.com/knowledge/software-design/dfd-tutorial-yourdon-notation

## Actor Glossary (shared)
- **Holder / Wallet User:** End-user operating the QuantumZero mobile app to view credentials and present proofs.
- **Verifier / Relying Party:** External party requesting a proof/presentation and verifying what is presented.
- **Admin User (Browser):** Operator using the QuantumZero web dashboard and Admin API to manage issuers/schemas/credential definitions and view system status.
- **QuantumZero Mobile App:** Flutter/Dart application running on a user device (see `QuantumZero-mobile`).
- **QuantumZero Server Admin API:** Rust/Actix-Web service exposing `/api/v1/*` endpoints (see `QuantumZero-server/services/admin-api`).
- **QuantumZero Web Frontend:** Rust service serving static HTML/CSS/JS dashboard files (see `QuantumZero-server/services/web-frontend`).
- **PostgreSQL (Admin DB):** Database used by the Admin API for registry and auth/session persistence (see server migrations).
- **Ledger Browser (VON):** HTTP service used as the Admin API's ledger query target (`LEDGER_URL`).
- **Indy Pool (node1..node4):** Indy node containers backing the ledger network (see ledger compose files).
- **ACA-Py Agent (demo):** Aries Cloud Agent Python container used in `QuantumZero-server/ledgerDemo` for demo issuance/verification flows.
- **tails-server (demo):** Container used by the ACA-Py demo stack for revocation tails file hosting.
- **Platform Keychain/Keystore:** iOS Keychain / Android Keystore platform facilities referenced by the mobile app's security service interfaces.

---

## Figures

### Figure 1. Use Case - User Authentication (App Unlock)
- File: `diagrams/usecase-mobile-app-unlock.mmd`
- Priority: A
- Status: Planned (UI/service wiring not implemented)
- Actors: Holder / Wallet User, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: App installed; device has a configured unlock method; wallet initialized.
- Triggers: App launch/resume; user attempts a protected operation; wallet session timeout.
- Post-conditions: Wallet is unlocked for a bounded session, or access remains locked after failure.
- Narrative: Describes the wallet unlock boundary and the authentication path (biometric with PIN fallback).

### Figure 2. Use Case - Authentication with External Services
- File: `diagrams/usecase-mobile-external-authentication.mmd`
- Priority: A
- Status: Planned (external authentication protocol not implemented)
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: Wallet unlocked; at least one credential exists; verifier request channel available (QR/deep link).
- Triggers: User initiates an external login that requests credential-based proof.
- Post-conditions: Proof/presentation is provided to the verifier, and a result is displayed to the user.
- Narrative: Frames wallet-assisted authentication to external services using credential presentation.

### Figure 3. Use Case - Prove a Fact (Verifiable Presentation)
- File: `diagrams/usecase-mobile-prove-fact.mmd`
- Priority: A
- Status: Planned (proof/presentation generation not implemented)
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: Wallet unlocked; credential material available; verifier request is received.
- Triggers: Verifier provides a request; user approves sharing.
- Post-conditions: A verifiable presentation/proof is produced and transmitted; verification outcome is surfaced.
- Narrative: Describes the holder-driven flow of selecting what to share and producing a presentation for verification.

### Figure 4. Use Case - Server Admin Management (Admin API + Web Dashboard)
- File: `diagrams/usecase-server-admin-management.mmd`
- Priority: A
- Status: Current (Admin API + Web Frontend exist)
- Actors: Admin User (Browser), QuantumZero Web Frontend, QuantumZero Server Admin API, PostgreSQL (Admin DB), Ledger Browser (VON) (see Actor Glossary)
- Preconditions: Server services running; database migrated; ledger browser reachable for ledger features.
- Triggers: Admin logs in; admin performs CRUD actions and/or triggers ledger sync.
- Post-conditions: Registry/auth data is created/updated; audit records are written; results returned to admin UI.
- Narrative: Captures the operational scope of the current server admin surface and its primary use cases.

### Figure 5. DFD - Admin Registry (Issuers/Schemas/CredDefs) (Level 1)
- File: `diagrams/dfd-server-admin-registry.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), PostgreSQL (Admin DB), Ledger Browser (VON) (see Actor Glossary)
- Preconditions: Admin API reachable; DB reachable; schema migrated.
- Triggers: Admin submits issuer/schema/cred-def CRUD requests; admin triggers sync/import endpoints.
- Post-conditions: Registry tables updated; audit logs recorded; responses returned to the admin.
- Narrative: Shows how registry management requests flow through Admin API processes into persistent data stores.

### Figure 6. DFD - Ledger Queries (Level 1)
- File: `diagrams/dfd-server-ledger-queries.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Server Admin API, Ledger Browser (VON), PostgreSQL (Admin DB) (see Actor Glossary)
- Preconditions: `LEDGER_URL` configured; ledger browser reachable on Docker network `indy`.
- Triggers: Admin calls health/pool-node endpoints; admin triggers schema import and/or ledger sync.
- Post-conditions: Ledger query results returned; imported/synced records persisted in PostgreSQL when applicable.
- Narrative: Shows the Admin API's ledger-query data path and the optional persistence of imported/synced records.

### Figure 7. DFD - Trusted Registry Administration (LedgerDB) (Level 1) (Planned)
- File: `diagrams/dfd-server-trust-registry-admin.mmd`
- Priority: B
- Status: Planned (service layer not implemented in Rust workspace)
- Actors: Admin User (Browser) (see Actor Glossary)
- Preconditions: Trusted Registry DB schema is deployed (data model defined by `QuantumZero-server/ledgerDB/init.sql`).
- Triggers: Admin performs issuer directory, template, policy, or offline cache package operations.
- Post-conditions: Trusted registry records updated; audit events recorded; outputs (e.g., offline cache package) produced.
- Narrative: Defines the intended administrative data flows for the trusted registry schema present in the server workspace.

### Figure 8. Class Diagram - Mobile Core Data Models
- File: `diagrams/class-mobile-models.mmd`
- Priority: A
- Status: Current
- Actors: QuantumZero Mobile App developers (design/use)
- Preconditions: Mobile codebase present (`QuantumZero-mobile/lib/core/models/*`).
- Triggers: Model evolution; serialization contract review; feature implementation.
- Post-conditions: Consistent understanding of the mobile wallet's core data structures.
- Narrative: Defines the current mobile domain models used by the Flutter wallet (DID, Credential, VerifiablePresentation).

### Figure 9. Class Diagram - Mobile Repositories
- File: `diagrams/class-mobile-repositories.mmd`
- Priority: A
- Status: Current (interfaces present; implementations TODO)
- Actors: QuantumZero Mobile App developers (design/use)
- Preconditions: Repository interfaces exist in `QuantumZero-mobile/lib/core/repositories/*`.
- Triggers: Persistence layer implementation; DB schema finalization.
- Post-conditions: Agreed repository API surface for DID and credential persistence.
- Narrative: Captures the repository interfaces and intended persistence responsibilities for DIDs and credentials.

### Figure 10. Class Diagram - Mobile Core Services
- File: `diagrams/class-mobile-services.mmd`
- Priority: A
- Status: Current (interfaces present; implementations largely TODO)
- Actors: QuantumZero Mobile App developers (design/use)
- Preconditions: Service interfaces exist in `QuantumZero-mobile/lib/core/services/*`.
- Triggers: Security service implementation; platform integration work.
- Post-conditions: Agreed service API surface for biometrics, cryptography, and secure storage.
- Narrative: Defines the mobile service interfaces and their implementations as currently scaffolded in the codebase.

### Figure 11. Class Diagram - Mobile State Management (Riverpod)
- File: `diagrams/class-mobile-state-management.mmd`
- Priority: A
- Status: Current (providers/notifiers present; repositories injected later)
- Actors: Holder / Wallet User (indirect via UI), QuantumZero Mobile App developers
- Preconditions: Riverpod providers exist in `QuantumZero-mobile/lib/features/*/presentation/*`.
- Triggers: UI loads; provider initialization; state refresh operations.
- Post-conditions: UI-visible state updated (DID, credential list, QR generation state).
- Narrative: Documents the existing Riverpod `StateNotifier` state containers used by the mobile UI.

### Figure 12. Class Diagram - Mobile QR Features
- File: `diagrams/class-mobile-qr.mmd`
- Priority: A
- Status: Current (services defined; UI uses `mobile_scanner` directly today)
- Actors: Holder / Wallet User, Verifier / Relying Party (via QR channel)
- Preconditions: QR generation/scanning service interfaces exist; UI screens available.
- Triggers: User scans or presents a QR code.
- Post-conditions: QR data is captured and/or generated for presentation workflows.
- Narrative: Defines the QR-domain service interfaces for scanning and generating QR payloads.

### Figure 13. Class Diagram - Mobile Selective Disclosure
- File: `diagrams/class-mobile-selective-disclosure.mmd`
- Priority: B
- Status: Current (service interface present; ZKP logic TODO)
- Actors: Holder / Wallet User, Verifier / Relying Party (see Actor Glossary)
- Preconditions: Selective disclosure service interface present in `QuantumZero-mobile/lib/features/selective_disclosure`.
- Triggers: User requests partial disclosure; verifier requires constrained attributes.
- Post-conditions: A `SelectiveDisclosureResult` is produced (and may be verified) once implemented.
- Narrative: Documents the service interface and result model used to represent selective disclosure outputs.

### Figure 14. Class Diagram - Mobile UI Screens (Flutter) (Current)
- File: `diagrams/class-mobile-ui-screens.mmd`
- Priority: A
- Status: Current
- Actors: Holder / Wallet User
- Preconditions: Flutter routes and screens exist in `QuantumZero-mobile/lib/main.dart` and `QuantumZero-mobile/lib/screens/*`.
- Triggers: App startup; navigation between screens.
- Post-conditions: UI state transitions occur; providers are read/watched by UI where implemented.
- Narrative: Maps the current screen classes to routes and highlights which screens depend on Riverpod providers and external UI libraries.

### Figure 15. Class Diagram - Server Domain Models
- File: `diagrams/class-server-models.mmd`
- Priority: A
- Status: Current
- Actors: QuantumZero Server Admin API developers (design/use)
- Preconditions: Server model types exist in `QuantumZero-server/services/admin-api/src/models.rs` and `QuantumZero-server/shared/common/src/lib.rs`.
- Triggers: API contract changes; DB schema changes; ledger sync changes.
- Post-conditions: Consistent understanding of server API request/response and persistence models.
- Narrative: Documents the Rust structs/enums used by the Admin API and shared library types.

### Figure 16. Class Diagram - Server API Handlers (Admin API)
- File: `diagrams/class-server-handlers.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Server Admin API
- Preconditions: Admin API compiled and running; routes configured via `configure_routes`.
- Triggers: HTTP requests to `/api/v1/*`.
- Post-conditions: HTTP responses returned; DB/ledger interactions performed where applicable.
- Narrative: Shows the Admin API handler functions and their primary dependencies (`AppState`, DB pool, Indy client).

### Figure 17. Class Diagram - Server Ledger Client (qz-indy-client)
- File: `diagrams/class-server-ledger-client.mmd`
- Priority: A
- Status: Current
- Actors: QuantumZero Server Admin API, Ledger Browser (VON)
- Preconditions: `LEDGER_URL` points to a reachable ledger browser endpoint.
- Triggers: Ledger query calls from Admin API (health, pool nodes, scan/sync/import).
- Post-conditions: Ledger JSON results parsed into typed structures and returned to callers.
- Narrative: Documents the ledger client API used by the server to query ledger-related endpoints through the ledger browser.

### Figure 18. Component Diagram - Complete QuantumZero System Architecture
- File: `diagrams/component-system-complete.mmd`
- Priority: A
- Status: Current (includes optional demo/reference components)
- Actors: Holder / Wallet User, Verifier / Relying Party, Admin User (Browser) (see Actor Glossary)
- Preconditions: Mobile app and server services available; ledger network available for ledger-linked paths.
- Triggers: User UI operations; admin management operations; ledger sync operations.
- Post-conditions: Local state updated; server registry updated; ledger data synchronized on demand.
- Narrative: High-level component view connecting mobile layers, server services, ledger integration, and optional demo/reference stacks.

### Figure 19. Component Diagram - Mobile Application Layers
- File: `diagrams/component-mobile-layers.mmd`
- Priority: A
- Status: Current (with explicit planned/TODO wiring)
- Actors: Holder / Wallet User
- Preconditions: Flutter UI and Riverpod providers present; repositories/services defined (some TODO).
- Triggers: UI observes providers; feature wiring work progresses from TODO stubs to implementations.
- Post-conditions: Layer boundaries are established and consistent across features.
- Narrative: Shows the mobile app's layered decomposition (UI, state, domain APIs, services, models, and planned persistence).

### Figure 20. Component Diagram - Mobile Core Services
- File: `diagrams/component-mobile-services.mmd`
- Priority: A
- Status: Current (interfaces present; platform wiring TODO)
- Actors: Holder / Wallet User, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: Service interfaces exist; platform packages are available in the Flutter project dependencies.
- Triggers: Biometric/crypto/secure-storage operations are invoked once wired into UI/features.
- Post-conditions: Platform security services are used consistently for gated access and secure material handling.
- Narrative: Depicts the mobile security-related service components and their intended platform dependencies.

### Figure 21. Component Diagram - Server Architecture Overview
- File: `diagrams/component-server-overview.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Server Admin API, QuantumZero Web Frontend, PostgreSQL (Admin DB), Ledger Browser (VON)
- Preconditions: Docker compose stack running; `DATABASE_URL` and `LEDGER_URL` configured.
- Triggers: Admin uses dashboard pages; browser issues API requests; API issues DB/ledger requests.
- Post-conditions: Registry/auth records updated; health/metrics/stats views populated.
- Narrative: High-level server component view showing the two Rust services and their external dependencies.

### Figure 22. Component Diagram - Server Service Internals (Current)
- File: `diagrams/component-server-microservices.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Server Admin API, QuantumZero Web Frontend
- Preconditions: Service code present; shared libraries available in Rust workspace.
- Triggers: Route configuration; handler execution; web frontend static resource serving.
- Post-conditions: Internal module responsibilities are delineated (routes/handlers/models/state; web static serving).
- Narrative: Breaks down Admin API and Web Frontend into their key internal modules and dependencies.

### Figure 23. Deployment Diagram - QuantumZero Server Infrastructure (PoC)
- File: `diagrams/deployment-server-infrastructure.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), Holder / Wallet User (see Actor Glossary)
- Preconditions: Docker host available; required ports free; external Docker network `indy` exists.
- Triggers: Containers started; admin uses dashboard; Admin API performs periodic ledger sync.
- Post-conditions: Server services reachable; DB persists registry/auth state; ledger browser reachable for queries.
- Narrative: Shows the deployed PoC stack: Admin API + Web Frontend + PostgreSQL + ledger network access, plus the mobile device context.

### Figure 24. Deployment Diagram - Indy Ledger Network (Docker)
- File: `diagrams/deployment-ledger-indy-network.mmd`
- Priority: A
- Status: Current
- Actors: Ledger operators (administration), Ledger Browser (VON), Indy Pool (node1..node4)
- Preconditions: Docker host available; `indy` network created; ledger compose started.
- Triggers: Node startup; controller actions; ledger browser queries.
- Post-conditions: Indy pool available and discoverable through the ledger browser HTTP endpoints.
- Narrative: Captures the ledger-side deployment that the server uses for DID/schema/cred-def discovery via the ledger browser.

### Figure 25. Deployment Diagram - Ledger Demo Agents (ACA-Py) (Optional)
- File: `diagrams/deployment-ledger-demo-acapy-agents.mmd`
- Priority: B
- Status: Optional (demo stack; separate from Rust services)
- Actors: Demo Operator, ACA-Py Agents, tails-server, Indy Pool, Ledger Browser (see Actor Glossary)
- Preconditions: `indy` network exists; ledger demo compose started.
- Triggers: Operator drives demo flows using exposed ACA-Py admin ports.
- Post-conditions: Demo agents are available to simulate issuer/holder/verifier interactions against the Indy ledger.
- Narrative: Documents the optional ACA-Py based demo microservice stack present in the server workspace (`ledgerDemo`).

### Figure 26. Architecture - Server System Overview
- File: `diagrams/architecture-server-system-overview.mmd`
- Priority: B
- Status: Current
- Actors: Holder / Wallet User, Verifier / Relying Party, Admin User (Browser)
- Preconditions: Mobile app and server services available; ledger browser reachable for ledger operations.
- Triggers: Wallet UI use; admin operations; ledger sync operations.
- Post-conditions: Local UI state changes and server registry/ledger views are consistent with current components.
- Narrative: End-to-end view connecting the mobile wallet layers to the server admin stack and Indy ledger integration.

### Figure 27. Architecture - Indy Ledger Integration (Current)
- File: `diagrams/architecture-server-trusted-ledger.mmd`
- Priority: B
- Status: Current
- Actors: QuantumZero Server Admin API, Ledger Browser (VON), Indy Pool (node1..node4)
- Preconditions: `LEDGER_URL` configured; ledger browser reachable on the `indy` Docker network.
- Triggers: Admin API ledger queries; startup/interval ledger sync.
- Post-conditions: Ledger observations are consumed by the Admin API and optionally persisted to PostgreSQL.
- Narrative: Focused architecture view of the Admin API to ledger browser to Indy pool data path.

### Figure 28. ER Diagram - Admin API Database Schema (PostgreSQL)
- File: `diagrams/erdiagram-server-admin-db.mmd`
- Priority: A
- Status: Current
- Actors: QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Migrations applied from `QuantumZero-server/services/admin-api/migrations/*`.
- Triggers: Admin API startup migration run; CRUD operations via handlers.
- Post-conditions: Data is stored in tables matching the diagram (issuers, schemas, cred defs, audit logs, users, sessions).
- Narrative: Captures the Admin API persistence schema used for registry and authentication/session management.

### Figure 29. ER Diagram - Trusted Registry Database Schema (LedgerDB)
- File: `diagrams/erdiagram-server-trust-registry-db.mmd`
- Priority: B
- Status: Reference (schema present as SQL; service wiring not in Rust workspace)
- Actors: Trusted Registry DB (LedgerDB), Admin User (Browser) (planned management)
- Preconditions: LedgerDB schema applied from `QuantumZero-server/ledgerDB/init.sql`.
- Triggers: Planned trust registry administration operations and offline cache packaging.
- Post-conditions: Trusted registry data supports policy/template/issuer directory governance workflows once wired.
- Narrative: Documents the server-side trusted registry schema used to store issuer directory entries, templates, trust policies, and offline cache packages.

### Figure 30. ER Diagram - Mobile Local Database Schema (SQLite) (Planned)
- File: `diagrams/erdiagram-mobile-local-db.mmd`
- Priority: C
- Status: Planned (schema notes exist; repository implementations TODO)
- Actors: QuantumZero Mobile App, Local SQLite store (planned)
- Preconditions: Local DB schema created in SQLite (per repository TODO notes).
- Triggers: Wallet persistence operations (save/load DID and credentials).
- Post-conditions: DIDs and credentials are persisted locally for offline-friendly UX.
- Narrative: Records the intended local persistence schema described in the mobile repository stubs.

### Figure 31. Activity Diagram - Mobile Attribute Minimization
- File: `diagrams/activity-mobile-attribute-minimization.mmd`
- Priority: B
- Status: Planned (selective disclosure service TODO)
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Wallet has at least one credential; verifier request indicates required attributes.
- Triggers: User chooses to present a proof/presentation.
- Post-conditions: Only the minimum necessary attributes are selected for inclusion in the proof/presentation.
- Narrative: Describes the decision flow for minimizing disclosed attributes in the wallet UX.

### Figure 32. Activity Diagram - Mobile Navigation (Current)
- File: `diagrams/activity-mobile-navigation.mmd`
- Priority: B
- Status: Current
- Actors: Holder / Wallet User
- Preconditions: App installed and launches successfully.
- Triggers: User taps navigation actions and routes.
- Post-conditions: User arrives at the expected screen (home, scan, present, settings).
- Narrative: Documents the current app navigation flow as implemented in routes/screens.

### Figure 33. Activity Diagram - SDK Evaluation Workflow (Planned)
- File: `diagrams/activity-server-sdk-evaluation.mmd`
- Priority: C
- Status: Planned (process/workflow documentation)
- Actors: Project developers/architects
- Preconditions: Candidate libraries identified; evaluation criteria defined.
- Triggers: Technology selection work for future features (e.g., proof/verification support).
- Post-conditions: A candidate is selected or rejected with documented rationale.
- Narrative: Documents the project's intended workflow for evaluating SDKs/libraries without asserting a selected protocol.

### Figure 34. Activity Diagram - ZKP Tooling Comparison (Planned)
- File: `diagrams/activity-server-zkp-tooling-comparison.mmd`
- Priority: C
- Status: Planned (process/workflow documentation)
- Actors: Project developers/architects
- Preconditions: ZKP needs identified; candidate approaches listed.
- Triggers: ZKP design/planning work.
- Post-conditions: A tooling direction is chosen or deferred with documented constraints.
- Narrative: Provides a high-level workflow for comparing ZKP tooling options in the project context.

### Figure 35. Sequence Diagram - Mobile Android Key Generation (Planned)
- File: `diagrams/sequence-mobile-android-key-generation.mmd`
- Priority: C
- Status: Planned
- Actors: QuantumZero Mobile App, Platform Keychain/Keystore (Android)
- Preconditions: Android device supports Keystore; app has required permissions/config.
- Triggers: Wallet initializes key material; user enables security features.
- Post-conditions: Platform-managed key references exist for signing/encryption use.
- Narrative: Describes the planned Android platform key creation flow for wallet key material.

### Figure 36. Sequence Diagram - Mobile Biometric Authentication (Planned)
- File: `diagrams/sequence-mobile-biometric-authentication.mmd`
- Priority: B
- Status: Planned
- Actors: Holder / Wallet User, Platform Keychain/Keystore
- Preconditions: Biometrics enrolled; biometric API available.
- Triggers: User attempts to unlock wallet or approve a sensitive operation.
- Post-conditions: Operation proceeds only after successful biometric authentication.
- Narrative: Shows the planned biometric-gating sequence for protected wallet actions.

### Figure 37. Sequence Diagram - Mobile Crypto Validation (Current)
- File: `diagrams/sequence-mobile-crypto-validation.mmd`
- Priority: B
- Status: Current (sequence exists as PoC flow; crypto wiring partially TODO)
- Actors: QuantumZero Mobile App, CryptoService (see Actor Glossary)
- Preconditions: Crypto service interface available; inputs provided.
- Triggers: App validates signatures/hashes as part of a credential/proof workflow (once wired).
- Post-conditions: Validation result returned to the calling feature/UI.
- Narrative: Documents the intended validation call chain for cryptographic checks within the mobile app.

### Figure 38. Sequence Diagram - Mobile DID Generation (Planned)
- File: `diagrams/sequence-mobile-did-generation.mmd`
- Priority: C
- Status: Planned
- Actors: QuantumZero Mobile App, CryptoService, Local SQLite store (planned)
- Preconditions: Crypto key generation implemented; DID repository implemented.
- Triggers: User requests a new DID.
- Post-conditions: A new DID record is created and persisted; state updates to reflect active DID.
- Narrative: Describes the planned DID generation and persistence sequence.

### Figure 39. Sequence Diagram - Mobile Ios Key Generation (Planned)
- File: `diagrams/sequence-mobile-ios-key-generation.mmd`
- Priority: C
- Status: Planned
- Actors: QuantumZero Mobile App, Platform Keychain/Keystore (iOS)
- Preconditions: iOS Keychain available; app configured for secure storage usage.
- Triggers: Wallet initializes key material.
- Post-conditions: Platform-managed key references exist for later crypto operations.
- Narrative: Describes the planned iOS platform key creation flow for wallet key material.

### Figure 40. Sequence Diagram - Mobile Local Storage Setup (Planned)
- File: `diagrams/sequence-mobile-local-storage-setup.mmd`
- Priority: C
- Status: Planned
- Actors: QuantumZero Mobile App, Local SQLite store (planned)
- Preconditions: `sqflite` persistence implemented.
- Triggers: App initializes persistence layer at startup.
- Post-conditions: Local storage schema created/validated and ready for use.
- Narrative: Documents the planned initialization sequence for local persistence.

### Figure 41. Sequence Diagram - Mobile Non Exportable Keys (Planned)
- File: `diagrams/sequence-mobile-non-exportable-keys.mmd`
- Priority: B
- Status: Planned
- Actors: QuantumZero Mobile App, Platform Keychain/Keystore
- Preconditions: Platform supports non-exportable key storage policies.
- Triggers: App requests non-exportable key generation; app requests signing.
- Post-conditions: Only signatures are returned to the app; key material remains platform-managed.
- Narrative: Shows the planned non-exportable key usage pattern using platform-managed key handles.

### Figure 42. Sequence Diagram - Mobile Offline Verification (Planned)
- File: `diagrams/sequence-mobile-offline-verification.mmd`
- Priority: C
- Status: Planned
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Credential/presentation data available locally; verifier accepts offline flow.
- Triggers: User presents proof without network connectivity.
- Post-conditions: Proof is presented via offline channel (e.g., QR) and verifier makes a decision.
- Narrative: Describes an offline-friendly presentation path for the wallet.

### Figure 43. Sequence Diagram - Mobile Online Sync (Planned)
- File: `diagrams/sequence-mobile-online-sync.mmd`
- Priority: C
- Status: Planned
- Actors: QuantumZero Mobile App, Network services (TBD)
- Preconditions: Network connectivity; sync endpoints identified.
- Triggers: App detects connectivity; user initiates sync.
- Post-conditions: Local cache and remote state are reconciled where applicable.
- Narrative: Documents a planned online sync sequence without asserting a specific backend protocol.

### Figure 44. Sequence Diagram - Mobile Proof Generation (Planned)
- File: `diagrams/sequence-mobile-proof-generation.mmd`
- Priority: B
- Status: Planned
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore
- Preconditions: Credential store available; proof generation implemented.
- Triggers: Verifier requests proof; user approves generation.
- Post-conditions: Proof/presentation package is produced and returned to verifier.
- Narrative: Shows the planned high-level proof-generation call chain and signing step.

### Figure 45. Sequence Diagram - Mobile Replay Protection (Planned)
- File: `diagrams/sequence-mobile-replay-protection.mmd`
- Priority: B
- Status: Planned
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Nonce/timestamp strategy implemented in request and presentation flow.
- Triggers: Wallet processes a verifier request that includes challenge material.
- Post-conditions: Replay attempts are rejected based on nonce/timestamp checks.
- Narrative: Describes the planned replay protection sequence for proof requests and responses.

### Figure 46. Sequence Diagram - Mobile Revocation Check (Planned)
- File: `diagrams/sequence-mobile-revocation-check.mmd`
- Priority: C
- Status: Planned
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Revocation/status mechanism identified and implemented.
- Triggers: Verifier performs a verification that requires revocation/status evaluation.
- Post-conditions: Verification decision incorporates revocation/status outcomes.
- Narrative: Documents a planned revocation/status check step in the verification flow.

### Figure 47. Sequence Diagram - Mobile Selective Disclosure (Planned)
- File: `diagrams/sequence-mobile-selective-disclosure.mmd`
- Priority: B
- Status: Planned
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore
- Preconditions: Selective disclosure logic implemented; required credential data available.
- Triggers: Verifier requests subset of attributes; user approves disclosure selection.
- Post-conditions: Presentation contains only selected attributes, with cryptographic binding.
- Narrative: Shows the planned selective disclosure sequence coordinated by the wallet UI and crypto layer.

### Figure 48. Sequence Diagram - Mobile Vc Signature Verification (Planned)
- File: `diagrams/sequence-mobile-vc-signature-verification.mmd`
- Priority: C
- Status: Planned
- Actors: Verifier / Relying Party (or verification service)
- Preconditions: Verification service implemented; issuer key material available.
- Triggers: A credential is submitted for verification.
- Post-conditions: Signature verification result produced and logged.
- Narrative: Documents a generic signature verification sequence without asserting a specific credential proof format.

### Figure 49. Sequence Diagram - Mobile Vc Storage (Planned)
- File: `diagrams/sequence-mobile-vc-storage.mmd`
- Priority: C
- Status: Planned
- Actors: Holder / Wallet User, Local SQLite store (planned), Platform Keychain/Keystore
- Preconditions: Persistence layer implemented; access control defined.
- Triggers: User stores/reads/updates/deletes credentials.
- Post-conditions: Credential data is persisted locally with an encryption/key-management strategy.
- Narrative: Describes the planned sequence for local credential storage operations in the wallet.

### Figure 50. Sequence Diagram - Mobile Vc Workflow (Planned)
- File: `diagrams/sequence-mobile-vc-workflow.mmd`
- Priority: C
- Status: Planned
- Actors: Holder / Wallet User, Issuer System, Verifier / Relying Party
- Preconditions: Issuance and verification endpoints exist (not implemented in the mobile app today).
- Triggers: User requests issuance; user later presents proof to verifier.
- Post-conditions: Credential is stored in wallet; proof presentation is performed using referenced sequences.
- Narrative: High-level, protocol-agnostic issuance-to-presentation workflow summary for the wallet.

### Figure 51. Sequence Diagram - Mobile Vp Creation (Planned)
- File: `diagrams/sequence-mobile-vp-creation.mmd`
- Priority: C
- Status: Planned
- Actors: Holder / Wallet User, Platform Keychain/Keystore
- Preconditions: Presentation model and signing are implemented; credential data available locally.
- Triggers: User initiates presentation creation.
- Post-conditions: Presentation payload is produced, signed, and ready to present.
- Narrative: Describes the planned presentation creation and signing sequence in the wallet.

### Figure 52. Sequence Diagram - Mobile Vp Presentation (Planned)
- File: `diagrams/sequence-mobile-vp-presentation.mmd`
- Priority: B
- Status: Planned
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore
- Preconditions: Verifier request received (e.g., QR/deep link); proof/presentation payload available.
- Triggers: User approves presenting proof.
- Post-conditions: Verifier receives the proof response and returns an accept/reject outcome.
- Narrative: Describes the planned request-to-presentation sequence, referencing other diagrams for subflows.

### Figure 53. Sequence Diagram - Mobile Zkp Circuits (Planned)
- File: `diagrams/sequence-mobile-zkp-circuits.mmd`
- Priority: C
- Status: Planned
- Actors: Project developers/architects
- Preconditions: ZKP circuit approach chosen; circuit execution strategy defined.
- Triggers: ZKP integration work starts.
- Post-conditions: Circuit compilation/execution strategy is documented for implementation planning.
- Narrative: Documents a planned ZKP circuit workflow at a conceptual level for future implementation.

### Figure 54. Sequence Diagram - Mobile Zkp Failure Handling (Planned)
- File: `diagrams/sequence-mobile-zkp-failure-handling.mmd`
- Priority: C
- Status: Planned
- Actors: Holder / Wallet User
- Preconditions: ZKP generation integrated; error classes defined.
- Triggers: Proof generation fails due to invalid inputs, timeouts, or crypto errors.
- Post-conditions: User receives a clear failure result and guidance; no sensitive material is exposed.
- Narrative: Captures a planned user-visible failure-handling path for proof generation.

### Figure 55. Sequence Diagram - Server Auth Session (Current)
- File: `diagrams/sequence-server-auth-session.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Web Frontend, QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Admin API running; users table seeded; DB reachable.
- Triggers: Admin submits login/logout/session verification requests.
- Post-conditions: Session token issued/invalidated/validated; server responds with auth state.
- Narrative: Shows the current authentication/session management interaction between the dashboard, Admin API, and database.

### Figure 56. Sequence Diagram - Server Issuer Management (Current)
- File: `diagrams/sequence-server-issuer-management.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Admin session valid; DB migrated.
- Triggers: Admin performs issuer list/create/read/update operations.
- Post-conditions: Issuer records updated in PostgreSQL and returned in API responses.
- Narrative: Documents the current issuer CRUD sequence through the Admin API.

### Figure 57. Sequence Diagram - Server Schema Management (Current)
- File: `diagrams/sequence-server-schema-management.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Server Admin API, PostgreSQL (Admin DB), Ledger Browser (VON)
- Preconditions: Admin session valid; DB migrated; ledger browser reachable for import/sync paths.
- Triggers: Admin performs schema list/create/read/import operations.
- Post-conditions: Schema records updated and/or imported; results returned to admin.
- Narrative: Shows the current schema management flow including the ledger import path.

### Figure 58. Sequence Diagram - Server Credential Definition Management (Current)
- File: `diagrams/sequence-server-cred-def-management.mmd`
- Priority: A
- Status: Current
- Actors: Admin User (Browser), QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Admin session valid; DB migrated.
- Triggers: Admin performs credential definition list/create/read operations.
- Post-conditions: Credential definition records updated in PostgreSQL and returned in API responses.
- Narrative: Documents the current credential definition management sequence through the Admin API.

### Figure 59. Sequence Diagram - Server Ledger Sync (Current)
- File: `diagrams/sequence-server-ledger-sync.mmd`
- Priority: A
- Status: Current
- Actors: QuantumZero Server Admin API, Ledger Browser (VON), PostgreSQL (Admin DB)
- Preconditions: `LEDGER_URL` configured; ledger browser reachable; DB migrated.
- Triggers: Admin API startup sync; periodic background sync; manual sync endpoint.
- Post-conditions: Issuers/schemas/cred defs discovered from ledger browser are persisted and reported.
- Narrative: Shows the current automated and manual ledger synchronization behavior implemented by the Admin API.

### Figure 60. Use Case - Server API Suite (Admin/Issuance/Verification/Revocation) (Planned)
- File: `diagrams/usecase-server-api-suite.mmd`
- Priority: B
- Status: Planned (target server design; only Admin API exists today)
- Actors: Admin User (Browser), Issuer System / Operator, Holder / Wallet User, Verifier / Relying Party (see Actor Glossary)
- Preconditions: Planned API services exist behind a gateway; shared trust registry and audit/logging policy defined.
- Triggers: Issuer initiates issuance; verifier submits a proof/presentation; issuer/admin initiates revocation; admin performs registry management.
- Post-conditions: Issuance/verification/revocation operations complete and are auditable; admin registry state remains consistent.
- Narrative: Consolidated use case view of the intended four-API microservice suite for the Rust server.

### Figure 61. Component Diagram - Server Core API Services (Admin/Issuance/Revocation/Verification) (Planned)
- File: `diagrams/component-server-core-services-planned.mmd`
- Priority: B
- Status: Planned (target server design)
- Actors: Admin User (Browser), Issuer System / Operator, Verifier / Relying Party, Ledger Browser (VON), PostgreSQL (Admin DB) (see Actor Glossary)
- Preconditions: API gateway deployed; issuance/verification/revocation services implemented; routing policy defined.
- Triggers: HTTPS requests routed to the correct API; services emit audit logs; services consult trust registry and ledger.
- Post-conditions: Requests are routed and processed by the correct service; audit logging is performed; ledger/trust registry interactions occur as required by policy.
- Narrative: Target component topology showing an API gateway fronting the four API services, with shared trust registry and audit logging concerns.

### Figure 62. Class Diagram - Server API Handlers (Issuance API) (Planned)
- File: `diagrams/class-server-issuance-handlers.mmd`
- Priority: B
- Status: Planned (no Rust issuance service currently exists under `QuantumZero-server/services`)
- Actors: Issuer System / Operator (client), Issuance API service
- Preconditions: Issuance API is implemented with Actix-Web routing/handlers/models/state consistent with the current admin-api pattern.
- Triggers: Issuer client requests issuance-related operations.
- Post-conditions: Issuance-related operations execute with ledger and database dependencies available to the service.
- Narrative: Defines the planned handler/module surface for the issuance microservice in the Rust server.

### Figure 63. Class Diagram - Server API Handlers (Verification API) (Planned)
- File: `diagrams/class-server-verification-handlers.mmd`
- Priority: B
- Status: Planned (no Rust verification service currently exists under `QuantumZero-server/services`)
- Actors: Verifier / Relying Party (client), Verification API service
- Preconditions: Verification API is implemented with Actix-Web routing/handlers/models/state consistent with the current admin-api pattern.
- Triggers: Verifier client submits proof/presentation payloads for verification.
- Post-conditions: Verification operations execute with ledger and database dependencies available to the service.
- Narrative: Defines the planned handler/module surface for the verification microservice in the Rust server.

### Figure 64. Class Diagram - Server API Handlers (Revocation API) (Planned)
- File: `diagrams/class-server-revocation-handlers.mmd`
- Priority: B
- Status: Planned (no Rust revocation service currently exists under `QuantumZero-server/services`)
- Actors: Issuer System / Operator (client), Revocation API service
- Preconditions: Revocation API is implemented with Actix-Web routing/handlers/models/state consistent with the current admin-api pattern.
- Triggers: Issuer initiates revocation actions; clients query revocation status.
- Post-conditions: Revocation operations execute with ledger and database dependencies available to the service.
- Narrative: Defines the planned handler/module surface for the revocation microservice in the Rust server.
