# Secure Communication

## Purpose

This document defines requirements and best practices for secure communication in robotics systems built with MPF. Secure communication is essential to prevent eavesdropping, tampering, and unauthorized access.

## Communication Channels

### 1. Inter-Process Communication (IPC)

#### ROS Topics and Services

**Security Requirements:**
- Authentica with ROS 2 Security (SROS2)
- Encryption of sensitive data
- Access control per topic/service

**Implementation:**

```bash
# Enable ROS 2 Security
export ROS_SECURITY_ENABLE=true
export ROS_SECURITY_STRATEGY=Enforce
```

**Configuration:**
- Use DDS security plugins
- Certificate-based authentication
- Topic-level access control lists

**Best Practices:**
- Encrypt safety-critical commands
- Sign sensor data from critical sensors
- Validate message sources
- Rate limiting for topics

#### Unix Domain Sockets

**Security Requirements:**
- File system permissions
- Process authentication
- Data encryption for sensitive content

**Implementation:**

```rust
use std::os::unix::fs::PermissionsExt;
use std::fs;

fn create_secure_socket(path: &str) -> Result<(), IoError> {
    // Create socket with restricted permissions
    let socket = UnixListener::bind(path)?;
    let mut perms = fs::metadata(path)?.permissions();
    perms.set_mode(0o600); // Owner read/write only
    fs::set_permissions(path, perms)?;
    Ok(())
}
```

### 2. Network Communication

#### TLS/SSL

**Minimum Requirements:**
- TLS 1.2 or higher (prefer TLS 1.3)
- Strong cipher suites only
- Certificate validation
- Perfect Forward Secrecy (PFS)

**Recommended Cipher Suites:**
```
TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
```

**Forbidden Cipher Suites:**
- Any using RC4
- Any using MD5
- Any using NULL encryption
- Export-grade ciphers
- Anonymous DH

**Certificate Management:**

```rust
use rustls::{ServerConfig, ClientConfig};

fn create_tls_config() -> ServerConfig {
    let mut config = ServerConfig::new(NoClientAuth::new());
    
    // Load certificates
    let cert_file = File::open("cert.pem")?;
    let key_file = File::open("key.pem")?;
    
    config.set_single_cert(certs, key)?;
    
    // Configure cipher suites
    config.ciphersuites = &[
        CipherSuite::TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
        CipherSuite::TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
    ];
    
    config
}
```

**Certificate Requirements:**
- Minimum 2048-bit RSA or 256-bit ECC
- Valid CA signature
- Appropriate key usage extensions
- Certificate revocation checking (CRL or OCSP)
- Certificate pinning for critical connections

#### SSH

**Configuration Requirements:**

```
# /etc/ssh/sshd_config
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
MaxSessions 2
```

**Key Requirements:**
- ED25519 or RSA 4096-bit minimum
- No DSA keys
- Regular key rotation
- Passphrase-protected private keys

#### VPN (If Required)

**Recommended Protocols:**
- WireGuard
- OpenVPN with strong configuration
- IPsec with IKEv2

**Configuration:**
- Perfect Forward Secrecy
- Strong authentication
- Traffic encryption
- Regular key rotation

### 3. Wireless Communication

#### WiFi

**Security Requirements:**
- WPA3 (or WPA2-Enterprise minimum)
- Strong pre-shared keys (if WPA2-PSK)
- Hidden SSID (defense in depth)
- MAC filtering (defense in depth)

**Prohibited:**
- Open networks
- WEP
- WPA (original)
- WPS

#### Bluetooth

**Security Requirements:**
- Bluetooth 4.2+ (with Secure Connections)
- Out-of-band pairing
- Encryption enabled
- Authentication required

**Best Practices:**
- Disable when not needed
- Non-discoverable mode
- Whitelist of allowed devices
- Regular pairing review

### 4. External APIs

#### REST APIs

**Security Requirements:**
- HTTPS only (TLS 1.2+)
- API authentication (OAuth 2.0, API keys)
- Rate limiting
- Input validation

**Example Implementation:**

```rust
use actix_web::{web, App, HttpServer, HttpRequest};
use actix_web_httpauth::middleware::HttpAuthentication;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .wrap(HttpAuthentication::bearer(validator))
            .service(
                web::resource("/api/command")
                    .route(web::post().to(handle_command))
            )
    })
    .bind_rustls("127.0.0.1:8443", tls_config())?
    .run()
    .await
}
```

**API Security Headers:**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'self'
```

#### Cloud Services

**Security Requirements:**
- Mutual TLS authentication
- End-to-end encryption
- Secure credential storage
- Regular credential rotation

### 5. Serial Communication

#### UART/RS-232/RS-485

**Security Considerations:**
- Physical security (main protection)
- Checksums for integrity
- Authentication protocol if critical
- Encryption for sensitive data

**Example Protocol:**

```rust
struct SecureSerialMessage {
    command: Command,
    timestamp: u64,
    signature: [u8; 32], // HMAC-SHA256
}

impl SecureSerialMessage {
    fn verify(&self, key: &[u8]) -> bool {
        let mut mac = Hmac::<Sha256>::new_from_slice(key).unwrap();
        mac.update(&self.command.as_bytes());
        mac.update(&self.timestamp.to_le_bytes());
        mac.verify(&self.signature).is_ok()
    }
}
```

## Cryptographic Standards

### Algorithms

**Symmetric Encryption:**
- **Approved**: AES-256-GCM, AES-128-GCM, ChaCha20-Poly1305
- **Prohibited**: DES, 3DES, RC4, Blowfish

**Asymmetric Encryption:**
- **Approved**: RSA 2048+ bits, ECC 256+ bits (NIST P-256, Curve25519)
- **Prohibited**: RSA < 2048 bits, DSA

**Hash Functions:**
- **Approved**: SHA-256, SHA-384, SHA-512, BLAKE2
- **Prohibited**: MD5, SHA-1

**Message Authentication:**
- **Approved**: HMAC-SHA256, HMAC-SHA512
- **Prohibited**: HMAC-MD5, HMAC-SHA1

### Key Management

**Key Generation:**
- Use cryptographically secure random number generator (CSRNG)
- Sufficient entropy
- Hardware random number generator when available

**Key Storage:**
- Hardware Security Module (HSM) for production
- Encrypted key storage
- Secure enclave / Trusted Execution Environment (TEE)
- Never store keys in source code

**Key Rotation:**
- TLS certificates: Annual or earlier
- API keys: Quarterly
- Encryption keys: Annual or on compromise
- Session keys: Per session

**Key Destruction:**
- Secure erasure (multiple overwrites)
- Zeroization of memory
- Physical destruction of storage media

## Data Protection in Transit

### Encryption Requirements by Data Classification

| Data Classification | Encryption Required | Method |
|---------------------|-------------------|--------|
| Public | Optional | None or TLS |
| Internal | Recommended | TLS 1.2+ |
| Confidential | Required | TLS 1.2+ |
| Safety-Critical | Required | TLS 1.3 + application-level |
| Secret | Required | TLS 1.3 + end-to-end encryption |

### Safety-Critical Communications

**Additional Requirements:**
- Application-level encryption
- Digital signatures
- Replay attack prevention (timestamps, nonces)
- Sequence numbers
- Integrity checks

**Example:**

```rust
struct SafetyCriticalMessage {
    sequence: u64,
    timestamp: SystemTime,
    command: SafetyCommand,
    signature: Signature,
}

impl SafetyCriticalMessage {
    fn verify(&self, public_key: &PublicKey) -> Result<(), SecurityError> {
        // Check timestamp freshness
        if self.timestamp.elapsed()? > Duration::from_millis(100) {
            return Err(SecurityError::MessageTooOld);
        }
        
        // Verify sequence number
        if !self.sequence_is_valid() {
            return Err(SecurityError::InvalidSequence);
        }
        
        // Verify signature
        self.signature.verify(public_key, &self.command)?;
        
        Ok(())
    }
}
```

## Network Segmentation

### DMZ Architecture

```
Internet
   │
   ├─── Firewall ─── DMZ (Web/API Gateway)
   │                   │
   │                   ├─── Firewall ─── Management Network
   │                   │                      │
   │                   │                      └─── Robot Control Network
   │                   │
   │                   └─── Isolated Sensor Network
```

### VLAN Segmentation

- **VLAN 10**: Management
- **VLAN 20**: Control systems
- **VLAN 30**: Sensors
- **VLAN 40**: HMI/Operator interfaces
- **VLAN 99**: Guest/isolated

## Monitoring and Detection

### Communication Monitoring

**What to Monitor:**
- Failed authentication attempts
- Unusual traffic patterns
- Protocol violations
- Certificate validation failures
- Encryption downgrades

**Alerting Thresholds:**
- 3 failed auth attempts: Warning
- 10 failed auth attempts: Alert, potential block
- TLS negotiation failures: Alert
- Unencrypted traffic on encrypted channels: Critical alert

### Intrusion Detection

**Network IDS:**
- Snort or Suricata
- Signature-based detection
- Anomaly-based detection

**Host IDS:**
- File integrity monitoring
- Log analysis
- Process monitoring

## Incident Response

### Communication Breach Response

1. **Detect**: Identify the breach
2. **Contain**: Isolate affected systems
3. **Investigate**: Determine scope and impact
4. **Remediate**: Fix vulnerabilities, rotate keys
5. **Recover**: Restore secure operations
6. **Learn**: Update procedures and defenses

### Emergency Procedures

**Compromised TLS Certificates:**
1. Revoke certificate
2. Generate new certificate
3. Deploy new certificate
4. Update certificate pinning
5. Monitor for continued compromise

**Compromised Keys:**
1. Immediate key rotation
2. Audit all systems using the key
3. Review logs for unauthorized access
4. Re-encrypt data if necessary

## Compliance and Auditing

### Audit Logging

**What to Log:**
- Connection attempts
- Authentication events
- Key usage
- Certificate validation
- Protocol errors

**Log Retention:**
- Security events: 1 year minimum
- Audit events: 3 years (or per regulation)

### Compliance Standards

- **IEC 62443-4-2**: Security for industrial automation and control systems
- **NIST SP 800-52**: Guidelines for TLS implementations
- **NIST SP 800-57**: Key management recommendations

## Testing and Validation

### Security Testing

**Regular Testing:**
- TLS configuration testing (e.g., SSL Labs, testssl.sh)
- Penetration testing of communication channels
- Fuzzing of protocol implementations
- Certificate validation testing

**Test Cases:**
- Man-in-the-middle detection
- Certificate validation
- Downgrade attack prevention
- Replay attack prevention

## References

- [Threat Model](./threat_model.md)
- [Attack Surfaces](./attack_surfaces.md)
- [Access Control](./access_control.md)
- NIST SP 800-52: Guidelines for TLS Implementations
- IEC 62443-4-2: Technical Security Requirements for IACS Components

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Security Team | Initial secure communication guidelines |
