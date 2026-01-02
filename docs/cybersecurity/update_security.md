# Update Security

## Purpose

This document defines security requirements and procedures for software and firmware updates in robotics systems built with MPF. Secure updates are critical to prevent the introduction of malware and maintain system integrity.

## Update Threat Model

### Threats

1. **Malicious Update**: Attacker distributes compromised update package
2. **Man-in-the-Middle**: Attacker intercepts and modifies update in transit
3. **Downgrade Attack**: Attacker forces installation of older, vulnerable version
4. **Update Server Compromise**: Attacker gains control of update distribution server
5. **Supply Chain Attack**: Compromised build pipeline produces malicious updates

### Security Objectives

- **Authenticity**: Verify update is from legitimate source
- **Integrity**: Ensure update has not been modified
- **Freshness**: Prevent replay of old updates
- **Authorized**: Only authorized personnel can initiate updates
- **Atomic**: Update succeeds completely or rolls back
- **Recoverable**: System can recover from failed update

## Secure Update Architecture

### Components

```
┌─────────────────┐
│  Build Server   │ ←── Produces signed update packages
└────────┬────────┘
         │ (signed)
         ↓
┌─────────────────┐
│ Update Server   │ ←── Distributes updates securely
└────────┬────────┘
         │ (HTTPS)
         ↓
┌─────────────────┐
│ Robot System    │ ←── Verifies and installs updates
│  - Verification │
│  - Installation │
│  - Rollback     │
└─────────────────┘
```

## Digital Signatures

### Signing Process

**Build Phase:**

```bash
#!/bin/bash
# Build and sign update package

# Build the update package
./build-update.sh > update.pkg

# Sign with private key (offline, in secure environment)
openssl dgst -sha256 -sign private_key.pem \
    -out update.pkg.sig update.pkg

# Create metadata
cat > update.json <<EOF
{
  "version": "2.1.0",
  "timestamp": "$(date -Iseconds)",
  "package": "update.pkg",
  "signature": "update.pkg.sig",
  "hash": "$(sha256sum update.pkg | cut -d' ' -f1)"
}
EOF
```

**Verification Phase:**

```rust
use ring::signature::{self, UnparsedPublicKey, RSA_PKCS1_2048_8192_SHA256};
use std::fs;

struct UpdatePackage {
    version: Version,
    timestamp: SystemTime,
    data: Vec<u8>,
    signature: Vec<u8>,
}

impl UpdatePackage {
    fn verify(&self, public_key: &[u8]) -> Result<(), UpdateError> {
        // Verify signature
        let key = UnparsedPublicKey::new(
            &RSA_PKCS1_2048_8192_SHA256,
            public_key
        );
        
        key.verify(&self.data, &self.signature)
            .map_err(|_| UpdateError::InvalidSignature)?;
        
        // Verify hash
        let expected_hash = self.compute_hash();
        let actual_hash = compute_hash(&self.data);
        if expected_hash != actual_hash {
            return Err(UpdateError::HashMismatch);
        }
        
        // Verify freshness (timestamp within acceptable window)
        let age = SystemTime::now()
            .duration_since(self.timestamp)
            .map_err(|_| UpdateError::InvalidTimestamp)?;
        
        if age > Duration::from_days(30) {
            return Err(UpdateError::UpdateTooOld);
        }
        
        Ok(())
    }
}
```

### Key Management

**Private Key:**
- **Storage**: Hardware Security Module (HSM) or secure offline storage
- **Access**: Restricted to authorized release managers
- **Usage**: Only for signing official releases
- **Backup**: Encrypted backup in secure location
- **Rotation**: Annual or on compromise

**Public Key:**
- **Storage**: Embedded in firmware/software
- **Multiple Keys**: Support key rotation (store current + next key)
- **Revocation**: Mechanism to revoke compromised keys

```rust
struct TrustedKeys {
    current: PublicKey,
    next: Option<PublicKey>,
    revoked: Vec<KeyId>,
}

impl TrustedKeys {
    fn verify_signature(&self, data: &[u8], sig: &Signature) 
        -> Result<(), Error> {
        // Check if key is revoked
        if self.revoked.contains(&sig.key_id) {
            return Err(Error::RevokedKey);
        }
        
        // Try current key
        if let Ok(()) = self.current.verify(data, sig) {
            return Ok(());
        }
        
        // Try next key (for key rotation)
        if let Some(next) = &self.next {
            if let Ok(()) = next.verify(data, sig) {
                return Ok(());
            }
        }
        
        Err(Error::InvalidSignature)
    }
}
```

## Secure Transport

### HTTPS Requirements

**TLS Configuration:**
- TLS 1.3 (preferred) or TLS 1.2 minimum
- Certificate pinning for update server
- Strong cipher suites only
- Certificate validation enabled

```rust
use reqwest::{Client, Certificate};
use std::fs::File;
use std::io::Read;

fn create_update_client() -> Result<Client, Error> {
    // Load pinned certificate
    let mut buf = Vec::new();
    File::open("update_server_cert.pem")?.read_to_end(&mut buf)?;
    let cert = Certificate::from_pem(&buf)?;
    
    // Create client with pinned certificate
    let client = Client::builder()
        .use_rustls_tls()
        .add_root_certificate(cert)
        .https_only(true)
        .build()?;
    
    Ok(client)
}

async fn download_update(client: &Client, url: &str) 
    -> Result<UpdatePackage, Error> {
    let response = client.get(url)
        .send()
        .await?;
    
    if !response.status().is_success() {
        return Err(Error::DownloadFailed);
    }
    
    let data = response.bytes().await?;
    Ok(parse_update_package(&data)?)
}
```

### Integrity Checks

**Multiple Hashing:**

```rust
struct PackageIntegrity {
    sha256: [u8; 32],
    blake2b: [u8; 64],
    size: u64,
}

impl PackageIntegrity {
    fn verify(&self, data: &[u8]) -> Result<(), Error> {
        // Verify size
        if data.len() as u64 != self.size {
            return Err(Error::SizeMismatch);
        }
        
        // Verify SHA-256
        let sha256 = compute_sha256(data);
        if sha256 != self.sha256 {
            return Err(Error::Sha256Mismatch);
        }
        
        // Verify BLAKE2b
        let blake2 = compute_blake2b(data);
        if blake2 != self.blake2b {
            return Err(Error::Blake2Mismatch);
        }
        
        Ok(())
    }
}
```

## Version Management

### Semantic Versioning

Use semantic versioning (SemVer): MAJOR.MINOR.PATCH

- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality additions
- **PATCH**: Backwards-compatible bug fixes

### Version Verification

```rust
struct VersionCheck {
    current: Version,
    minimum_allowed: Version,
}

impl VersionCheck {
    fn can_update_to(&self, new: &Version) -> Result<(), UpdateError> {
        // Prevent downgrade
        if new < &self.current {
            return Err(UpdateError::DowngradeNotAllowed);
        }
        
        // Check minimum version requirement
        if new < &self.minimum_allowed {
            return Err(UpdateError::VersionTooOld);
        }
        
        // Check for reasonable version jump
        if new.major > self.current.major + 1 {
            return Err(UpdateError::VersionJumpTooLarge);
        }
        
        Ok(())
    }
}
```

### Update Metadata

```json
{
  "version": "2.1.0",
  "release_date": "2024-01-15T10:30:00Z",
  "signature_timestamp": "2024-01-15T10:35:00Z",
  "minimum_version": "2.0.0",
  "changelog": "Bug fixes and security updates",
  "security_fixes": ["CVE-2024-1234", "CVE-2024-5678"],
  "dependencies": {
    "module-domain": "1.5.0",
    "module-infrastructure": "1.8.2"
  },
  "hash": {
    "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "blake2b": "..."
  },
  "size": 52428800,
  "signature": "...",
  "signing_key_id": "key-2024-01"
}
```

## Installation Process

### Pre-Installation Checks

```rust
struct UpdateInstaller {
    package: UpdatePackage,
}

impl UpdateInstaller {
    fn pre_install_checks(&self) -> Result<(), UpdateError> {
        // 1. Verify signature and integrity
        self.package.verify(&trusted_public_key())?;
        
        // 2. Check version compatibility
        version_check()?;
        
        // 3. Verify sufficient storage space
        let required_space = self.package.size + ROLLBACK_SPACE;
        if available_space() < required_space {
            return Err(UpdateError::InsufficientSpace);
        }
        
        // 4. Check battery level (for mobile robots)
        if battery_level() < 50.0 {
            return Err(UpdateError::InsufficientBattery);
        }
        
        // 5. Verify no critical operations in progress
        if is_mission_active() {
            return Err(UpdateError::SystemBusy);
        }
        
        // 6. Create backup/snapshot
        create_backup()?;
        
        Ok(())
    }
}
```

### Atomic Installation

**A/B System Updates:**

```
┌─────────────┐     ┌─────────────┐
│  Partition A │     │ Partition B  │
│  (Active)    │     │  (Inactive)  │
│  v2.0.0      │     │              │
└─────────────┘     └─────────────┘
        │                    ↑
        │        Install v2.1.0
        │                    │
        ↓                    │
┌─────────────┐     ┌─────────────┐
│  Partition A │     │ Partition B  │
│  (Fallback)  │     │  (Active)    │
│  v2.0.0      │     │  v2.1.0      │
└─────────────┘     └─────────────┘
```

```rust
enum Partition {
    A,
    B,
}

struct SystemUpdater {
    active: Partition,
    inactive: Partition,
}

impl SystemUpdater {
    fn install_update(&mut self, package: UpdatePackage) 
        -> Result<(), UpdateError> {
        // Write to inactive partition
        self.write_to_partition(&self.inactive, &package)?;
        
        // Verify installation
        self.verify_partition(&self.inactive)?;
        
        // Switch boot partition
        self.set_boot_partition(&self.inactive)?;
        
        // Mark for first-boot validation
        self.mark_pending_validation()?;
        
        // Reboot
        self.trigger_reboot()?;
        
        Ok(())
    }
    
    fn post_boot_validation(&mut self) -> Result<(), UpdateError> {
        // Run validation tests
        if self.validate_system() {
            // Success - commit the update
            self.commit_boot_partition()?;
            self.clear_fallback()?;
        } else {
            // Failed - rollback to previous version
            self.rollback()?;
        }
        
        Ok(())
    }
}
```

### Rollback Mechanism

```rust
struct RollbackManager {
    backup: BackupImage,
}

impl RollbackManager {
    fn rollback(&self) -> Result<(), RollbackError> {
        // 1. Stop all services
        stop_all_services()?;
        
        // 2. Restore backup
        self.backup.restore()?;
        
        // 3. Verify restoration
        verify_system_integrity()?;
        
        // 4. Reboot
        trigger_reboot()?;
        
        Ok(())
    }
    
    fn can_rollback(&self) -> bool {
        self.backup.is_valid() && self.backup.age() < Duration::from_days(7)
    }
}
```

## Update Authorization

### Authentication and Authorization

```rust
struct UpdateAuthorization {
    initiated_by: UserId,
    approved_by: Option<UserId>,
    authorization_level: AuthLevel,
}

enum AuthLevel {
    PatchUpdate,        // Any authorized user
    MinorUpdate,        // Requires technician role
    MajorUpdate,        // Requires engineer role
    SafetyCritical,     // Requires dual authorization
}

impl UpdateAuthorization {
    fn authorize_update(&mut self, update: &UpdatePackage) 
        -> Result<(), AuthError> {
        let required_level = update.required_auth_level();
        
        match required_level {
            AuthLevel::SafetyCritical => {
                // Requires two authorized users
                if self.approved_by.is_none() {
                    return Err(AuthError::DualAuthRequired);
                }
            }
            _ => {
                // Check initiator has required role
                if !self.initiated_by.has_auth_level(&required_level) {
                    return Err(AuthError::InsufficientPrivilege);
                }
            }
        }
        
        Ok(())
    }
}
```

## Update Logging and Audit

### Audit Trail

```rust
struct UpdateAuditLog {
    timestamp: SystemTime,
    update_id: String,
    version_from: Version,
    version_to: Version,
    initiated_by: UserId,
    approved_by: Option<UserId>,
    result: UpdateResult,
    verification_checks: Vec<VerificationCheck>,
    duration: Duration,
}

enum UpdateResult {
    Success,
    Failed(String),
    RolledBack(String),
}

impl UpdateAuditLog {
    fn log(&self) {
        // Log to secure audit log
        secure_audit_log::write(self);
        
        // Alert on failures
        if matches!(self.result, UpdateResult::Failed(_) | UpdateResult::RolledBack(_)) {
            alert_security_team(self);
        }
    }
}
```

## Emergency Updates

### Fast-Track Process

For critical security vulnerabilities:

1. **Expedited Approval**: Reduced approval time
2. **Automated Testing**: Parallel to deployment
3. **Phased Rollout**: Deploy to subset first
4. **Monitoring**: Enhanced monitoring post-update
5. **Rollback Ready**: Immediate rollback capability

```rust
struct EmergencyUpdate {
    cve_ids: Vec<String>,
    severity: Severity,
    fast_track_approved_by: UserId,
}

enum Severity {
    Critical,  // Immediate deployment
    High,      // Within 24 hours
    Medium,    // Within 1 week
    Low,       // Next regular update cycle
}
```

## Update Testing

### Pre-Release Testing

1. **Unit Tests**: All tests pass
2. **Integration Tests**: Module integration verified
3. **System Tests**: Full system test
4. **Hardware-in-the-Loop**: Test on target hardware
5. **Regression Tests**: No existing functionality broken
6. **Security Tests**: Vulnerability scan, penetration test

### Post-Update Validation

```rust
struct PostUpdateValidator {
    checks: Vec<ValidationCheck>,
}

impl PostUpdateValidator {
    fn validate(&self) -> Result<(), ValidationError> {
        for check in &self.checks {
            check.run()?;
        }
        Ok(())
    }
}

trait ValidationCheck {
    fn run(&self) -> Result<(), ValidationError>;
}

struct SafetySystemCheck;
impl ValidationCheck for SafetySystemCheck {
    fn run(&self) -> Result<(), ValidationError> {
        // Verify emergency stop works
        // Verify watchdog works
        // Verify safety interlocks work
        Ok(())
    }
}
```

## Update Channels

### Channel Types

- **Stable**: Thoroughly tested, recommended for production
- **Beta**: Feature-complete, undergoing final testing
- **Development**: Latest features, may be unstable

### Channel Selection

```rust
enum UpdateChannel {
    Stable,
    Beta,
    Development,
}

impl UpdateChannel {
    fn allowed_in_production(&self) -> bool {
        matches!(self, UpdateChannel::Stable)
    }
}
```

## References

- [Threat Model](./threat_model.md)
- [Access Control](./access_control.md)
- [Secure Communication](./secure_communication.md)
- NIST SP 800-147: BIOS Protection Guidelines
- IEC 62443-4-2: Technical security requirements for IACS components

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Security Team | Initial update security policy |
