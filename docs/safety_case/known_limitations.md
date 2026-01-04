# Known Limitations

## Purpose

Document known limitations and exclusions of the safety case.

## System Limitations

### Operational Limitations

**Speed Limit**: 2.0 m/s maximum
- Based on risk assessment per ISO/TS 15066
- Higher speeds require additional safeguards

**Payload Limit**: 25 kg maximum
- Exceeding may cause instability
- Force limits may be exceeded

**Workspace**: Defined by configuration
- Must not be exceeded during operation
- Boundaries enforced by software and sensors

### Environmental Limitations

**Temperature**: 10-40°C operating range
- Below 10°C: Reduced performance
- Above 40°C: Thermal protection may activate

**Humidity**: 20-80% non-condensing
- Higher humidity may affect sensors

**Lighting**: Adequate lighting required
- Vision systems need minimum illumination

## Safety Case Limitations

### Scope Exclusions

Not covered by this safety case:
- External infrastructure failures
- Natural disasters
- Intentional misuse or sabotage
- Unauthorized modifications

### Evidence Gaps

Current gaps in safety evidence:
- Long-term reliability data (< 1 year operation)
- Extreme environmental testing
- Full FMEA coverage (in progress)

### Assumptions

Safety case validity depends on:
- Trained operators
- Proper maintenance
- No unauthorized modifications
- Operating within specified limits

## Risk Acceptance

### Residual Risks

Risks accepted after mitigation:
- Low probability equipment failures
- Operator errors despite training
- Unforeseen environmental factors

### ALARP Demonstration

Risks reduced to As Low As Reasonably Practicable (ALARP):
- Further risk reduction disproportionately costly
- Industry best practices applied
- Comparable to similar systems

## Known Issues

### Open Issues

| ID | Description | Severity | Status | Target Resolution |
|----|-------------|----------|--------|-------------------|
| ISS-001 | Calibration drift over time | Low | Open | Monitor in field |
| ISS-002 | Edge case in collision detection | Medium | In Progress | Q1 2024 |

## Future Improvements

Potential enhancements:
- Additional sensor redundancy
- Advanced collision prediction
- Automated health monitoring
- Predictive maintenance

## References
- [Assumptions and Scope](./assumptions_and_scope.md)
- [Hazard Analysis](./hazard_analysis_summary.md)

## Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Safety Team | Initial version |
