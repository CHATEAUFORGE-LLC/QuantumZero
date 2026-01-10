# QuantumZero Software Architecture Documentation
## Deliverable #1 - UML Diagram Index

**Project:** QuantumZero - Self-Sovereign Identity System  
**Date:** January 9, 2026  
**Version:** 1.0  

---

## Document Purpose

This document serves as the master index for all UML diagrams created for the QuantumZero project, fulfilling the requirements of Deliverable #1 as specified in [687-Deliverable-1.md](687-Deliverable-1.md). All diagrams adhere to UML 2.5 standards and follow proper notation as defined in:

- [UML Class Diagram Tutorial](https://www.visual-paradigm.com/guide/uml-unified-modeling-language/uml-class-diagram-tutorial/)
- [UML Diagrams Reference](https://www.uml-diagrams.org/)

---

## 1. Use Case Diagrams

Use Case diagrams show actors, processes, and system boundaries. All use cases include priority levels (A/B/C), preconditions, postconditions, and triggers as required.

### 1.1 User Authentication (App Unlock)
- **File:** [usecase-mobile-app-unlock.mmd](diagrams/usecase-mobile-app-unlock.mmd)
- **Priority:** A (Essential for system operation)
- **Purpose:** Shows how users authenticate to access the QuantumZero mobile wallet
- **Actors:** User, Biometric System, Secure Storage
- **Key Use Cases:** Launch Application, Authenticate with Biometric, Authenticate with PIN Fallback, Access Wallet, Lock Application
- **Requirements:** F-SEC-01 (Hardware-backed biometric authentication)
- **Preconditions:** App installed, user enrolled biometrics/PIN, secure hardware available
- **Postconditions:** User authenticated, wallet unlocked, session established
- **Triggers:** App launch, background return, timeout
- **Related Diagrams:** 
  - sequence-mobile-biometric-authentication.mmd (detailed flow)
  - class-mobile-services.mmd (BiometricService, SecureStorageService)

### 1.2 Authentication with External Services
- **File:** [usecase-mobile-external-authentication.mmd](diagrams/usecase-mobile-external-authentication.mmd)
- **Priority:** A (Essential for system operation)
- **Purpose:** Shows how users authenticate to external services using QuantumZero credentials
- **Actors:** User, External Service Provider, Biometric System, Crypto Engine
- **Key Use Cases:** Initiate External Authentication, Present Verifiable Credential, Generate ZKP Proof, Sign Request with DID
- **Requirements:** F-SEC-01, F-SEC-03, F-SEC-04 (Biometric auth, ZKP, Selective disclosure)
- **Preconditions:** User has wallet with valid credentials, external service supports VC/VP, biometrics enrolled
- **Postconditions:** User authenticated, auth token received, session established
- **Triggers:** Login with QuantumZero click, deep link, OAuth redirect
- **Related Diagrams:**
  - usecase-mobile-prove-fact.mmd (VP generation process)
  - sequence-mobile-proof-generation.mmd

### 1.3 Prove a Fact (Verifiable Presentation)
- **File:** [usecase-mobile-prove-fact.mmd](diagrams/usecase-mobile-prove-fact.mmd)
- **Priority:** A (Essential for system operation)
- **Purpose:** Shows how users generate and present verifiable presentations to prove claims
- **Actors:** Holder/User, Verifier, QR Scanner, Crypto Engine, Backend API
- **Key Use Cases:** Scan Verification Request QR, Select Credentials to Share, Generate Verifiable Presentation, Apply Selective Disclosure, Sign VP with DID, Present VP to Verifier
- **Requirements:** F-SEC-03, F-SEC-04 (Selective disclosure, ZKP)
- **Preconditions:** User authenticated, has valid credentials, verifier request available
- **Postconditions:** VP generated and signed, presented to verifier, result received
- **Triggers:** QR code scan, deep link, NFC tag
- **Related Diagrams:**
  - sequence-mobile-vp-creation.mmd
  - sequence-mobile-vp-presentation.mmd
  - sequence-mobile-selective-disclosure.mmd

---

## 2. Class Diagrams

Class diagrams detail data structures, system architecture, interfaces, and components. Naming conventions follow language standards: Dart (camelCase) for mobile, Rust (snake_case) for server.

### 2.1 Mobile Application Classes

#### 2.1.1 Mobile Core Data Models
- **File:** [class-mobile-models.mmd](diagrams/class-mobile-models.mmd)
- **Priority:** A
- **Purpose:** Defines core domain models for the QuantumZero mobile application
- **Language:** Dart
- **Key Classes:**
  - `Did`: W3C Decentralized Identifier with methods `fromJson()`, `toJson()`, `parse()`, `isActive()`
  - `Credential`: W3C Verifiable Credential with methods `isExpired()`, `isValid()`, `fromJson()`, `toJson()`
  - `VerifiablePresentation`: W3C Verifiable Presentation with method `isExpired()`
- **Enumerations:** DidStatus, CredentialStatus, CredentialCategory
- **Relationships:** Did → DidStatus, Credential → CredentialStatus, Credential → CredentialCategory, Credential references Did, VerifiablePresentation references Credential
- **Implementation:** QuantumZero-mobile/lib/core/models/
- **Standards:** W3C DID Core, W3C Verifiable Credentials Data Model

#### 2.1.2 Mobile Data Repositories
- **File:** [class-mobile-repositories.mmd](diagrams/class-mobile-repositories.mmd)
- **Priority:** A
- **Purpose:** Defines repository interfaces for data persistence and retrieval
- **Language:** Dart
- **Pattern:** Repository Pattern
- **Key Interfaces:**
  - `DidRepository`: Methods - initialize(), saveDid(), getDidByIdentifier(), getAllDids(), getActiveDid(), setActiveDid(), updateDid(), deactivateDid(), deleteDid()
  - `CredentialRepository`: Methods - initialize(), saveCredential(), getCredentialById(), getAllCredentials(), getCredentialsByType(), getCredentialsByIssuer(), getValidCredentials(), updateCredential(), deleteCredential()
  - `PresentationRepository`: Methods - initialize(), savePresentation(), getPresentationById(), getAllPresentations(), getPresentationsByHolder(), deletePresentation(), cleanupExpiredPresentations()
- **Dependencies:** Uses SecureStorageService, CryptoService
- **Implementation:** QuantumZero-mobile/lib/core/repositories/

#### 2.1.3 Mobile Core Services
- **File:** [class-mobile-services.mmd](diagrams/class-mobile-services.mmd)
- **Priority:** A
- **Purpose:** Defines core service interfaces for cryptography, biometrics, and secure storage
- **Language:** Dart
- **Key Interfaces:**
  - `BiometricService`: Methods - isAvailable(), isEnrolled(), authenticate(), getAvailableBiometrics()
  - `CryptoService`: Methods - generateKeyPair(), generateSecretKey(), sign(), verify(), encrypt(), decrypt(), hash(), generateNonce()
  - `SecureStorageService`: Methods - write(), read(), delete(), containsKey(), readAll(), deleteAll()
- **Enumerations:** BiometricType (face, fingerprint, iris, strong, weak)
- **Platform Implementations:** iOS (FaceID/TouchID, Secure Enclave, Keychain), Android (BiometricPrompt, Keystore/StrongBox, EncryptedSharedPreferences)
- **Requirements:** F-SEC-01, F-SEC-02
- **Implementation:** QuantumZero-mobile/lib/core/services/

### 2.2 Server Application Classes

#### 2.2.1 Server Domain Models
- **File:** [class-server-models.mmd](diagrams/class-server-models.mmd)
- **Priority:** A
- **Purpose:** Defines server-side domain models for the QuantumZero backend
- **Language:** Rust
- **Key Structs:**
  - `Issuer`: Fields - id: Uuid, did: String, verkey: String, alias: String, role: String, status: String, created_at: DateTime<Utc>, updated_at: DateTime<Utc>
  - `SchemaRecord`: Fields - id: Uuid, schema_id: String, name: String, version: String, attributes: Vec<String>, issuer_did: String, created_at: DateTime<Utc>
  - `CredentialDefinitionRecord`: Fields - id: Uuid, cred_def_id: String, schema_id: String, tag: String, issuer_did: String, support_revocation: bool, created_at: DateTime<Utc>
  - `User`: Fields - id: Uuid, username: String, password_hash: String, display_name: String, roles: Vec<String>, status: String, last_login: Option<DateTime<Utc>>, created_at: DateTime<Utc>, updated_at: DateTime<Utc>
- **Implementation:** QuantumZero-server/services/admin-api/src/models.rs
- **Database:** PostgreSQL with SQLx ORM

#### 2.2.2 Server API Handlers
- **File:** [class-server-handlers.mmd](diagrams/class-server-handlers.mmd)
- **Priority:** A
- **Purpose:** Defines server-side HTTP request handlers for the Admin API
- **Language:** Rust (Actix-Web framework)
- **Handler Groups:**
  - **Issuer Handlers:** list_issuers(), create_issuer(), get_issuer(), update_issuer_status()
  - **Schema Handlers:** list_schemas(), create_schema(), get_schema(), import_schema_from_ledger()
  - **CredDef Handlers:** list_cred_defs(), create_cred_def(), get_cred_def()
  - **Auth Handlers:** login(), logout(), verify_session()
  - **System Handlers:** health_check(), get_metrics(), get_stats(), sync_from_ledger()
- **Implementation:** QuantumZero-server/services/admin-api/src/handlers.rs

---

## 3. Component Diagrams

Component diagrams show the organization and dependencies among software components.

### 3.1 Complete System Architecture
- **File:** [component-system-complete.mmd](diagrams/component-system-complete.mmd)
- **Priority:** A
- **Purpose:** Master component diagram showing all major components and their interactions
- **Scope:** Complete QuantumZero system (Mobile + Server)
- **Mobile Components:**
  - **Presentation Layer:** Screens (Flutter Widgets)
  - **State Management:** Providers (Riverpod)
  - **Business Logic:** DidRepository, CredentialRepository, PresentationRepository
  - **Core Services:** BiometricService, CryptoService, SecureStorageService (interfaces)
  - **Domain Models:** Did, Credential, VerifiablePresentation
  - **Platform Services:** iOS (Keychain, Secure Enclave), Android (Keystore, StrongBox)
- **Server Components:**
  - **Microservices:** Admin API (8080), Issuance API (8082), Verification API (8083), Revocation API (8084)
  - **Shared Libraries:** Common (Models, Utils)
- **Data Layer:** Local SQLite (encrypted VC storage), PostgreSQL (server persistence)
- **Related Diagrams:**
  - component-mobile-layers.mmd (detailed mobile layers)
  - component-server-microservices.mmd (detailed server services)

### 3.2 Mobile Application Layers
- **File:** [component-mobile-layers.mmd](diagrams/component-mobile-layers.mmd)
- **Priority:** A
- **Purpose:** Shows the layered architecture of the mobile application
- **Layers (top to bottom):**
  1. UI Layer: Screens (Flutter Widgets), App Theme (Material Design)
  2. State Management: Riverpod Providers
  3. Business Logic: Repositories
  4. Core Services: Biometric, Crypto, Storage
  5. Data Models: Domain entities
  6. Platform Services: iOS Keychain/Secure Enclave, Android Keystore/StrongBox

### 3.3 Mobile Services Detail
- **File:** [component-mobile-services.mmd](diagrams/component-mobile-services.mmd)
- **Priority:** A
- **Purpose:** Detailed view of mobile service components and their implementations
- **Services:** BiometricService, CryptoService, SecureStorageService
- **Platform Bindings:** iOS and Android implementations

### 3.4 Server Microservices Overview
- **File:** [component-server-overview.mmd](diagrams/component-server-overview.mmd)
- **Priority:** A
- **Purpose:** Shows server-side microservices architecture
- **Services:**
  - Admin API (Actix-Web, Port 8080)
  - Issuance API (Actix-Web, Port 8082)
  - Verification API (Actix-Web, Port 8083)
  - Revocation API (Actix-Web, Port 8084)
  - Web Frontend (Static Files, Port 8081)
- **Shared Libraries:** Common (Models, Utils)
- **Data Layer:** PostgreSQL
- **External Clients:** Mobile Application, Admin Dashboard

### 3.5 Server Microservices Detail
- **File:** [component-server-microservices.mmd](diagrams/component-server-microservices.mmd)
- **Priority:** A
- **Purpose:** Detailed internal structure of each microservice
- **Components per Service:** Handlers, Models, State, Routes

---

## 4. Deployment Diagrams

Deployment diagrams show the physical deployment of artifacts on nodes and the network topology.

### 4.1 Complete System Infrastructure
- **File:** [deployment-system-complete.mmd](diagrams/deployment-system-complete.mmd)
- **Priority:** A
- **Purpose:** Master deployment diagram showing complete infrastructure
- **Scope:** Mobile devices + Server infrastructure
- **Mobile Devices:**
  - **iOS Device:** QuantumZero.ipa artifact, iOS Runtime environment, Keychain Services, Secure Enclave, FaceID/TouchID, Local SQLite
  - **Android Device:** QuantumZero.apk artifact, Android Runtime environment, Android Keystore, StrongBox, BiometricPrompt, Local SQLite
- **Server Node:**
  - **Docker Host:** admin-api:latest, issuance-api:latest, verification-api:latest, revocation-api:latest, web-frontend:latest containers
  - **Database:** PostgreSQL 15 container
- **Communication:** HTTPS/REST with TLS 1.3 between mobile and server, SQLx connection pools to database
- **Related Diagrams:** deployment-server-infrastructure.mmd

### 4.2 Server Infrastructure (Detailed)
- **File:** [deployment-server-infrastructure.mmd](diagrams/deployment-server-infrastructure.mmd)
- **Priority:** A
- **Purpose:** Detailed server deployment architecture
- **Environment:** Development/Production
- **Artifacts:** Docker containers for each microservice
- **Database:** PostgreSQL 15 with SQLx ORM
- **Ports:** 8080 (Admin API), 8081 (Web Frontend), 8082 (Issuance API), 8083 (Verification API), 8084 (Revocation API), 5432 (PostgreSQL)

---

## 5. Architecture Diagrams

High-level architecture diagrams showing system overview and design principles.

### 5.1 Server System Overview
- **File:** [architecture-server-system-overview.mmd](diagrams/architecture-server-system-overview.mmd)
- **Priority:** B (Supplementary high-level view)
- **Purpose:** High-level view of server system architecture
- **Note:** This is a supplementary diagram. For detailed UML views, see:
  - component-server-overview.mmd
  - deployment-server-infrastructure.mmd

### 5.2 Trusted Ledger Architecture
- **File:** [architecture-server-trusted-ledger.mmd](diagrams/architecture-server-trusted-ledger.mmd)
- **Priority:** B (Supplementary)
- **Purpose:** Shows trust registry and ledger simulation architecture

---

## 6. Sequence Diagrams

Sequence diagrams show interactions between objects in a time sequence. All sequence diagrams follow UML notation with proper lifelines, activation boxes, and message types.

### 6.1 Mobile Application Sequences

#### Identity Management
- **sequence-mobile-did-generation.mmd** - DID creation and registration
- **sequence-mobile-android-key-generation.mmd** - Android-specific key generation using Keystore
- **sequence-mobile-ios-key-generation.mmd** - iOS-specific key generation using Secure Enclave
- **sequence-mobile-non-exportable-keys.mmd** - Hardware-bound key generation

#### Authentication & Security
- **sequence-mobile-biometric-authentication.mmd** - Biometric authentication flow
- **sequence-mobile-crypto-validation.mmd** - Cryptographic validation process
- **sequence-mobile-local-storage-setup.mmd** - Secure storage initialization

#### Credential Management
- **sequence-mobile-vc-workflow.mmd** - Complete verifiable credential workflow
- **sequence-mobile-vc-storage.mmd** - Credential storage and retrieval
- **sequence-mobile-vc-signature-verification.mmd** - Credential signature validation
- **sequence-mobile-revocation-check.mmd** - Credential revocation status check

#### Presentation & Proofs
- **sequence-mobile-vp-creation.mmd** - Verifiable presentation creation
- **sequence-mobile-vp-presentation.mmd** - VP presentation to verifier
- **sequence-mobile-proof-generation.mmd** - Zero-knowledge proof generation
- **sequence-mobile-selective-disclosure.mmd** - Selective attribute disclosure
- **sequence-mobile-attribute-minimization.mmd** - Minimal attribute exposure
- **sequence-mobile-zkp-circuits.mmd** - ZKP circuit generation
- **sequence-mobile-zkp-failure-handling.mmd** - ZKP error handling

#### Verification
- **sequence-mobile-offline-verification.mmd** - Offline credential verification
- **sequence-mobile-online-sync.mmd** - Online synchronization
- **sequence-mobile-replay-protection.mmd** - Replay attack prevention

### 6.2 Server Application Sequences

#### Credential Issuance
- **sequence-server-credential-issuance-api.mmd** - Credential issuance API flow
- **sequence-server-credential-signing.mmd** - Credential signing process
- **sequence-server-credential-schema-validation.mmd** - Schema validation

#### Verification
- **sequence-server-proof-verification.mmd** - Proof verification process

#### Infrastructure
- **sequence-server-issuer-key-management.mmd** - Issuer key lifecycle management

#### Research & Evaluation
- **sequence-server-sdk-evaluation.mmd** - SDK evaluation process
- **sequence-server-zksnark-comparison.mmd** - ZK-SNARK library comparison

---

## 7. Other Diagrams

### 7.1 Entity Relationship Diagrams

#### Trust Registry Database
- **File:** [erdiagram-server-trust-registry-db.mmd](diagrams/erdiagram-server-trust-registry-db.mmd)
- **Priority:** A
- **Purpose:** Database schema for trust registry
- **Tables:** Issuers, Schemas, CredentialDefinitions, Users

### 7.2 Flowchart Diagrams

#### Hash Chain Ledger
- **File:** [flowchart-server-hash-chain-ledger.mmd](diagrams/flowchart-server-hash-chain-ledger.mmd)
- **Priority:** B
- **Purpose:** Shows hash chain ledger implementation logic

#### Issuer Registry
- **File:** [flowchart-server-issuer-registry.mmd](diagrams/flowchart-server-issuer-registry.mmd)
- **Priority:** B
- **Purpose:** Shows issuer registration and management flow

---

## 8. Diagram Standards and Conventions

### 8.1 UML Notation Standards

All diagrams strictly adhere to UML 2.5 standards as defined by OMG:

1. **Use Case Diagrams**
   - Actors shown as stick figures
   - Use cases as ellipses
   - System boundary as rectangle
   - Associations as lines
   - Include/extend relationships as dashed arrows with stereotypes

2. **Class Diagrams**
   - Classes as rectangles with three compartments (name, attributes, methods)
   - Visibility: + (public), - (private), # (protected), ~ (package)
   - Relationships: association (line), aggregation (hollow diamond), composition (filled diamond), inheritance (hollow arrow), dependency (dashed arrow)
   - Stereotypes: «interface», «enumeration», «abstract»

3. **Component Diagrams**
   - Components as rectangles with «component» stereotype
   - Interfaces as circles or lollipops
   - Dependencies as dashed arrows
   - Nested components shown within boundaries

4. **Deployment Diagrams**
   - Nodes as 3D boxes with «device» stereotype
   - Artifacts with «artifact» stereotype
   - Execution environments with «execution environment» stereotype
   - Communication paths as lines with protocols

5. **Sequence Diagrams**
   - Lifelines as boxes with dashed vertical lines
   - Messages as horizontal arrows
   - Activation boxes for processing
   - Return messages as dashed arrows

### 8.2 Naming Conventions

- **Dart (Mobile):** camelCase for methods and attributes, PascalCase for classes
- **Rust (Server):** snake_case for functions and variables, PascalCase for types
- **Database:** snake_case for table and column names

### 8.3 Color Coding

Consistent color scheme across all diagrams:
- **Actors:** Orange (#fff3e0 fill, #e65100 stroke)
- **Use Cases:** Light Blue (#e1f5fe fill, #01579b stroke)
- **Mobile Components:** Blue (#e3f2fd fill, #1976d2 stroke)
- **Server Components:** Green (#e8f5e9 fill, #2e7d32 stroke)
- **Database:** Teal (#e0f2f1 fill, #00695c stroke)
- **Platform Services:** Amber (#fff3e0 fill, #e65100 stroke)
- **Interfaces:** Purple (#f3e5f5 fill, #7b1fa2 stroke)
- **Notes:** Yellow (#fff9c4 fill, #f57f17 stroke)

### 8.4 Diagram Relationships

Each diagram includes header comments identifying:
- Purpose and scope
- Priority level (A/B/C)
- Related diagrams (cross-references)
- Requirements mapping
- Actual implementation location

---

## 9. Requirements Traceability

### Security Requirements
- **F-SEC-01 (Biometric Authentication):**
  - usecase-mobile-app-unlock.mmd
  - usecase-mobile-external-authentication.mmd
  - class-mobile-services.mmd (BiometricService)
  - sequence-mobile-biometric-authentication.mmd

- **F-SEC-02 (Hardware-backed Cryptography):**
  - class-mobile-services.mmd (CryptoService)
  - deployment-system-complete.mmd (Secure Enclave, Keystore, StrongBox)
  - sequence-mobile-android-key-generation.mmd
  - sequence-mobile-ios-key-generation.mmd

- **F-SEC-03 (Selective Disclosure):**
  - usecase-mobile-external-authentication.mmd
  - usecase-mobile-prove-fact.mmd
  - sequence-mobile-selective-disclosure.mmd
  - sequence-mobile-attribute-minimization.mmd

- **F-SEC-04 (Zero-Knowledge Proofs):**
  - usecase-mobile-external-authentication.mmd
  - usecase-mobile-prove-fact.mmd
  - sequence-mobile-proof-generation.mmd
  - sequence-mobile-zkp-circuits.mmd

---

## 10. Summary

This documentation fulfills all requirements for Deliverable #1:

### ✓ Required UML Diagrams (Completed)
1. **Use Case Diagrams:** 3 diagrams covering user authentication and proving facts
2. **Class Diagrams:** 5 diagrams covering mobile and server models, repositories, services, and handlers
3. **Component Diagrams:** 5 diagrams showing system architecture and layers
4. **Deployment Diagrams:** 2 diagrams showing complete infrastructure

### ✓ Optional UML Diagrams (Completed)
- **Sequence Diagrams:** 26 diagrams covering complete interaction flows
- **Entity Relationship Diagram:** 1 diagram for database schema

### ✓ Standards Compliance
- All diagrams follow UML 2.5 notation
- Proper stereotypes and relationship types
- Consistent naming conventions
- Cross-referenced to avoid duplication

### ✓ Deliverable Requirements Met
- Priority levels specified (A/B/C)
- Preconditions, postconditions, and triggers documented
- Actors clearly described
- Data flow narratives included in headers
- Professional presentation with consistent styling

### Total Diagrams: 47+
- **Use Case:** 3
- **Class:** 5
- **Component:** 5
- **Deployment:** 2
- **Sequence:** 26
- **Architecture:** 2
- **ER Diagram:** 1
- **Flowchart:** 2
- **Additional:** 1+

All diagrams are version-controlled in the `QuantumZero/diagrams/` directory and are ready for review and presentation.

---

## Document Control

**Version History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-09 | System | Initial creation - Complete diagram index |

**References:**
- [687-Deliverable-1.md](687-Deliverable-1.md) - Project requirements
- [UML 2.5 Specification](https://www.uml-diagrams.org/)
- [W3C DID Core](https://www.w3.org/TR/did-core/)
- [W3C Verifiable Credentials](https://www.w3.org/TR/vc-data-model/)
