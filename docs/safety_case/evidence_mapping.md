# Evidence Mapping

## Purpose

Map safety claims to supporting evidence.

## Evidence Categories

### Design Evidence
- Architecture documents
- Design specifications
- Safety analysis reports

### Implementation Evidence
- Source code
- Code reviews
- Static analysis reports

### Verification Evidence
- Test plans
- Test results
- Coverage reports

### Validation Evidence
- HIL test results
- Field test results
- User acceptance

## Evidence Traceability Matrix

| Claim | Evidence ID | Evidence Type | Location | Status |
|-------|------------|---------------|----------|--------|
| SC-1 | HAZOP-001 | Analysis | docs/safety/hazop.pdf | Complete |
| SC-1 | FMEA-001 | Analysis | docs/safety/fmea.pdf | Complete |
| SC-2 | SRS-001 | Requirements | docs/requirements/srs.md | Complete |
| SC-2 | TEST-SAF-* | Tests | test_results/ | In Progress |
| SC-3 | DOC-HW-001 | Design | docs/hardware/es_design.pdf | Complete |
| SC-3 | TEST-SAF-001 | Tests | test_results/es_test.pdf | Complete |
| SC-4 | TEST-COL-001 | Tests | test_results/collision.pdf | Planned |
| SC-5 | FMEA-SYS-001 | Analysis | docs/safety/system_fmea.pdf | In Progress |

## Evidence Quality Criteria

### Completeness
- All claims have supporting evidence
- Evidence addresses all aspects of claim

### Independence
- Evidence from independent sources when critical
- No conflicts of interest

### Sufficiency
- Evidence is adequate to support claim
- Multiple evidence types preferred

### Currency
- Evidence is up-to-date
- Re-validated after changes

## Evidence Gaps

Document any gaps in evidence:

| Claim | Gap Description | Mitigation | Target Date |
|-------|----------------|------------|-------------|
| SC-4 | Collision tests incomplete | Schedule HIL tests | Q1 2024 |

## References
- [Top-Level Claims](./top_level_claims.md)
- [Safety Arguments](./safety_arguments.md)

## Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Safety Team | Initial version |
