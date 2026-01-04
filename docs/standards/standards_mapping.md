# Standards Mapping

## Purpose

This document maps specific project requirements to applicable standard clauses. This mapping is essential for demonstrating compliance and facilitating audits.

## How to Use This Document

For each project using MPF:

1. Identify applicable standards from [Applicable Standards](./applicable_standards.md)
2. List specific requirements from those standards
3. Map each requirement to implementation artifacts (code, tests, documentation)
4. Document verification methods

## Template: Standards Mapping Table

### Example: ISO 13849-1 Mapping

| Standard Clause | Requirement Summary | MPF Implementation | Verification Method | Status |
|-----------------|---------------------|-------------------|---------------------|--------|
| 4.1 - General | Safety function shall be designed according to risk assessment | `docs/safety_case/hazard_analysis_summary.md` | Design review | Planned |
| 4.3 - Categories | Define safety category (B, 1, 2, 3, 4) | Architecture design in `domain/` module | Architecture review | Planned |
| 4.5 - Faults | Consider faults and error conditions | Error handling in `shared/error_model/` | FMEA, Testing | Planned |
| 4.6 - Validation | Validate safety functions | Test suite in `infrastructure/tests/` | Test execution | Planned |

### Example: IEC 61508 Mapping

| Standard Clause | Requirement Summary | MPF Implementation | Verification Method | Status |
|-----------------|---------------------|-------------------|---------------------|--------|
| 7.4.2.2 - Software architecture | Define software architecture | Clean Architecture layers (domain, application, infrastructure) | Architecture review | Implemented |
| 7.4.4.1 - Coding standards | Apply coding standards | MISRA Rust guidelines in `docs/development/coding_rules.md` | Static analysis | Planned |
| 7.4.5.1 - Software module testing | Test individual modules | Unit tests per module | Test coverage report | Planned |
| 7.4.6.1 - Software integration testing | Test integrated modules | Integration tests in each module | Test execution | Planned |

### Example: IEC 62443 Mapping

| Standard Clause | Requirement Summary | MPF Implementation | Verification Method | Status |
|-----------------|---------------------|-------------------|---------------------|--------|
| 3-3 SR 1.1 | User identification and authentication | Access control in `infrastructure/auth/` | Security testing | Planned |
| 3-3 SR 1.2 | Use of multi-factor authentication | MFA implementation in interfaces | Security audit | Planned |
| 3-3 SR 3.1 | Communication integrity | Secure communication protocols in `docs/cybersecurity/secure_communication.md` | Protocol verification | Planned |
| 3-3 SR 7.1 | Deny by default | Firewall rules, access control defaults | Configuration review | Planned |

## Project-Specific Mapping

### [Project Name]

**Applicable Standards:**
- [List standards that apply to this specific project]

**Safety Integrity Level:** [SIL 1/2/3 or PLd/PLe]

#### Standard: [Standard Name]

| Standard Clause | Requirement Summary | Implementation Location | Verification Method | Responsible | Status |
|-----------------|---------------------|------------------------|---------------------|-------------|--------|
| | | | | | |
| | | | | | |

## Traceability Matrix

### Requirements to Implementation

| Requirement ID | Standard Reference | Implementation Artifact | Test Case ID | Status |
|----------------|-------------------|------------------------|-------------|--------|
| REQ-SAF-001 | ISO 13849-1 § 4.1 | `domain/safety/emergency_stop.rs` | TEST-SAF-001 | Implemented |
| REQ-SAF-002 | ISO 13849-1 § 4.3 | `application/safety_monitoring/` | TEST-SAF-002 | Planned |
| REQ-CYB-001 | IEC 62443-3-3 SR 1.1 | `infrastructure/auth/user_auth.rs` | TEST-CYB-001 | Planned |

### Implementation to Standards

| Implementation Artifact | Requirement ID(s) | Standard Reference(s) | Verification |
|------------------------|-------------------|----------------------|--------------|
| `domain/safety/` | REQ-SAF-001, REQ-SAF-002 | ISO 13849-1 § 4.1, 4.3 | Design review, Testing |
| `shared/error_model/` | REQ-SAF-005 | IEC 61508 § 7.4.2.3 | Code review, Static analysis |

## Verification and Validation Plan

### Design Verification

| Activity | Method | Responsible | Schedule |
|----------|--------|-------------|----------|
| Architecture review | Review against Clean Architecture principles | Lead architect | Before implementation |
| Code review | Peer review, static analysis | Development team | Per feature |
| Safety analysis | FMEA, FTA | Safety engineer | Design phase |

### Validation

| Activity | Method | Responsible | Schedule |
|----------|--------|-------------|----------|
| Unit testing | Automated tests | Developers | Continuous |
| Integration testing | Automated tests | Integration team | Per sprint |
| System testing | Test execution | QA team | Pre-release |
| Safety validation | Safety test plan execution | Safety engineer | Pre-release |

## Tool Qualification

Per IEC 61508, development tools must be qualified based on their impact on safety.

| Tool | Purpose | Tool Class | Qualification Required | Status |
|------|---------|-----------|------------------------|--------|
| Rust compiler | Code compilation | T2 | Yes | Planned |
| Static analyzer | Code verification | T3 | Yes | Planned |
| Test framework | Test execution | T3 | Yes | Planned |

## Audit Trail

Document all changes to this mapping:

| Date | Version | Changed By | Changes | Reason |
|------|---------|-----------|---------|--------|
| | 1.0 | | Initial version | Project start |

## Notes

- This document must be updated when:
  - New requirements are added
  - Standards are updated to new versions
  - Implementation changes affect compliance
  - Verification results are obtained

- All mappings must be reviewed during:
  - Design reviews
  - Code reviews
  - Pre-release audits
  - Post-incident analyses

## References

- [Applicable Standards](./applicable_standards.md)
- [Deviations and Justifications](./deviations_and_justifications.md)
- Project Requirements Specification
- Safety Requirements Specification
