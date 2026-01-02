# Goal Structuring Notation (Textual)

## Purpose

Present safety arguments in GSN format (textual representation).

## GSN Elements

### Goals (G)
Claims about system safety

### Strategies (S)
Approaches to achieve goals

### Solutions (Sn)
Evidence supporting goals

### Context (C)
Relevant background information

### Assumptions (A)
Dependencies and assumptions

### Justifications (J)
Rationale for approach

## Example: Emergency Stop Argument

```
G1: Emergency stop system is acceptably safe
├── C1: Operating per ISO 13849-1
├── C2: SIL 2 requirement
└── S1: Argue by decomposition into subsystems
    ├── G1.1: Hardware circuit is fail-safe
    │   ├── A1: Components are reliable
    │   └── Sn1: Hardware design review (DOC-HW-001)
    │   └── Sn2: Component specifications
    ├── G1.2: Stop time meets requirement
    │   ├── C3: Required stop time < 100ms
    │   └── Sn3: Emergency stop tests (TEST-SAF-001)
    └── G1.3: Failure modes are handled
        ├── J1: FMEA covers all failure modes
        └── Sn4: FMEA report (FMEA-ES-001)
```

## Complete Argument Hierarchy

```
TLC: System is acceptably safe
├── C: Scope and assumptions (DOC-SCOPE-001)
└── S: Argue by hazard mitigation
    ├── G1: All hazards identified
    │   └── Sn: Hazard analysis (HAZOP-001, FMEA-001)
    ├── G2: Hazards adequately mitigated
    │   └── S: By risk reduction measures
    │       ├── G2.1: Emergency stop (see above)
    │       ├── G2.2: Safe speeds
    │       └── G2.3: Collision prevention
    └── G3: Safety requirements verified
        └── Sn: Test results (TEST-*)
```

## References
- [Safety Arguments](./safety_arguments.md)
- [Evidence Mapping](./evidence_mapping.md)

## Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Safety Team | Initial version |
