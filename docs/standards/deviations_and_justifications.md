# Deviations and Justifications

## Purpose

This document records any deviations from applicable standards, along with detailed justifications and compensating measures. Transparent documentation of deviations is essential for audit readiness and regulatory compliance.

## Deviation Process

When a project cannot fully comply with a standard requirement:

1. **Document the deviation**: Clearly state what requirement cannot be met
2. **Provide justification**: Explain why compliance is not feasible
3. **Assess risk**: Evaluate safety and security implications
4. **Define compensating measures**: Implement alternative controls
5. **Obtain approval**: Get sign-off from safety/compliance authority

## Deviation Template

For each deviation, document:

- **Deviation ID**: Unique identifier
- **Standard Reference**: Which standard and clause
- **Requirement**: What is required by the standard
- **Actual Implementation**: What is actually implemented
- **Justification**: Why deviation is necessary
- **Risk Assessment**: Potential impact
- **Compensating Measures**: Alternative controls
- **Approval**: Who approved and when
- **Review Date**: When deviation will be re-evaluated

## Active Deviations

### DEV-001: [Example - Tool Qualification]

**Standard Reference:** IEC 61508-3:2010 § 7.4.2.7 (Tool qualification)

**Requirement:** All software tools used to develop safety-critical code must be qualified according to tool class.

**Actual Implementation:** Rust compiler is used without formal qualification as T2 tool.

**Justification:**
- Rust compiler is widely used and extensively tested
- Open-source nature allows source code review
- Strong type system and memory safety reduce compiler-related risks
- Cost and time for full tool qualification not justified for current SIL level

**Risk Assessment:**
- **Likelihood**: Low (compiler bugs affecting safety are rare)
- **Severity**: Medium (potential for incorrect code generation)
- **Overall Risk**: Low-Medium

**Compensating Measures:**
1. Use stable, well-tested compiler versions
2. Extensive testing of compiled code
3. Static analysis to detect potential issues
4. Code review of critical safety functions
5. Hardware watchdog as ultimate safety net

**Approval:**
- **Approved by**: [Safety Manager Name]
- **Date**: [Date]
- **Conditions**: Limited to SIL 2 applications

**Review Date:** [Annual review date]

---

### DEV-002: [Example - Placeholder for Project Deviation]

**Standard Reference:** [Standard] § [Clause]

**Requirement:** [Requirement text]

**Actual Implementation:** [What is implemented]

**Justification:** [Why]

**Risk Assessment:** [Impact analysis]

**Compensating Measures:** [Alternative controls]

**Approval:**
- **Approved by**: [Name]
- **Date**: [Date]

**Review Date:** [Date]

---

## Closed Deviations

### DEV-XXX: [Example - Resolved Deviation]

**Standard Reference:** [Standard] § [Clause]

**Requirement:** [Requirement text]

**Original Deviation:** [What was deviated]

**Resolution:** [How it was resolved]

**Closed By:** [Name]

**Closure Date:** [Date]

---

## Deviation Categories

### Acceptable Deviations

Deviations that are generally acceptable with proper justification:

- Use of modern tools not explicitly covered by older standards
- Application-specific tailoring of generic requirements
- Use of equivalent alternative methods with demonstrated safety
- Practical limitations in testing environments

### Unacceptable Deviations

Deviations that are generally NOT acceptable:

- Omission of critical safety functions
- Bypassing required safety analysis
- Inadequate testing of safety-critical code
- Missing traceability for safety requirements
- Failure to implement required security measures

## Risk Matrix for Deviation Assessment

| Likelihood | Severity: Minor | Severity: Moderate | Severity: Major | Severity: Critical |
|------------|----------------|-------------------|----------------|-------------------|
| Very Unlikely | Low | Low | Medium | High |
| Unlikely | Low | Medium | Medium | High |
| Possible | Medium | Medium | High | Very High |
| Likely | Medium | High | High | Very High |
| Very Likely | High | High | Very High | Very High |

**Decision Criteria:**
- **Low Risk**: Deviation may be acceptable with compensating measures
- **Medium Risk**: Deviation requires strong justification and compensating measures
- **High Risk**: Deviation requires exceptional justification, multiple compensating measures, and management approval
- **Very High Risk**: Deviation generally not acceptable

## Approval Authority

| Risk Level | Approval Required |
|-----------|------------------|
| Low | Project Safety Officer |
| Medium | Safety Manager |
| High | Safety Manager + Technical Authority |
| Very High | Safety Board + Management |

## Review and Update Process

- **Periodic Review**: All deviations must be reviewed annually
- **Trigger Events**: Review required when:
  - Standard is updated to new version
  - Implementation changes
  - Incident occurs related to deviation area
  - New technology becomes available

## Traceability

### Deviations to Risk Assessment

| Deviation ID | Related Hazard(s) | Risk Level | Compensating Measures Effective? |
|--------------|------------------|-----------|--------------------------------|
| DEV-001 | HAZ-SW-001 | Low-Medium | Yes |

### Deviations to Testing

| Deviation ID | Additional Test Cases | Test Results |
|--------------|----------------------|--------------|
| DEV-001 | TEST-COMP-001, TEST-COMP-002 | Pass |

## Lessons Learned

Document insights from deviations:

- What worked well as compensating measure
- What didn't work as expected
- Best practices for future projects
- Standards gaps or improvement opportunities

## References

- [Applicable Standards](./applicable_standards.md)
- [Standards Mapping](./standards_mapping.md)
- Project Risk Register
- Safety Case Documentation

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Team | Initial version |

## Notes

**Important**: This document is critical for audits. All deviations must be:
- Thoroughly documented
- Properly justified
- Risk-assessed
- Approved by appropriate authority
- Regularly reviewed
