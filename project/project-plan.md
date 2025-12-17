## Milestone M1 - Analysis & Design Complete
```
Epic: Requirements Finalization
- Finalize functional requirements (FR table validation)
- Finalize nonfunctional requirements (NFR table validation)
- Confirm Zero-Trust enforcement assumptions
- Lock acceptance criteria per feature

Epic: System Architecture Design
- High-level system architecture diagram
- DID lifecycle and VC flow diagrams
- Trust registry / ledger simulation design
- Mobile wallet architecture definition

Epic: Governance & Planning
- Confirm client agreement alignment (1.4)
- Align Appendix F SOW with project execution
- Validate GitHub project structure
```

## Milestone M2 - Core Identity & Wallet Foundations
```
Epic: Mobile Wallet Core
- Implement DID generation workflow
- Implement VC storage model
- Implement VP creation logic
- Local-first data storage setup

Epic: Secure Key Management
- iOS Secure Enclave key generation
- Android Keystore key generation
- Non-exportable key enforcement
- Biometric / device authentication binding

Epic: Developer Enablement
- SDK evaluation (Aries / DIDKit / Spruce)
- Crypto library validation
```

## Milestone M3 - Issuance, Verification & Trust Registry
```
Epic: Backend Issuance Services
- Credential issuance API
- Credential schema validation
- Issuer key management
- Credential signing logic

Epic: Verification Services
- VC signature verification
- Revocation status checks
- Replay protection (nonce/timestamp)

Epic: Trust Registry / Ledger Simulation
- Issuer registry design
- Hash-chain or lightweight ledger implementation
- Local cache for offline verification
```

## Milestone M4 - Zero-Knowledge Proofs & Selective Disclosure
```
Epic: ZKP Framework Integration
- Evaluate zkSNARK / Noir / Gnark tooling
- Define ZKP circuits for claims
- Proof generation on mobile
- Proof verification on backend

Epic: Privacy Controls
- Selective disclosure rules
- Attribute minimization enforcement
- ZKP failure handling
```

## Milestone M5 - Integration, Testing & Hardening
```
Epic: Integration Testing
- Mobile ↔ Backend end-to-end flows
- Issuance → Storage → Presentation → Verification
- Offline QR-based verification

Epic: Security Validation
- Threat modeling review
- Zero-Trust enforcement checks
- TLS and certificate pinning validation

Epic: Defect Resolution
- Bug triage and prioritization
- Stability fixes
- Performance tuning
```

## Milestone M6 - Documentation, Final Review & Submission
```
Epic: Documentation
- User Manual (Appendix A)
- Maintenance Manual (Appendix B)
- System architecture documentation
- Test suite documentation

Epic: Final Report
- Section reviews and consistency checks
- APA formatting validation
- Table/Figure verification

Epic: Final Demonstration
- End-to-end system walkthrough
- Acceptance criteria confirmation
- Final submission packaging
```

## Recommended GitHub Labels
```
type:analysis
type:design
type:implementation
type:testing
type:documentation
type:security
type:research

priority:high
priority:medium
priority:low

risk:technical
risk:schedule
risk:integration
```

## Issue Template (Optional but Highly Recommended)
```
### Description
Brief description of the task or issue.

### Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2

### Dependencies
- Related issues or prerequisites

### Owner
Primary / Secondary

### Notes
Additional context or risks
```