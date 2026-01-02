# Access Control

## Purpose

This document defines access control policies and mechanisms for robotics systems built with MPF. Proper access control is essential for preventing unauthorized access and maintaining system security.

## Access Control Principles

### Principle of Least Privilege

**Definition:** Users and processes should have only the minimum permissions necessary to perform their functions.

**Implementation:**
- Grant minimal required permissions
- Time-limited access when possible
- Regular access reviews
- Revoke access when no longer needed

### Separation of Duties

**Definition:** Critical operations should require multiple individuals or roles.

**Examples:**
- Code changes require review and approval by different person
- Software deployment requires approval
- Safety parameter changes require dual authorization

### Defense in Depth

**Definition:** Multiple layers of access control.

**Layers:**
1. Physical security
2. Network security
3. Operating system security
4. Application security
5. Data security

## Authentication

### User Authentication

#### Password Requirements

**Minimum Standards:**
- Length: 12 characters minimum
- Complexity: Mix of upper/lower case, numbers, symbols
- History: Last 5 passwords not reused
- Expiry: 90 days (or risk-based)
- Lockout: After 5 failed attempts

**Prohibited:**
- Default passwords
- Common passwords
- Shared accounts
- Password storage in plain text

#### Multi-Factor Authentication (MFA)

**Required For:**
- Administrative access
- Remote access
- Safety-critical operations
- Sensitive data access

**Acceptable Factors:**
1. **Something you know**: Password, PIN
2. **Something you have**: Hardware token, smartphone app, smart card
3. **Something you are**: Biometric (fingerprint, face recognition)

**Implementation Example:**

```rust
use totp_rs::{Algorithm, TOTP};

struct UserAuth {
    username: String,
    password_hash: String,
    totp_secret: Option<String>,
    failed_attempts: u32,
}

impl UserAuth {
    fn authenticate(&mut self, password: &str, totp_code: Option<&str>) 
        -> Result<(), AuthError> {
        // Check if account is locked
        if self.failed_attempts >= 5 {
            return Err(AuthError::AccountLocked);
        }
        
        // Verify password
        if !self.verify_password(password)? {
            self.failed_attempts += 1;
            return Err(AuthError::InvalidCredentials);
        }
        
        // Verify TOTP if required
        if let Some(secret) = &self.totp_secret {
            let code = totp_code.ok_or(AuthError::MfaRequired)?;
            if !self.verify_totp(secret, code)? {
                self.failed_attempts += 1;
                return Err(AuthError::InvalidMfa);
            }
        }
        
        // Reset failed attempts on success
        self.failed_attempts = 0;
        Ok(())
    }
}
```

#### Certificate-Based Authentication

**Use Cases:**
- Machine-to-machine communication
- Service accounts
- ROS 2 Security (SROS2)

**Requirements:**
- X.509 certificates from trusted CA
- Private key protection
- Certificate revocation checking
- Regular certificate rotation

### Service Authentication

#### API Keys

**Management:**
- Unique key per service/application
- Secure generation (cryptographically random)
- Encrypted storage
- Regular rotation (quarterly)
- Immediate revocation capability

**Example:**

```rust
struct ApiKey {
    key_id: String,
    key_hash: String, // Never store plain key
    permissions: Vec<Permission>,
    created_at: SystemTime,
    expires_at: SystemTime,
    last_used: Option<SystemTime>,
}

impl ApiKey {
    fn is_valid(&self) -> bool {
        SystemTime::now() < self.expires_at
    }
    
    fn has_permission(&self, required: &Permission) -> bool {
        self.permissions.contains(required)
    }
}
```

#### OAuth 2.0 / OpenID Connect

**Use Cases:**
- Third-party integrations
- Delegated authorization
- Single Sign-On (SSO)

**Grant Types:**
- Authorization Code (preferred for web apps)
- Client Credentials (for service-to-service)
- Not recommended: Implicit flow, Resource Owner Password

## Authorization

### Role-Based Access Control (RBAC)

**Standard Roles:**

| Role | Permissions | Use Case |
|------|------------|----------|
| **Operator** | Start/stop missions, view status | Normal operation |
| **Technician** | Diagnostics, calibration, maintenance | Maintenance |
| **Engineer** | Configuration, parameter tuning | Development, commissioning |
| **Safety Officer** | Safety parameter access, emergency stop | Safety management |
| **Administrator** | User management, system configuration | System administration |
| **Auditor** | Read-only access to logs and configuration | Compliance, investigation |

**Implementation:**

```rust
#[derive(Debug, Clone, PartialEq)]
enum Role {
    Operator,
    Technician,
    Engineer,
    SafetyOfficer,
    Administrator,
    Auditor,
}

#[derive(Debug, Clone, PartialEq)]
enum Permission {
    StartMission,
    StopMission,
    ViewStatus,
    ModifyConfiguration,
    ModifySafetyParameters,
    AccessDiagnostics,
    ManageUsers,
    ViewLogs,
    EmergencyStop,
}

impl Role {
    fn permissions(&self) -> Vec<Permission> {
        use Permission::*;
        match self {
            Role::Operator => vec![StartMission, StopMission, ViewStatus],
            Role::Technician => vec![
                ViewStatus, AccessDiagnostics, StopMission
            ],
            Role::Engineer => vec![
                ViewStatus, ModifyConfiguration, AccessDiagnostics,
                StartMission, StopMission
            ],
            Role::SafetyOfficer => vec![
                ViewStatus, ModifySafetyParameters, EmergencyStop,
                ViewLogs, AccessDiagnostics
            ],
            Role::Administrator => vec![
                ManageUsers, ModifyConfiguration, ViewLogs,
                AccessDiagnostics, StartMission, StopMission,
                ViewStatus
            ],
            Role::Auditor => vec![ViewLogs, ViewStatus],
        }
    }
}
```

### Attribute-Based Access Control (ABAC)

**Use Cases:**
- Fine-grained access control
- Context-aware authorization
- Dynamic policies

**Attributes:**
- User attributes (role, department, clearance)
- Resource attributes (classification, owner)
- Environmental attributes (time, location, network)

**Example Policy:**

```rust
struct AccessPolicy {
    resource: Resource,
    conditions: Vec<Condition>,
}

enum Condition {
    RequireRole(Role),
    RequireTimeslot { start: Time, end: Time },
    RequireNetwork(NetworkSegment),
    RequireMfa,
}

impl AccessPolicy {
    fn evaluate(&self, context: &AccessContext) -> bool {
        self.conditions.iter().all(|cond| {
            match cond {
                Condition::RequireRole(role) => 
                    context.user.has_role(role),
                Condition::RequireTimeslot { start, end } => 
                    context.time >= *start && context.time <= *end,
                Condition::RequireNetwork(net) => 
                    context.network == *net,
                Condition::RequireMfa => 
                    context.mfa_verified,
            }
        })
    }
}
```

## Access Control Implementation

### Operating System Level

#### Linux File Permissions

```bash
# Configuration files - read-only for application user
chmod 400 /etc/robot/config.toml
chown robot:robot /etc/robot/config.toml

# Log directory - writable by application
chmod 750 /var/log/robot/
chown robot:robot /var/log/robot/

# Executable - no write permission
chmod 550 /usr/bin/robot-controller
chown root:robot /usr/bin/robot-controller
```

#### Linux Capabilities

Avoid running as root by using capabilities:

```bash
# Give specific capability instead of full root
setcap cap_net_bind_service=+ep /usr/bin/robot-service
```

#### SELinux / AppArmor

Mandatory Access Control (MAC) for additional protection:

```
# AppArmor profile example
/usr/bin/robot-controller {
  # Allow reading configuration
  /etc/robot/** r,
  
  # Allow writing logs
  /var/log/robot/** rw,
  
  # Allow network access
  network inet stream,
  
  # Deny everything else
  deny /** w,
}
```

### Application Level

#### Access Control Lists (ACLs)

```rust
struct Acl {
    resource: ResourceId,
    entries: Vec<AclEntry>,
}

struct AclEntry {
    principal: Principal, // User or Role
    permissions: Vec<Permission>,
    allow: bool, // Allow or Deny
}

impl Acl {
    fn check_access(&self, user: &User, permission: &Permission) 
        -> AccessDecision {
        // Deny takes precedence
        for entry in &self.entries {
            if entry.matches(user) && entry.permissions.contains(permission) {
                if !entry.allow {
                    return AccessDecision::Deny;
                }
            }
        }
        
        // Then check for allows
        for entry in &self.entries {
            if entry.matches(user) && entry.permissions.contains(permission) {
                if entry.allow {
                    return AccessDecision::Allow;
                }
            }
        }
        
        // Default deny
        AccessDecision::Deny
    }
}
```

### ROS 2 Access Control

Using SROS2 (Secure ROS 2):

```bash
# Create security files
ros2 security create_keystore demo_keys
ros2 security create_key demo_keys /node_name

# Create access control policy
# In policy.xml:
<policy>
  <enclaves>
    <enclave path="/robot_controller">
      <profiles>
        <profile ns="/" node="motion_controller">
          <topics publish="ALLOW">
            <topic>cmd_vel</topic>
          </topics>
          <topics subscribe="ALLOW">
            <topic>sensor_data</topic>
          </topics>
          <services reply="ALLOW">
            <service>emergency_stop</service>
          </services>
        </profile>
      </profiles>
    </enclave>
  </enclaves>
</policy>
```

## Session Management

### Session Security

**Requirements:**
- Secure session ID generation
- Session timeout after inactivity
- Session invalidation on logout
- Concurrent session limits

**Implementation:**

```rust
struct Session {
    id: SessionId,
    user_id: UserId,
    created_at: SystemTime,
    last_activity: SystemTime,
    ip_address: IpAddr,
}

impl Session {
    fn is_valid(&self) -> bool {
        let now = SystemTime::now();
        let max_lifetime = Duration::from_hours(8);
        let inactivity_timeout = Duration::from_minutes(30);
        
        // Check total session lifetime
        if now.duration_since(self.created_at).unwrap() > max_lifetime {
            return false;
        }
        
        // Check inactivity timeout
        if now.duration_since(self.last_activity).unwrap() > inactivity_timeout {
            return false;
        }
        
        true
    }
}
```

## Audit and Logging

### Access Audit Events

**Events to Log:**
- Authentication attempts (success and failure)
- Authorization decisions (especially denials)
- Privilege escalations
- Account creation/modification/deletion
- Access to sensitive resources
- Administrative actions

**Log Format:**

```rust
struct AccessLogEntry {
    timestamp: SystemTime,
    event_type: AccessEventType,
    user: String,
    resource: String,
    action: String,
    result: AccessResult,
    ip_address: Option<IpAddr>,
    additional_context: HashMap<String, String>,
}

enum AccessEventType {
    Authentication,
    Authorization,
    PrivilegeEscalation,
    AccountManagement,
    ResourceAccess,
}

enum AccessResult {
    Success,
    Failure(String), // Reason for failure
}
```

### Log Protection

- Append-only logs
- Integrity protection (digital signatures)
- Secure storage
- Access control on logs themselves
- Centralized log collection

## Physical Access Control

### Facility Access

- Badge/card access systems
- Biometric readers
- Security cameras
- Visitor management
- Access logs

### Hardware Access

- Locked enclosures for controllers
- Cable locks for portable devices
- Tamper-evident seals
- Secured equipment rooms

## Emergency Access

### Break-Glass Procedures

**Purpose:** Provide emergency access when normal procedures are not feasible.

**Requirements:**
- Documented procedures
- Strong audit trail
- Limited duration
- Immediate notification to security team
- Post-incident review

**Example:**

```rust
struct EmergencyAccess {
    granted_to: UserId,
    granted_by: UserId,
    reason: String,
    granted_at: SystemTime,
    expires_at: SystemTime,
    elevated_permissions: Vec<Permission>,
}

impl EmergencyAccess {
    fn grant(user: UserId, reason: String) -> Result<Self, Error> {
        // Log emergency access request
        audit_log::log_emergency_access_request(&user, &reason);
        
        // Notify security team
        notify_security_team(&user, &reason);
        
        Ok(EmergencyAccess {
            granted_to: user,
            granted_by: current_admin(),
            reason,
            granted_at: SystemTime::now(),
            expires_at: SystemTime::now() + Duration::from_hours(4),
            elevated_permissions: vec![/* temporary permissions */],
        })
    }
}
```

## Access Review and Maintenance

### Regular Reviews

**Frequency:**
- User access: Quarterly
- Administrative access: Monthly
- Service accounts: Quarterly
- Shared accounts: Never (should not exist)

**Review Process:**
1. List all users and their permissions
2. Verify employment/role status
3. Confirm access is still required
4. Remove unnecessary permissions
5. Document review results

### Onboarding/Offboarding

**Onboarding:**
1. Identity verification
2. Role assignment
3. Account provisioning
4. Security training
5. Document access granted

**Offboarding:**
1. Immediate account deactivation
2. Credential revocation
3. Access removal
4. Key/badge return
5. Document access revoked

## References

- [Threat Model](./threat_model.md)
- [Attack Surfaces](./attack_surfaces.md)
- [Secure Communication](./secure_communication.md)
- NIST SP 800-53: Security and Privacy Controls (AC family)
- ISO/IEC 27001: Access control

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Security Team | Initial access control policy |
