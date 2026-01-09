# Zero-Trust Security Model & Assumptions

**Version:** 1.0  
**Related Issue:** [#22](https://github.com/CHATEAUFORGE-LLC/QuantumZero/issues/22)   
**Last Updated:** 12.28.25  

## 1. Executive Summary
This document defines the operational enforcement of the **Zero Trust** security model within the QuantumZero infrastructure. Unlike traditional perimeter-based security, QuantumZero operates on the principle that **no entity—user, device, or service—is trusted by default**. Trust is established solely through continuous cryptographic verification, hardware-backed identity, and strict data minimization.



## 2. Core Zero-Trust Principles

### A. "Never Trust, Always Verify"
**Definition:** No request is trusted based on network location or session token alone. Every interaction must be explicitly authenticated and authorized using cryptographic proofs.

* **Enforcement Point:** API Gateway & Backend Verification Service.
* **Detailed Mechanisms:**
    1.  **Cryptographic Signature Verification:** Every request to the backend must be signed by the user's DID. The backend validates these signatures against W3C-compliant public keys before processing any transaction.
    2.  **Real-Time Revocation Checks:** Verification is dynamic. For every presentation, the system queries the **Trust Registry** to validate the current status of the credential. Revoked credentials are rejected immediately, even if their cryptographic signature is valid.
    3.  **Strict Authorization:** The platform enforces a "deny-by-default" policy. Only requests accompanied by a valid, non-revoked DID signature are processed.
* **Traceability:** Meets Requirement `[NF-SEC-03]` and `[F-SEC-04]`.

### B. Least Privilege (Data Minimization)
**Definition:** Users and systems should only have access to the specific data needed for the task at hand, and absolutely nothing more.

* **Enforcement Point:** Zero-Knowledge Proof (ZKP) Generator (Mobile Device).
* **Detailed Mechanisms:**
    1.  **Selective Disclosure via Circuits:** We utilize the **Mopro toolkit** and **Noir DSL** to define ZKP circuits. These circuits allow the mobile device to generate a proof for a specific claim (e.g., *"Age >= 18"*) without ever including the underlying PII (e.g., *"Date of Birth: 01/01/1990"*) in the payload.
    2.  **Backend Blindness:** The Verification Service (running **Gnark**) receives only the mathematical proof, never the raw data. This ensures the backend technically *cannot* see user data, enforcing privacy by architecture rather than policy.
    3.  **Storage Minimization:** The backend database schema is designed to reject raw PII. It stores only cryptographic hashes and DID documents, ensuring compliance with GDPR data minimization principles.
* **Traceability:** Meets Requirement `[F-SEC-05]` and `[NF-SEC-06]`.

### C. Device-Level Trust Anchoring
**Definition:** Identity must be bound to specific, tamper-resistant hardware to prevent credential cloning, export, or theft.

* **Enforcement Point:** Secure Enclave (iOS) / Keystore (Android).
* **Detailed Mechanisms:**
    1.  **Hardware Isolation:** Private keys are generated directly inside the **iOS Secure Enclave** (via CryptoKit) or **Android Keystore** (via Jetpack Security). These keys are flagged as `non-exportable` at the hardware level, meaning they can never be extracted to application memory or backup files.
    2.  **Biometric Binding:** Access to these hardware keys is gated by the device's native biometric authentication (FaceID/Fingerprint). A successful biometric challenge is required to authorize the signing operation inside the enclave/keystore.
* **Traceability:** Meets Requirement `[NF-SEC-01]` and `[F-SEC-01]`.

### D. Secure Transport (Assume Breach)
**Definition:** We assume the network layer is hostile and actively monitored. All data in transit must be encrypted and pinned.

* **Enforcement Point:** Network / Transport Layer.
* **Detailed Mechanisms:**
    1.  **TLS 1.3 Enforcement:** All communications between the mobile app, API gateway, and backend services are pinned to **TLS 1.3** protocols. Older, vulnerable cipher suites are disabled to prevent downgrade attacks.
    2.  **Replay Protection:** All verification requests include a unique nonce or timestamp. The backend rejects any request with a reused nonce to prevent replay attacks, ensuring that intercepted traffic cannot be re-transmitted to spoof identity.
* **Traceability:** Meets Requirement `[NF-SEC-02]` and `[F-SEC-06]`.



## 3. Security Assumptions Log
The following table explicitly defines the assumptions inherent in our threat model. If these assumptions are violated, the security guarantees of the system may be compromised.

| ID | Assumption | Description & Implication |
| :--- | :--- | :--- |
| **A-01** | **OS Integrity** | **We assume the user's device is not "rooted" or "jailbroken."** <br> *Implication:* If the OS kernel is compromised, the isolation of the Hardware Security Module (Secure Enclave/Android Keystore) could theoretically be bypassed by a sophisticated attacker. We rely on the OS vendor's guarantees that the Enclave is tamper-resistant. |
| **A-02** | **Fail-Safe Offline** | **We assume the mobile app fails safe if the Trust Registry is unreachable.** <br> *Implication:* If the mobile device cannot reach the Trust Registry to check for revocation, it relies on a cached local copy. If this cache is stale, the verification defaults to failure rather than potentially accepting a revoked credential ("Fail-Safe" vs. "Fail-Open"). |
| **A-03** | **No Recovery Backdoor** | **We assume the user is solely responsible for their recovery phrase.** <br> *Implication:* Since keys are non-exportable and we store no server-side backups, losing the device *and* the recovery phrase results in permanent loss of identity. There is no "Admin Reset" capability for the QuantumZero team. |
| **A-04** | **Biometric Integrity** | **We assume the device biometric sensors have not been physically bypassed.** <br> *Implication:* We rely on the hardware assurances of TouchID/FaceID. If an attacker can spoof biometrics at the hardware level, they can authorize key usage. |