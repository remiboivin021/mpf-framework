# Safety Arguments

## Purpose

Present structured arguments linking safety claims to evidence.

## Argument Structure

Using Goal Structuring Notation (GSN) principles:

### Argument Pattern

```
Goal (Claim)
    ├── Strategy (How to achieve goal)
    ├── Context (Relevant information)
    ├── Sub-Goals (Decomposition)
    └── Evidence (Supporting data)
```

## Main Safety Arguments

### Argument 1: Emergency Stop Effectiveness

**Goal**: Emergency stop reliably stops robot within 100ms

**Strategy**: Argue by demonstrating hardware safety + testing

**Context**:
- ISO 13849-1 Category 3
- SIL 2 requirement

**Sub-Goals**:
1. Hardware emergency stop circuit is fail-safe
2. Stop time is verified by testing
3. All failure modes are handled

**Evidence**:
- Hardware design review (DOC-HW-001)
- Emergency stop test results (TEST-SAF-001)
- FMEA for emergency stop (FMEA-ES-001)

### Argument 2: Safe Speed Limits

**Goal**: Robot speed never exceeds safe limits

**Strategy**: Argue by software + hardware enforcement

**Context**:
- Maximum safe speed: 2.0 m/s
- Based on ISO/TS 15066

**Sub-Goals**:
1. Software enforces velocity limits
2. Hardware watchdog detects violations
3. Limits verified by testing

**Evidence**:
- Code review (REV-MOT-001)
- Unit tests (TEST-UNIT-VEL)
- Integration tests (TEST-INT-LIM)
- HIL tests (TEST-HIL-SPEED)

### Argument 3: Collision Prevention

**Goal**: Risk of collision is acceptably low

**Strategy**: Argue through multiple layers of protection

**Context**:
- Collaborative operation
- Human presence expected

**Sub-Goals**:
1. Workspace boundaries are enforced
2. Collision detection is functional
3. Safe separation is maintained

**Evidence**:
- Workspace configuration (CFG-WS-001)
- Collision detection tests (TEST-COL-001)
- Separation monitoring logs (LOG-SEP-*)

## Argument Validation

Each argument must:
- Be logically sound
- Have supporting evidence
- Address counter-arguments
- Be maintained over time

## References
- [Top-Level Claims](./top_level_claims.md)
- [Evidence Mapping](./evidence_mapping.md)
- GSN Standard (Origin Consulting)

## Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Safety Team | Initial version |
