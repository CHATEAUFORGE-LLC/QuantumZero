# QuantumZero Diagram Narratives and Metadata (Deliverable #1)

This document centralizes the required per-diagram narratives, priorities (A/B/C), preconditions, triggers, post-conditions, and actor descriptions. The diagrams in `diagrams/` intentionally omit this text to keep UML/DFD visuals uncluttered.

## Notation References (required)
- UML Class Diagram Tutorial: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/uml-class-diagram-tutorial/
- UML Diagrams Reference: https://www.uml-diagrams.org/
- DFD (Yourdon) Tutorial: https://online.visual-paradigm.com/knowledge/software-design/dfd-tutorial-yourdon-notation

## Actor Glossary (shared)
- **Holder / Wallet User:** End-user operating the QuantumZero mobile app to view credentials and present proofs.
- **Verifier / Relying Party:** External party requesting a proof/presentation and verifying what is presented.
- **Admin User:** Operator using the QuantumZero web dashboard and Admin API to manage issuers/schemas/credential definitions, trust policies, credential templates, and view system status. Has authenticated session with role-based access control.
- **QuantumZero Mobile App:** Flutter/Dart application running on a user device (see `QuantumZero-mobile`).
- **QuantumZero Server Admin API:** Rust/Actix-Web service exposing `/api/v1/*` endpoints (see `QuantumZero-server/services/admin-api`).
- **QuantumZero Server API Suite:** Server-side APIs (Admin/Issuance/Verification/Revocation) behind an API gateway (see `diagrams/component-server-core-services.mmd`).
- **QuantumZero Web Frontend:** Rust service serving static HTML/CSS/JS dashboard files (see `QuantumZero-server/services/web-frontend`).
- **PostgreSQL (Admin DB):** Database used by the Admin API for registry and auth/session persistence (see server migrations).
- **PostgreSQL (Staging DB):** Gateway staging database for issuer/schema/cred-def/issuance/revocation requests pending approval.
- **Ledger Browser (VON):** HTTP service used as the Admin API's ledger query target (`LEDGER_URL`).
- **Indy Pool (node1..node4):** Indy node containers backing the ledger network (see ledger compose files).
- **ACA-Py Agent (demo):** Aries Cloud Agent Python container used in `QuantumZero-server/ledgerDemo` for demo issuance/verification flows.
- **tails-server (demo):** Container used by the ACA-Py demo stack for revocation tails file hosting.
- **Platform Keychain/Keystore:** iOS Keychain / Android Keystore platform facilities referenced by the mobile app's security service interfaces.
- **Android Keystore/StrongBox:** Android platform key management (optionally hardware-backed) used for generating and using non-exportable keys.
- **iOS Keychain/Secure Enclave:** iOS platform key management (optionally hardware-backed) used for generating and using non-exportable keys.
- **Verifier App (offline-capable):** External verifier-side application/system capable of verifying proofs with limited/no network access by using cached issuer/status data.

---

## Figures

### Figure 1. DFD Level 0 - Admin Registry System (Context Diagram)
- File: `diagrams/dfd-server-admin-registry-L0.mmd`
- Priority: B
- Narrative: Shows the Admin Registry Management System as a single process with external entities (Admin User, Indy Ledger). Establishes the system boundary and major data flows for managing issuers, schemas, and credential definitions synchronized with the ledger.
- Preconditions: Ledger network is accessible via HTTP; Admin User has authenticated session.
- Trigger: Admin User initiates registry management tasks or sync operations.
- Post-conditions: Registry data is created/updated; ledger is queried; confirmation responses returned to admin.

### Figure 2. DFD Level 1 - Admin Registry Management (Process Decomposition)
- File: `diagrams/dfd-server-admin-registry-L1.mmd`
- Priority: B
- Narrative: Decomposes Process 0 into 5 major processes (Manage Issuers, Manage Schemas, Manage Credential Definitions, Sync From Ledger, Audit Logging) with 4 data stores. Shows how admin requests flow through processes to PostgreSQL storage and how ledger sync populates registry tables.
- Preconditions: Admin authenticated; PostgreSQL database available; ledger accessible.
- Trigger: Admin CRUD operations on registry entities; scheduled/manual ledger sync.
- Post-conditions: Registry data persisted to D1-D3; audit events logged to D4; sync status returned.

### Figure 3. DFD Level 0 - Ledger Query System (Context Diagram)
- File: `diagrams/dfd-server-ledger-queries-L0.mmd`
- Priority: B
- Narrative: Shows the Ledger Query & Monitoring System as a single process interfacing with Admin User and Indy Ledger. Defines system boundary for health checks, pool node queries, schema imports, and full ledger synchronization.
- Preconditions: Indy Ledger network operational; Admin has valid session.
- Trigger: Admin requests health status, pool info, schema import, or full sync.
- Post-conditions: Ledger data retrieved; health metrics returned; schemas imported to registry.

### Figure 4. DFD Level 1 - Ledger Query & Monitoring (Process Decomposition)
- File: `diagrams/dfd-server-ledger-queries-L1.mmd`
- Priority: B
- Narrative: Decomposes Process 0 into 4 major processes (Health & Metrics Monitoring, Query Pool Nodes, Import Schema By ID, Full Ledger Sync) with 3 data stores. Shows how ledger queries populate registry tables and return status to admin.
- Preconditions: Admin authenticated; ledger network reachable; registry database available.
- Trigger: Admin health check request; pool node query; schema import by ID; full sync command.
- Post-conditions: Health data returned; pool node info retrieved; schema imported to D2; full sync populates D1-D3.

### Figure 5. DFD Level 2 - Full Ledger Sync Process (4.0 Decomposition)
- File: `diagrams/dfd-server-ledger-queries-L2-sync.mmd`
- Priority: C
- Narrative: Detailed decomposition of Process 4.0 showing 7 sub-processes that scan and parse NYM, SCHEMA, and CRED_DEF transactions from the ledger. Demonstrates GET_TXN API calls, validation logic, deduplication checks against existing data stores, and final report generation.
- Preconditions: Admin initiated full sync with optional txn range; ledger GET_TXN endpoints available.
- Trigger: POST /sync/ledger with start_txn and end_txn parameters.
- Post-conditions: Issuers written to D1; schemas to D2; credential definitions to D3; sync summary with counts returned to admin.

### Figure 6. DFD Level 0 - Staged Registry Approval System (Context Diagram)
- File: `diagrams/dfd-server-trust-registry-admin-L0.mmd`
- Priority: B
- Narrative: Shows the staged registry approval system as a single process with Admin User and Issuer System as external entities. Establishes system boundary for submitting issuer/schema/cred-def requests and approving them.
- Preconditions: Admin authenticated with appropriate role privileges; issuer can sign submissions.
- Trigger: Issuer submits onboarding/schema/cred-def requests; admin reviews and approves/rejects.
- Post-conditions: Staged requests stored and updated; approvals populate the admin registry.

### Figure 7. DFD Level 1 - Staged Registry Approval (Process Decomposition)
- File: `diagrams/dfd-server-trust-registry-admin-L1.mmd`
- Priority: B
- Narrative: Decomposes Process 0 into staged request capture and approval processes for issuers, schemas, and credential definitions. Shows staging data stores, admin approval flows, and audit logging.
- Preconditions: Admin logged in; staging and admin databases available.
- Trigger: Issuer submissions; admin review and approval actions.
- Post-conditions: Staged requests recorded; approved items stored in registry tables; audit events logged.

### Figure 8. DFD Level 2 - Issuer Onboarding (Staged Approval)
- File: `diagrams/dfd-server-trust-registry-admin-L2-issuer.mmd`
- Priority: C
- Narrative: Detailed decomposition of issuer onboarding with signed submissions, staging, admin review, approval/rejection, and audit logging.
- Preconditions: Issuer can sign requests; admin authenticated with issuer management role.
- Trigger: POST /issuer-requests; POST /issuer-requests/{id}/approve or /reject.
- Post-conditions: Staging status updated; approved issuers written to registry; audit event recorded.

### Figure 9. DFD Level 2 - Manage Trust Policies Process (3.0 Decomposition)
- File: `diagrams/dfd-server-trust-registry-admin-L2-policy.mmd`
- Priority: C
- Narrative: Planned trust policy lifecycle management (not yet implemented in the current server code).
- Preconditions: Future policy management service is available.
- Trigger: Policy CRUD and activation operations.
- Post-conditions: Policy data stored and audited once implemented.

### Figure 10. Use Case - User Authentication (App Unlock)
- File: `diagrams/usecase-mobile-app-unlock.puml`
- Priority: A
- Actors: Holder / Wallet User, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: App installed; device has a configured unlock method; wallet initialized.
- Triggers: App launch/resume; user attempts a protected operation; wallet session timeout.
- Post-conditions: Wallet is unlocked for a bounded session, or access remains locked after failure.
- Narrative: Describes the wallet unlock boundary and the authentication path (biometric with PIN fallback).

### Figure 11. Use Case - Authentication with External Services
- File: `diagrams/usecase-mobile-external-authentication.puml`
- Priority: A
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: Wallet unlocked; at least one credential exists; verifier request channel available (QR/deep link).
- Triggers: User initiates an external login that requests credential-based proof.
- Post-conditions: Proof/presentation is provided to the verifier, and a result is displayed to the user.
- Narrative: Frames wallet-assisted authentication to external services using credential presentation.

### Figure 12. Use Case - Prove a Fact (Verifiable Presentation)
- File: `diagrams/usecase-mobile-prove-fact.puml`
- Priority: A
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: Wallet unlocked; credential material available; verifier request is received.
- Triggers: Verifier provides a request; user approves sharing.
- Post-conditions: A verifiable presentation/proof is produced and transmitted; verification outcome is surfaced.
- Narrative: Describes the holder-driven flow of selecting what to share and producing a presentation for verification.

### Figure 13. Use Case - Server Admin Management (Admin API + Web Dashboard)
- File: `diagrams/usecase-server-admin-management.puml`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Web Frontend, QuantumZero Server Admin API, PostgreSQL (Admin DB), Ledger Browser (VON) (see Actor Glossary)
- Preconditions: Server services running; database migrated; ledger browser reachable for ledger features.
- Triggers: Admin logs in; admin performs CRUD actions and/or triggers ledger sync.
- Post-conditions: Registry/auth data is created/updated; audit records are written; results returned to admin UI.
- Narrative: Captures the operational scope of the server admin surface and its primary use cases.

### Figure 14. Use Case - Server API Suite (Admin/Issuance/Verification/Revocation)
- File: `diagrams/usecase-server-api-suite.puml`
- Priority: B
- Actors: Admin User (Browser), Issuer System / Operator, Holder / Wallet User, Verifier / Relying Party (see Actor Glossary)
- Preconditions: API services exist behind a gateway; shared trust registry and audit/logging policy defined.
- Triggers: Issuer initiates issuance; verifier submits a proof/presentation; issuer/admin initiates revocation; admin performs registry management.
- Post-conditions: Issuance/verification/revocation operations complete and are auditable; admin registry state remains consistent.
- Narrative: Consolidated use case view of the four-API microservice suite for the Rust server.

### Figure 9. Class Diagram - Mobile Core Data Models
- File: `diagrams/class-mobile-models.mmd`
- Priority: A
- Actors: QuantumZero Mobile App developers (design/use)
- Preconditions: Mobile codebase present (`QuantumZero-mobile/lib/core/models/*`).
- Triggers: Model evolution; serialization contract review; feature implementation.
- Post-conditions: Consistent understanding of the mobile wallet's core data structures.
- Narrative: Defines the mobile domain models used by the Flutter wallet (DID, Credential, VerifiablePresentation).

### Figure 16. Class Diagram - Mobile Repositories
- File: `diagrams/class-mobile-repositories.mmd`
- Priority: A
- Actors: QuantumZero Mobile App developers (design/use)
- Preconditions: Repository interfaces exist in `QuantumZero-mobile/lib/core/repositories/*`.
- Triggers: Persistence layer implementation; DB schema finalization.
- Post-conditions: Agreed repository API surface for DID and credential persistence.
- Narrative: Captures the repository interfaces and intended persistence responsibilities for DIDs and credentials.

### Figure 17. Class Diagram - Mobile Core Services
- File: `diagrams/class-mobile-services.mmd`
- Priority: A
- Actors: QuantumZero Mobile App developers (design/use)
- Preconditions: Service interfaces exist in `QuantumZero-mobile/lib/core/services/*`.
- Triggers: Security service implementation; platform integration work.
- Post-conditions: Agreed service API surface for biometrics, cryptography, and secure storage.
- Narrative: Defines the mobile service interfaces and their implementations as currently scaffolded in the codebase.

### Figure 18. Class Diagram - Mobile State Management (Riverpod)
- File: `diagrams/class-mobile-state-management.mmd`
- Priority: A
- Actors: Holder / Wallet User (indirect via UI), QuantumZero Mobile App developers
- Preconditions: Riverpod providers exist in `QuantumZero-mobile/lib/features/*/presentation/*`.
- Triggers: UI loads; provider initialization; state refresh operations.
- Post-conditions: UI-visible state updated (DID, credential list, QR generation state).
- Narrative: Documents the existing Riverpod `StateNotifier` state containers used by the mobile UI.

### Figure 19. Class Diagram - Mobile QR Features
- File: `diagrams/class-mobile-qr.mmd`
- Priority: A
- Actors: Holder / Wallet User, Verifier / Relying Party (via QR channel)
- Preconditions: QR generation/scanning service interfaces exist; UI screens available.
- Triggers: User scans or presents a QR code.
- Post-conditions: QR data is captured and/or generated for presentation workflows.
- Narrative: Defines the QR-domain service interfaces for scanning and generating QR payloads.

### Figure 20. Class Diagram - Mobile Selective Disclosure
- File: `diagrams/class-mobile-selective-disclosure.mmd`
- Priority: B
- Actors: Holder / Wallet User, Verifier / Relying Party (see Actor Glossary)
- Preconditions: Selective disclosure service interface present in `QuantumZero-mobile/lib/features/selective_disclosure`.
- Triggers: User requests partial disclosure; verifier requires constrained attributes.
- Post-conditions: A `SelectiveDisclosureResult` is produced (and may be verified) once implemented.
- Narrative: Documents the service interface and result model used to represent selective disclosure outputs.

### Figure 21. Class Diagram - Mobile UI Screens (Flutter)
- File: `diagrams/class-mobile-ui-screens.mmd`
- Priority: A
- Actors: Holder / Wallet User
- Preconditions: Flutter routes and screens exist in `QuantumZero-mobile/lib/main.dart` and `QuantumZero-mobile/lib/screens/*`.
- Triggers: App startup; navigation between screens.
- Post-conditions: UI state transitions occur; providers are read/watched by UI where implemented.
- Narrative: Maps screen classes to routes and highlights which screens depend on Riverpod providers and external UI libraries.

### Figure 22. Class Diagram - Server Domain Models
- File: `diagrams/class-server-models.mmd`
- Priority: A
- Actors: QuantumZero Server Admin API developers (design/use)
- Preconditions: Server model types exist in `QuantumZero-server/services/admin-api/src/models.rs` and `QuantumZero-server/shared/common/src/lib.rs`.
- Triggers: API contract changes; DB schema changes; ledger sync changes.
- Post-conditions: Consistent understanding of server API request/response and persistence models.
- Narrative: Documents the Rust structs/enums used by the Admin API and shared library types.

### Figure 23. Class Diagram - Server API Handlers (Admin API)
- File: `diagrams/class-server-handlers.mmd`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Server Admin API
- Preconditions: Admin API compiled and running; routes configured via `configure_routes`.
- Triggers: HTTP requests to `/api/v1/*`.
- Post-conditions: HTTP responses returned; DB/ledger interactions performed where applicable.
- Narrative: Shows the Admin API handler functions and their primary dependencies (`AppState`, DB pool, Indy client).

### Figure 24. Class Diagram - Server API Handlers (Issuance API)
- File: `diagrams/class-server-issuance-handlers.mmd`
- Priority: B
- Actors: Issuer System / Operator (client), Issuance API service
- Preconditions: Issuance API follows an Actix-Web routing/handlers/models/state pattern consistent with the Admin API.
- Triggers: Issuer client requests issuance-related operations.
- Post-conditions: Issuance-related operations execute with ledger and database dependencies available to the service.
- Narrative: Defines the handler/module surface for the issuance microservice in the Rust server.

### Figure 25. Class Diagram - Server API Handlers (Verification API)
- File: `diagrams/class-server-verification-handlers.mmd`
- Priority: B
- Actors: Verifier / Relying Party (client), Verification API service
- Preconditions: Verification API follows an Actix-Web routing/handlers/models/state pattern consistent with the Admin API.
- Triggers: Verifier client submits proof/presentation payloads for verification.
- Post-conditions: Verification operations execute with ledger and database dependencies available to the service.
- Narrative: Defines the handler/module surface for the verification microservice in the Rust server.

### Figure 26. Class Diagram - Server API Handlers (Revocation API)
- File: `diagrams/class-server-revocation-handlers.mmd`
- Priority: B
- Actors: Issuer System / Operator (client), Revocation API service
- Preconditions: Revocation API follows an Actix-Web routing/handlers/models/state pattern consistent with the Admin API.
- Triggers: Issuer initiates revocation actions; clients query revocation status.
- Post-conditions: Revocation operations execute with ledger and database dependencies available to the service.
- Narrative: Defines the handler/module surface for the revocation microservice in the Rust server.

### Figure 27. Class Diagram - Server Ledger Client (qz-indy-client)
- File: `diagrams/class-server-ledger-client.mmd`
- Priority: A
- Actors: QuantumZero Server Admin API, Ledger Browser (VON)
- Preconditions: `LEDGER_URL` points to a reachable ledger browser endpoint.
- Triggers: Ledger query calls from Admin API (health, pool nodes, scan/sync/import).
- Post-conditions: Ledger JSON results parsed into typed structures and returned to callers.
- Narrative: Documents the ledger client API used by the server to query ledger-related endpoints through the ledger browser.

### Figure 28. Component Diagram - Complete QuantumZero System Architecture
- File: `diagrams/component-system-complete.mmd`
- Priority: A
- Actors: Holder / Wallet User, Verifier / Relying Party, Admin User (Browser) (see Actor Glossary)
- Preconditions: Mobile app and server services available; ledger network available for ledger-linked paths.
- Triggers: User UI operations; admin management operations; ledger sync operations.
- Post-conditions: Local state updated; server registry updated; ledger data synchronized on demand.
- Narrative: High-level component view connecting mobile layers, server services, ledger integration, and optional demo/reference stacks.

### Figure 29. Component Diagram - Mobile Application Layers
- File: `diagrams/component-mobile-layers.mmd`
- Priority: A
- Actors: Holder / Wallet User
- Preconditions: Flutter UI and Riverpod providers present; repositories/services defined.
- Triggers: UI observes providers; features invoke domain APIs.
- Post-conditions: Layer boundaries are established and consistent across features.
- Narrative: Shows the mobile app's layered decomposition (UI, state, domain APIs, services, models, and persistence).

### Figure 30. Component Diagram - Mobile Core Services
- File: `diagrams/component-mobile-services.mmd`
- Priority: A
- Actors: Holder / Wallet User, Platform Keychain/Keystore (see Actor Glossary)
- Preconditions: Service interfaces exist; platform packages are available in the Flutter project dependencies.
- Triggers: Biometric/crypto/secure-storage operations are invoked once wired into UI/features.
- Post-conditions: Platform security services are used consistently for gated access and secure material handling.
- Narrative: Depicts the mobile security-related service components and their intended platform dependencies.

### Figure 31. Component Diagram - Server Architecture Overview
- File: `diagrams/component-server-overview.mmd`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Server Admin API, QuantumZero Web Frontend, PostgreSQL (Admin DB), Ledger Browser (VON)
- Preconditions: Docker compose stack running; `DATABASE_URL` and `LEDGER_URL` configured.
- Triggers: Admin uses dashboard pages; browser issues API requests; API issues DB/ledger requests.
- Post-conditions: Registry/auth records updated; health/metrics/stats views populated.
- Narrative: High-level server component view showing the two Rust services and their external dependencies.

### Figure 32. Component Diagram - Server Service Internals
- File: `diagrams/component-server-microservices.mmd`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Server Admin API, QuantumZero Web Frontend
- Preconditions: Service code present; shared libraries available in Rust workspace.
- Triggers: Route configuration; handler execution; web frontend static resource serving.
- Post-conditions: Internal module responsibilities are delineated (routes/handlers/models/state; web static serving).
- Narrative: Breaks down Admin API and Web Frontend into their key internal modules and dependencies.

### Figure 33. Component Diagram - Server Core API Services (Admin/Issuance/Revocation/Verification)
- File: `diagrams/component-server-core-services.mmd`
- Priority: B
- Actors: Admin User (Browser), Issuer System / Operator, Verifier / Relying Party, Ledger Browser (VON), PostgreSQL (Admin DB) (see Actor Glossary)
- Preconditions: API gateway deployed; issuance/verification/revocation services implemented; routing policy defined.
- Triggers: HTTPS requests routed to the correct API; services emit audit logs; services consult trust registry and ledger.
- Post-conditions: Requests are routed and processed by the correct service; audit logging is performed; ledger/trust registry interactions occur as required by policy.
- Narrative: Target component topology showing an API gateway fronting the four API services, with shared trust registry and audit logging concerns.

### Figure 34. Deployment Diagram - QuantumZero Server Infrastructure (PoC)
- File: `diagrams/deployment-server-infrastructure.mmd`
- Priority: A
- Actors: Admin User (Browser), Holder / Wallet User (see Actor Glossary)
- Preconditions: Docker host available; required ports free; external Docker network `indy` exists.
- Triggers: Containers started; admin uses dashboard; Admin API performs periodic ledger sync.
- Post-conditions: Server services reachable; DB persists registry/auth state; ledger browser reachable for queries.
- Narrative: Shows the deployed PoC stack: Admin API + Web Frontend + PostgreSQL + ledger network access, plus the mobile device context.

### Figure 35. Deployment Diagram - Indy Ledger Network (Docker)
- File: `diagrams/deployment-ledger-indy-network.mmd`
- Priority: A
- Actors: Ledger operators (administration), Ledger Browser (VON), Indy Pool (node1..node4)
- Preconditions: Docker host available; `indy` network created; ledger compose started.
- Triggers: Node startup; controller actions; ledger browser queries.
- Post-conditions: Indy pool available and discoverable through the ledger browser HTTP endpoints.
- Narrative: Captures the ledger-side deployment that the server uses for DID/schema/cred-def discovery via the ledger browser.

### Figure 36. Deployment Diagram - Ledger Demo Agents (ACA-Py) (Optional)
- File: `diagrams/deployment-ledger-demo-acapy-agents.mmd`
- Priority: B
- Actors: Demo Operator, ACA-Py Agents, tails-server, Indy Pool, Ledger Browser (see Actor Glossary)
- Preconditions: `indy` network exists; ledger demo compose started.
- Triggers: Operator drives demo flows using exposed ACA-Py admin ports.
- Post-conditions: Demo agents are available to simulate issuer/holder/verifier interactions against the Indy ledger.
- Narrative: Documents the optional ACA-Py based demo microservice stack present in the server workspace (`ledgerDemo`).

### Figure 37. Architecture - Server System Overview
- File: `diagrams/architecture-server-system-overview.mmd`
- Priority: B
- Actors: Holder / Wallet User, Verifier / Relying Party, Admin User (Browser)
- Preconditions: Mobile app and server services available; ledger browser reachable for ledger operations.
- Triggers: Wallet UI use; admin operations; ledger sync operations.
- Post-conditions: Local UI state changes and server registry/ledger views are consistent with system components.
- Narrative: End-to-end view connecting the mobile wallet layers to the server admin stack and Indy ledger integration.

### Figure 38. Architecture - Indy Ledger Integration
- File: `diagrams/architecture-server-trusted-ledger.mmd`
- Priority: B
- Actors: QuantumZero Server Admin API, Ledger Browser (VON), Indy Pool (node1..node4)
- Preconditions: `LEDGER_URL` configured; ledger browser reachable on the `indy` Docker network.
- Triggers: Admin API ledger queries; startup/interval ledger sync.
- Post-conditions: Ledger observations are consumed by the Admin API and optionally persisted to PostgreSQL.
- Narrative: Focused architecture view of the Admin API to ledger browser to Indy pool data path.

### Figure 39. ER Diagram - Admin API Database Schema (PostgreSQL)
- File: `diagrams/erdiagram-server-admin-db.mmd`
- Priority: A
- Actors: QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Migrations applied from `QuantumZero-server/services/admin-api/migrations/*`.
- Triggers: Admin API startup migration run; CRUD operations via handlers.
- Post-conditions: Data is stored in tables matching the diagram (issuers, schemas, cred defs, audit logs, users, sessions).
- Narrative: Captures the Admin API persistence schema used for registry and authentication/session management.

### Figure 40. ER Diagram - Trusted Registry Database Schema (LedgerDB)
- File: `diagrams/erdiagram-server-trust-registry-db.mmd`
- Priority: B
- Actors: Trusted Registry DB (LedgerDB), Admin User (Browser)
- Preconditions: Trusted registry schema applied via `services/gateway-migrations/`.
- Triggers: Trust registry administration operations and offline cache packaging.
- Post-conditions: Trusted registry data supports policy/template/issuer directory governance workflows once wired.
- Narrative: Documents the server-side trusted registry schema used to store issuer directory entries, templates, trust policies, and offline cache packages.

### Figure 41. ER Diagram - Mobile Local Database Schema (SQLite)
- File: `diagrams/erdiagram-mobile-local-db.mmd`
- Priority: C
- Actors: QuantumZero Mobile App, Local SQLite store
- Preconditions: Local DB schema created in SQLite (per repository schema comments).
- Triggers: Wallet persistence operations (save/load DID and credentials).
- Post-conditions: DIDs and credentials are persisted locally for offline-friendly UX.
- Narrative: Records the intended local persistence schema described in the mobile repository stubs.

### Figure 42. Activity Diagram - Mobile Attribute Minimization
- File: `diagrams/activity-mobile-attribute-minimization.mmd`
- Priority: B
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Wallet has at least one credential; verifier request indicates required attributes.
- Triggers: User chooses to present a proof/presentation.
- Post-conditions: Only the minimum necessary attributes are selected for inclusion in the proof/presentation.
- Narrative: Describes the decision flow for minimizing disclosed attributes in the wallet UX.

### Figure 43. Activity Diagram - Mobile Navigation
- File: `diagrams/activity-mobile-navigation.mmd`
- Priority: B
- Actors: Holder / Wallet User
- Preconditions: App installed and launches successfully.
- Triggers: User taps navigation actions and routes.
- Post-conditions: User arrives at the expected screen (home, scan, present, settings).
- Narrative: Documents the app navigation flow as implemented in routes/screens.

### Figure 44. Activity Diagram - SDK Evaluation Workflow
- File: `diagrams/activity-server-sdk-evaluation.mmd`
- Priority: C
- Actors: Project developers/architects
- Preconditions: Candidate libraries identified; evaluation criteria defined.
- Triggers: Technology selection work for future features (e.g., proof/verification support).
- Post-conditions: A candidate is selected or rejected with documented rationale.
- Narrative: Documents the project's intended workflow for evaluating SDKs/libraries without asserting a selected protocol.

### Figure 45. Activity Diagram - ZKP Tooling Comparison
- File: `diagrams/activity-server-zkp-tooling-comparison.mmd`
- Priority: C
- Actors: Project developers/architects
- Preconditions: ZKP needs identified; candidate approaches listed.
- Triggers: ZKP design/planning work.
- Post-conditions: A tooling direction is chosen or deferred with documented constraints.
- Narrative: Provides a high-level workflow for comparing ZKP tooling options in the project context.

### Figure 46. Sequence Diagram - Mobile Biometric Authentication
- File: `diagrams/sequence-mobile-biometric-authentication.mmd`
- Priority: B
- Actors: Holder / Wallet User, Platform Keychain/Keystore
- Preconditions: Biometrics enrolled; biometric API available.
- Triggers: User attempts to unlock wallet or approve a sensitive operation.
- Post-conditions: Operation proceeds only after successful biometric authentication.
- Narrative: Shows the biometric-gating sequence for protected wallet actions through the BiometricService/local_auth boundary.

### Figure 47. Sequence Diagram - Mobile Crypto Validation
- File: `diagrams/sequence-mobile-crypto-validation.mmd`
- Priority: B
- Actors: QuantumZero Mobile App, CryptoService (see Actor Glossary)
- Preconditions: Crypto service interface available; inputs provided.
- Triggers: App validates hashes/signatures as part of a credential/proof workflow.
- Post-conditions: Validation result returned to the calling feature/UI.
- Narrative: Shows key generation and hashing calls in `CryptoServiceImpl` using the `cryptography` package.

### Figure 48. Sequence Diagram - Mobile DID Generation
- File: `diagrams/sequence-mobile-did-generation.mmd`
- Priority: C
- Actors: QuantumZero Mobile App, CryptoService, SecureStorageService, DidRepository, Local SQLite store
- Preconditions: Crypto key generation and DID repository operations are available.
- Triggers: User requests a new DID.
- Post-conditions: A new DID record is created and persisted; state updates to reflect active DID.
- Narrative: Describes the DID generation and persistence sequence.

### Figure 49. Sequence Diagram - Mobile Credential Storage
- File: `diagrams/sequence-mobile-vc-storage.mmd`
- Priority: C
- Actors: Holder / Wallet User, CredentialRepository, Local SQLite store
- Preconditions: CredentialRepository operations are available; local SQLite store initialized.
- Triggers: Wallet feature stores and retrieves credentials through the repository.
- Post-conditions: Credential data is persisted and returned through repository queries.
- Narrative: Describes local credential persistence through the repository and SQLite store.

### Figure 50. Sequence Diagram - Mobile Prove a Fact (VP via QR)
- File: `diagrams/sequence-mobile-vp-presentation.mmd`
- Priority: B
- Actors: Holder / Wallet User, Verifier / Relying Party, Platform Keychain/Keystore
- Preconditions: Verifier request available as a QR payload; wallet has at least one eligible credential.
- Triggers: User scans a proof request and approves presenting selected claims.
- Post-conditions: A presentation payload is generated and rendered as a QR for the verifier to scan.
- Narrative: Shows QR scan/parse, user-driven selective disclosure, signing, and QR presentation.

### Figure 51. Sequence Diagram - Server Auth Session
- File: `diagrams/sequence-server-auth-session.mmd`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Web Frontend, QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Admin API running; users table seeded; DB reachable.
- Triggers: Admin submits login/logout/session verification requests.
- Post-conditions: Session token issued/invalidated/validated; server responds with auth state.
- Narrative: Shows the authentication/session management interaction between the dashboard, Admin API, and database.

### Figure 52. Sequence Diagram - Server Issuer Management
- File: `diagrams/sequence-server-issuer-management.mmd`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Admin session valid; DB migrated.
- Triggers: Admin performs issuer list/create/read/update operations.
- Post-conditions: Issuer records updated in PostgreSQL and returned in API responses.
- Narrative: Documents the issuer CRUD sequence through the Admin API.

### Figure 53. Sequence Diagram - Server Schema Management
- File: `diagrams/sequence-server-schema-management.mmd`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Server Admin API, PostgreSQL (Admin DB), Ledger Browser (VON)
- Preconditions: Admin session valid; DB migrated; ledger browser reachable for import/sync paths.
- Triggers: Admin performs schema list/create/read/import operations.
- Post-conditions: Schema records updated and/or imported; results returned to admin.
- Narrative: Shows the schema management flow including the ledger import path.

### Figure 54. Sequence Diagram - Server Credential Definition Management
- File: `diagrams/sequence-server-cred-def-management.mmd`
- Priority: A
- Actors: Admin User (Browser), QuantumZero Server Admin API, PostgreSQL (Admin DB)
- Preconditions: Admin session valid; DB migrated.
- Triggers: Admin performs credential definition list/create/read operations.
- Post-conditions: Credential definition records updated in PostgreSQL and returned in API responses.
- Narrative: Documents the credential definition management sequence through the Admin API.

### Figure 55. Sequence Diagram - Server Ledger Sync
- File: `diagrams/sequence-server-ledger-sync.mmd`
- Priority: A
- Actors: QuantumZero Server Admin API, Ledger Browser (VON), PostgreSQL (Admin DB)
- Preconditions: `LEDGER_URL` configured; ledger browser reachable; DB migrated.
- Triggers: Admin API startup sync; periodic background sync; manual sync endpoint.
- Post-conditions: Issuers/schemas/cred defs discovered from ledger browser are persisted and reported.
- Narrative: Shows automated and manual ledger synchronization behavior implemented by the Admin API.

### Figure 56. Sequence Diagram - Server Replay Protection
- File: `diagrams/sequence-server-replay-protection.mmd`
- Priority: B
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Nonce/timestamp strategy implemented in request and presentation flow.
- Triggers: Wallet processes a verifier request that includes challenge material.
- Post-conditions: Replay attempts are rejected based on nonce/timestamp checks.
- Narrative: Describes replay protection for proof requests and responses using nonce/timestamp checks.

### Figure 57. Sequence Diagram - Server Revocation Check
- File: `diagrams/sequence-server-revocation-check.mmd`
- Priority: C
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Revocation/status mechanism identified and implemented.
- Triggers: Verifier performs a verification that requires revocation/status evaluation.
- Post-conditions: Verification decision incorporates revocation/status outcomes.
- Narrative: Documents a revocation/status check step in the verification flow.

### Figure 58. Sequence Diagram - Mobile Android Hardware-backed Key Generation
- File: `diagrams/sequence-mobile-android-key-generation.mmd`
- Priority: A
- Actors: Holder / Wallet User, QuantumZero Mobile App, Android Keystore/StrongBox (see Actor Glossary)
- Preconditions: Wallet installed; Android platform key APIs available; wallet initialization or DID creation workflow invoked.
- Triggers: Crypto service requests a new signing key pair.
- Post-conditions: A non-exportable key pair is created and referenced by the wallet; public key material is available for DID construction.
- Narrative: Details the Android-specific key generation subflow used by wallet cryptographic operations; complements `diagrams/sequence-mobile-did-generation.mmd`.

### Figure 59. Sequence Diagram - Mobile iOS Hardware-backed Key Generation
- File: `diagrams/sequence-mobile-ios-key-generation.mmd`
- Priority: A
- Actors: Holder / Wallet User, QuantumZero Mobile App, iOS Keychain/Secure Enclave (see Actor Glossary)
- Preconditions: Wallet installed; iOS platform key APIs available; wallet initialization or DID creation workflow invoked.
- Triggers: Crypto service requests a new signing key pair.
- Post-conditions: A non-exportable key pair is created and referenced by the wallet; public key material is available for DID construction.
- Narrative: Details the iOS-specific key generation subflow used by wallet cryptographic operations; complements `diagrams/sequence-mobile-did-generation.mmd`.

### Figure 60. Sequence Diagram - Mobile Repository Initialization (SQLite + Secure Storage)
- File: `diagrams/sequence-mobile-local-storage-setup.mmd`
- Priority: A
- Actors: QuantumZero Mobile App, SecureStorageService, DidRepository, CredentialRepository, Local SQLite store
- Preconditions: App first run or storage cleared; secure storage and SQLite are available on the device.
- Triggers: App startup triggers repository initialization.
- Post-conditions: Local SQLite schema is ready; repositories can persist and retrieve wallet data.
- Narrative: Captures initialization ordering between secure storage, repositories, and local SQLite; complements `diagrams/component-mobile-layers.mmd`.

### Figure 61. Sequence Diagram - Mobile Non-exportable Key Usage
- File: `diagrams/sequence-mobile-non-exportable-keys.mmd`
- Priority: A
- Actors: QuantumZero Mobile App, Platform Keychain/Keystore, CryptoService, SecureStorageService
- Preconditions: Hardware-backed key material exists; a signing/verification operation is requested by a wallet feature.
- Triggers: Wallet requests a signature over message/challenge material.
- Post-conditions: A signature is produced without exporting private key material and returned to the caller.
- Narrative: Shows how wallet cryptographic operations use key references/aliases rather than raw key extraction; complements `diagrams/sequence-mobile-crypto-validation.mmd`.

### Figure 62. Sequence Diagram - Concept: Offline Verification (Cache-first)
- File: `diagrams/sequence-mobile-offline-verification.mmd`
- Priority: C
- Actors: Verifier App (offline-capable), Holder / Wallet User
- Preconditions: Verifier has cached issuer key material and status information; a presentation request and response channel exists.
- Triggers: Verifier requests a presentation and receives a response payload.
- Post-conditions: Verifier makes an accept/reject decision based on cached resolution and signature verification outcomes.
- Narrative: Describes a cache-first verifier workflow without asserting a specific transport or server dependency.

### Figure 63. Sequence Diagram - Concept: Online Sync (Cache Refresh)
- File: `diagrams/sequence-mobile-online-sync.mmd`
- Priority: B
- Actors: QuantumZero Mobile App, QuantumZero Server API Suite, Local SQLite store
- Preconditions: Network connectivity; wallet has local cache/state to refresh.
- Triggers: Scheduled refresh or user-initiated sync.
- Post-conditions: Cached registry/status data is updated locally and used for subsequent operations.
- Narrative: Provides a generic cache refresh pattern for wallet-side data needed for verification/status decisions.

### Figure 64. Sequence Diagram - Mobile Secure QR Payload Generation
- File: `diagrams/sequence-mobile-proof-generation.mmd`
- Priority: B
- Actors: Holder / Wallet User, QuantumZero Mobile App, CryptoService, QrGenerationService
- Preconditions: Wallet unlocked; required inputs (challenge/request) available; signing key reference available.
- Triggers: User approves producing a QR payload for a verifier to scan.
- Post-conditions: Signed, integrity-protected QR payload is generated for display.
- Narrative: Breaks out the QR payload generation subflow used by `diagrams/sequence-mobile-vp-presentation.mmd`.

### Figure 65. Sequence Diagram - Mobile Replay Protection (QR Validation)
- File: `diagrams/sequence-mobile-replay-protection.mmd`
- Priority: B
- Actors: QuantumZero Mobile App, QrScanningService, CryptoService
- Preconditions: Wallet can store recent nonces/timestamps; scanned QR payload includes challenge material.
- Triggers: User scans a QR payload for verification or proof request processing.
- Post-conditions: Replayed or expired payloads are rejected before processing proceeds.
- Narrative: Describes wallet-side replay checks when consuming QR-based requests; complements `diagrams/sequence-server-replay-protection.mmd`.

### Figure 66. Sequence Diagram - Concept: Wallet Credential Status Check
- File: `diagrams/sequence-mobile-revocation-check.mmd`
- Priority: B
- Actors: QuantumZero Mobile App, QuantumZero Server API Suite
- Preconditions: Wallet has a credential record; status information can be evaluated locally and/or via a network query path.
- Triggers: Wallet or verifier workflow requires a credential status decision.
- Post-conditions: Credential is treated as active/revoked/unknown for the current operation.
- Narrative: Captures a generic status check pattern without asserting a specific revocation mechanism implementation.

### Figure 67. Sequence Diagram - Mobile Selective Disclosure (Service Flow)
- File: `diagrams/sequence-mobile-selective-disclosure.mmd`
- Priority: B
- Actors: Holder / Wallet User, SelectiveDisclosureService, CredentialRepository, CryptoService
- Preconditions: Wallet has at least one eligible credential; proof request specifies required predicates/attributes.
- Triggers: User approves sharing only requested attributes.
- Post-conditions: A proof/presentation payload is produced with minimized attribute disclosure.
- Narrative: Breaks out the SelectiveDisclosureService internal steps supporting `diagrams/sequence-mobile-vp-presentation.mmd`.

### Figure 68. Sequence Diagram - Concept: Verification API Signature Verification
- File: `diagrams/sequence-mobile-vc-signature-verification.mmd`
- Priority: B
- Actors: QuantumZero Server API Suite, Ledger Browser (VON), Indy Pool (node1..node4)
- Preconditions: Verification request received; required issuer DID/key material can be resolved through ledger query paths.
- Triggers: Server verifies a submitted VP/VC signature as part of verification processing.
- Post-conditions: Verification result produced (valid/invalid) and returned to the caller.
- Narrative: Describes the signature verification steps a server verification surface performs when resolving issuer keys via ledger query services.

### Figure 69. Sequence Diagram - Concept: Credential Lifecycle (Issuance to Presentation)
- File: `diagrams/sequence-mobile-vc-workflow.mmd`
- Priority: B
- Actors: Holder / Wallet User, Issuer System / Operator, Verifier / Relying Party, QuantumZero Mobile App
- Preconditions: Wallet initialized; issuance and verification parties exist for the credential domain.
- Triggers: Credential issuance and later proof/presentation events.
- Post-conditions: Credential is stored and later used to generate a presentation for a verifier.
- Narrative: High-level lifecycle overview that references more detailed issuance/presentation sequences in `diagrams/` and `diagrams/`.

### Figure 70. Sequence Diagram - Concept: VerifiablePresentation Assembly
- File: `diagrams/sequence-mobile-vp-creation.mmd`
- Priority: B
- Actors: QuantumZero Mobile App, SelectiveDisclosureService, CryptoService
- Preconditions: A proof request and selected claims are available.
- Triggers: Wallet assembles a VP payload for presentation.
- Post-conditions: A VP object is assembled and ready for signing/transport.
- Narrative: Describes VP assembly as a reusable internal step for multiple presentation channels (QR, deep link, etc.).

### Figure 71. Sequence Diagram - Concept: ZKP Circuit (Range Check Predicate)
- File: `diagrams/sequence-mobile-zkp-circuits.mmd`
- Priority: C
- Actors: QuantumZero Mobile App, SelectiveDisclosureService
- Preconditions: Proof request requires a predicate/range check; wallet has credential attributes to satisfy it.
- Triggers: Wallet generates a proof/predicate evaluation for selective disclosure.
- Post-conditions: Predicate proof material is produced or the operation fails cleanly.
- Narrative: Concept-level circuit/predicate depiction used to reason about ZKP-based selective disclosure.

### Figure 72. Sequence Diagram - Concept: ZKP Failure Handling
- File: `diagrams/sequence-mobile-zkp-failure-handling.mmd`
- Priority: C
- Actors: Holder / Wallet User, SelectiveDisclosureService, QuantumZero Mobile App
- Preconditions: A proof generation operation is attempted and an error condition occurs.
- Triggers: Proof generation fails due to invalid inputs, missing credential material, or cryptographic failure.
- Post-conditions: User receives a clear failure outcome and the wallet remains in a safe state.
- Narrative: Documents error handling paths for proof generation to keep user experience and security posture consistent.

### Figure 73. Interface Diagram - Mobile Wallet (Navigation Overview)
- File: `diagrams/interface-mobile.mmd`
- Priority: C
- Actors: Holder / Wallet User
- Preconditions: Mobile app installed; wallet initialized.
- Triggers: User navigates between primary screens.
- Post-conditions: Navigation paths and return routes are understood at a glance.
- Narrative: High-level navigation overview for the mobile wallet UI states.

### Figure 74. Interface Diagram - Mobile Presentation Flow (Detail)
- File: `diagrams/interface-mobile-presentation.mmd`
- Priority: C
- Actors: Holder / Wallet User, Verifier / Relying Party
- Preconditions: Credential detail view is accessible.
- Triggers: User initiates credential presentation.
- Post-conditions: Presentation flow is clarified from selection to verification result.
- Narrative: Detailed UI flow for credential presentation and verification result handling.

### Figure 75. Interface Diagram - Server Admin (Registry Operations)
- File: `diagrams/interface-server-1.mmd`
- Priority: C
- Actors: Admin User (Browser)
- Preconditions: Admin authenticated; dashboard accessible.
- Triggers: Admin navigates issuer/schema/revocation management screens.
- Post-conditions: Screen transitions for registry operations are defined.
- Narrative: UI flow for admin registry operations (issuers, schemas, revocation).

### Figure 76. Interface Diagram - Server Admin (Audit + Health)
- File: `diagrams/interface-server-2.mmd`
- Priority: C
- Actors: Admin User (Browser)
- Preconditions: Admin authenticated; dashboard accessible.
- Triggers: Admin opens audit logs or health monitoring.
- Post-conditions: Screen transitions for audit/health features are defined.
- Narrative: UI flow for audit log viewing and system health monitoring.

### Figure 77. Class Diagram - Server Admin API Models (Detail)
- File: `diagrams/class-server-models-admin-api.mmd`
- Priority: C
- Actors: QuantumZero Server developers
- Preconditions: Admin API models exist in `services/admin-api/src/models.rs`.
- Triggers: Model review or contract update.
- Post-conditions: Admin API model structures are documented in isolation.
- Narrative: Focused class diagram for Admin API request/response and domain records.

### Figure 78. Class Diagram - Server Issuance API Models (Detail)
- File: `diagrams/class-server-models-issuance-api.mmd`
- Priority: C
- Actors: QuantumZero Server developers
- Preconditions: Issuance API models exist in `services/issuance-api/src/models.rs`.
- Triggers: Issuance flow design or update.
- Post-conditions: Issuance API model structures are documented in isolation.
- Narrative: Focused class diagram for issuance request/response models.

### Figure 79. Class Diagram - Server Revocation API Models (Detail)
- File: `diagrams/class-server-models-revocation-api.mmd`
- Priority: C
- Actors: QuantumZero Server developers
- Preconditions: Revocation API models exist in `services/revocation-api/src/models.rs`.
- Triggers: Revocation flow design or update.
- Post-conditions: Revocation API model structures are documented in isolation.
- Narrative: Focused class diagram for revocation request/response models.

### Figure 80. Class Diagram - Server Verification API Models (Detail)
- File: `diagrams/class-server-models-verification-api.mmd`
- Priority: C
- Actors: QuantumZero Server developers
- Preconditions: Verification API models exist in `services/verification-api/src/models.rs`.
- Triggers: Verification flow design or update.
- Post-conditions: Verification API model structures are documented in isolation.
- Narrative: Focused class diagram for verification request/response models.

### Figure 81. Class Diagram - Server Common Models (Detail)
- File: `diagrams/class-server-models-common.mmd`
- Priority: C
- Actors: QuantumZero Server developers
- Preconditions: Shared models exist in `shared/common/src/lib.rs`.
- Triggers: Shared response/health model updates.
- Post-conditions: Common model structures are documented in isolation.
- Narrative: Focused class diagram for shared response/health/metrics models.

### Figure 82. ER Diagram - Gateway Request Tables Schema (PostgreSQL)
- File: `diagrams/erdiagram-server-request-tables.mmd`
- Priority: B
- Actors: QuantumZero Server API suite, PostgreSQL (Staging DB)
- Preconditions: Staging schema applied via gateway migrations.
- Triggers: Staged request review or data model audit.
- Post-conditions: Request table structures are documented.
- Narrative: Consolidated ER diagram of all staging request tables.

### Figure 83. ER Diagram - Registry Request Tables (PostgreSQL)
- File: `diagrams/erdiagram-server-request-registry.mmd`
- Priority: C
- Actors: QuantumZero Server API suite, PostgreSQL (Staging DB)
- Preconditions: Staging schema applied via gateway migrations.
- Triggers: Registry request flow review.
- Post-conditions: Registry request table structures are documented in isolation.
- Narrative: Focused ER view for issuer/schema/cred-def request tables.

### Figure 84. ER Diagram - Operational Request Tables (PostgreSQL)
- File: `diagrams/erdiagram-server-request-ops.mmd`
- Priority: C
- Actors: QuantumZero Server API suite, PostgreSQL (Staging DB)
- Preconditions: Staging schema applied via gateway migrations.
- Triggers: Issuance/verification/revocation request flow review.
- Post-conditions: Operational request table structures are documented in isolation.
- Narrative: Focused ER view for issuance, verification, and revocation requests.

### Figure 85. ER Diagram - Trusted Registry Core Tables (PostgreSQL)
- File: `diagrams/erdiagram-server-trust-registry-core.mmd`
- Priority: C
- Actors: Admin User (Browser), Trusted Registry DB
- Preconditions: Trusted registry schema applied via `services/gateway-migrations/`.
- Triggers: Registry schema review.
- Post-conditions: Core registry tables (issuers, schemas, cred defs, rev regs) are documented in isolation.
- Narrative: Focused ER view of core trusted registry tables.

### Figure 86. ER Diagram - Trusted Registry Policy & Offline Cache Tables (PostgreSQL)
- File: `diagrams/erdiagram-server-trust-registry-policy.mmd`
- Priority: C
- Actors: Admin User (Browser), Trusted Registry DB
- Preconditions: Trusted registry schema applied via `services/gateway-migrations/`.
- Triggers: Policy/offline cache schema review.
- Post-conditions: Policy and offline cache tables are documented in isolation.
- Narrative: Focused ER view for trust policy configuration and offline cache packaging.

### Figure 87. Feasibility Chart - Projected Operational Costs
- File: `diagrams/feasability.mmd`
- Priority: C
- Actors: Project stakeholders
- Preconditions: Cost projection inputs are defined.
- Triggers: Planning and cost review.
- Post-conditions: 4-year operational cost projection is communicated.
- Narrative: Simple cost projection chart for planning discussions.

### Figure 88. DFD Level 0 - Admin Registry System (Context Diagram)
- File: `diagrams/dfd-server-admin-registry-L0.mmd`
- Priority: B
- Narrative: Context diagram showing the Admin Registry Management System as a single process interacting with Admin User and Indy Ledger.
- Preconditions: Admin authenticated; ledger reachable.
- Trigger: Admin registry operations or sync commands.
- Post-conditions: Registry requests handled; ledger queries executed; responses returned.

### Figure 89. DFD Level 1 - Manage Issuers (Process 1.0)
- File: `diagrams/dfd-server-admin-registry-L1.mmd`
- Priority: B
- Narrative: Decomposes issuer management into validation, persistence, retrieval, and audit logging.
- Preconditions: Admin authenticated; registry DB available.
- Trigger: Issuer create/update or read requests.
- Post-conditions: Issuer records stored/retrieved; audit event recorded.

### Figure 90. DFD Level 1 - Manage Schemas (Process 2.0)
- File: `diagrams/dfd-server-admin-registry-L1-schemas.mmd`
- Priority: B
- Narrative: Decomposes schema management into validation, persistence, retrieval, and audit logging.
- Preconditions: Admin authenticated; registry DB available.
- Trigger: Schema create/update or read requests.
- Post-conditions: Schema records stored/retrieved; audit event recorded.

### Figure 91. DFD Level 1 - Manage Credential Definitions (Process 3.0)
- File: `diagrams/dfd-server-admin-registry-L1-cred-defs.mmd`
- Priority: B
- Narrative: Decomposes credential definition management into validation, persistence, retrieval, and audit logging.
- Preconditions: Admin authenticated; registry DB available.
- Trigger: Cred def create/update or read requests.
- Post-conditions: Cred def records stored/retrieved; audit event recorded.

### Figure 92. DFD Level 1 - Sync From Ledger (Process 4.0)
- File: `diagrams/dfd-server-admin-registry-L1-sync.mmd`
- Priority: B
- Narrative: Decomposes ledger sync into scanning, validation, persistence, and reporting.
- Preconditions: Ledger reachable; registry DB available.
- Trigger: Admin sync command.
- Post-conditions: Registry data updated; sync report returned.

### Figure 93. DFD Level 1 - Audit Logging (Process 5.0)
- File: `diagrams/dfd-server-admin-registry-L1-audit.mmd`
- Priority: C
- Narrative: Centralizes audit event intake, storage, and retrieval for registry operations.
- Preconditions: Admin DB available.
- Trigger: Registry process audit events or admin audit log query.
- Post-conditions: Audit records stored/retrieved.

### Figure 94. DFD Level 0 - Ledger Query & Monitoring (Context Diagram)
- File: `diagrams/dfd-server-ledger-queries-L0.mmd`
- Priority: B
- Narrative: Context diagram showing ledger query & monitoring as a single process interacting with Admin User and Indy Ledger.
- Preconditions: Admin authenticated; ledger reachable.
- Trigger: Health/pool/schema/sync requests.
- Post-conditions: Ledger data returned to admin.

### Figure 95. DFD Level 1 - Health & Metrics Monitoring (Process 1.0)
- File: `diagrams/dfd-server-ledger-queries-L1.mmd`
- Priority: B
- Narrative: Decomposes health checks into validation, ledger status query, and response compilation.
- Preconditions: Ledger reachable.
- Trigger: Health request.
- Post-conditions: Health response returned.

### Figure 96. DFD Level 1 - Query Pool Nodes (Process 2.0)
- File: `diagrams/dfd-server-ledger-queries-L1-pool-nodes.mmd`
- Priority: B
- Narrative: Decomposes pool node queries into validation, ledger query, and response formatting.
- Preconditions: Ledger reachable.
- Trigger: Pool node request.
- Post-conditions: Node data returned.

### Figure 97. DFD Level 1 - Import Schema By ID (Process 3.0)
- File: `diagrams/dfd-server-ledger-queries-L1-import-schema.mmd`
- Priority: B
- Narrative: Decomposes schema import into validation, ledger query, persistence, and result return.
- Preconditions: Ledger reachable; registry DB available.
- Trigger: Schema import request.
- Post-conditions: Schema record stored; result returned.

### Figure 98. DFD Level 1 - Full Ledger Sync (Process 4.0)
- File: `diagrams/dfd-server-ledger-queries-L1-sync.mmd`
- Priority: B
- Narrative: Decomposes full ledger sync into scanning, validation, persistence, and reporting.
- Preconditions: Ledger reachable; registry DB available.
- Trigger: Full sync command.
- Post-conditions: Registry data updated; report returned.

### Figure 99. DFD Level 2 - Full Ledger Sync (Process 4.0 Detailed)
- File: `diagrams/dfd-server-ledger-queries-L2-sync.mmd`
- Priority: C
- Narrative: Detailed ledger sync steps for NYM/SCHEMA/CRED_DEF scans and validation.
- Preconditions: Ledger reachable; registry DB available.
- Trigger: Full sync request with transaction range.
- Post-conditions: Records stored; summary returned.

### Figure 100. DFD Level 0 - Staged Registry Approval System (Context Diagram)
- File: `diagrams/dfd-server-trust-registry-admin-L0.mmd`
- Priority: B
- Narrative: Context diagram for staged registry approval with Admin and Issuer interactions.
- Preconditions: Admin authenticated; issuer able to submit requests.
- Trigger: Issuer submissions or admin review.
- Post-conditions: Approval results and status updates returned.

### Figure 101. DFD Level 1 - Issuer Onboarding (Process 1.0)
- File: `diagrams/dfd-server-trust-registry-admin-L1.mmd`
- Priority: B
- Narrative: Decomposes issuer onboarding into validation, staging, review, approval, and audit logging.
- Preconditions: Admin authenticated; staging DB available.
- Trigger: Issuer onboarding request.
- Post-conditions: Issuer stored and status updated.

### Figure 102. DFD Level 1 - Approve Schema Requests (Process 2.0)
- File: `diagrams/dfd-server-trust-registry-admin-L1-schema-requests.mmd`
- Priority: B
- Narrative: Decomposes schema request approvals into validation, staging, review, approval, and audit logging.
- Preconditions: Admin authenticated; staging DB available.
- Trigger: Schema request submission.
- Post-conditions: Schema stored and status updated.

### Figure 103. DFD Level 1 - Approve Cred Def Requests (Process 3.0)
- File: `diagrams/dfd-server-trust-registry-admin-L1-cred-def-requests.mmd`
- Priority: B
- Narrative: Decomposes cred def request approvals into validation, staging, review, approval, and audit logging.
- Preconditions: Admin authenticated; staging DB available.
- Trigger: Cred def request submission.
- Post-conditions: Cred def stored and status updated.

### Figure 104. DFD Level 1 - Manage Trust Policies (Process 4.0)
- File: `diagrams/dfd-server-trust-registry-admin-L1-policy.mmd`
- Priority: C
- Narrative: Decomposes trust policy management into validation, definition, scoping, publishing, and audit logging.
- Preconditions: Admin authenticated; policy tables available.
- Trigger: Policy CRUD operations.
- Post-conditions: Policy records updated; audit logged.

### Figure 105. DFD Level 1 - Audit Logging (Process 5.0)
- File: `diagrams/dfd-server-trust-registry-admin-L1-audit.mmd`
- Priority: C
- Narrative: Centralizes audit event intake, storage, and retrieval for trust registry operations.
- Preconditions: Admin DB available.
- Trigger: Registry process audit events or admin audit log query.
- Post-conditions: Audit records stored/retrieved.

### Figure 106. Interface Diagram - Mobile DID Management
- File: `diagrams/interface-mobile-did.mmd`
- Priority: C
- Actors: Holder / Wallet User
- Preconditions: Wallet home accessible.
- Triggers: User selects DID Management.
- Post-conditions: DID creation/view flows are understood.
- Narrative: Concise window navigation for DID management screens.

### Figure 107. Interface Diagram - Mobile Credential Management
- File: `diagrams/interface-mobile-credentials.mmd`
- Priority: C
- Actors: Holder / Wallet User
- Preconditions: Credentials exist or list view available.
- Triggers: User selects a credential.
- Post-conditions: Credential detail and related report views are understood.
- Narrative: Concise window navigation for credential list/detail and related actions.

### Figure 108. Interface Diagram - Mobile Settings & Backup
- File: `diagrams/interface-mobile-settings.mmd`
- Priority: C
- Actors: Holder / Wallet User
- Preconditions: Settings view accessible.
- Triggers: User selects backup/recovery.
- Post-conditions: Backup/restore navigation is understood.
- Narrative: Concise window navigation for settings and backup flows.
