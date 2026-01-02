# Regression Testing Policy

## Purpose

Define regression testing requirements to ensure changes don't break existing functionality.

## Regression Test Suite

### Core Test Suite
Must pass before any merge:
- All unit tests
- Critical integration tests
- Safety system tests

### Extended Test Suite
Run nightly:
- Full integration tests
- Performance tests
- Long-running tests

### Hardware Tests
Run weekly:
- HIL tests
- Full system tests
- Hardware integration tests

## Test Selection

### Risk-Based Selection
- High-risk changes: Full regression
- Medium-risk: Affected subsystems
- Low-risk: Core tests only

### Coverage Requirements
- Safety-critical: 100% of safety tests
- Critical paths: 100% of critical tests
- All other code: > 80% coverage

## Failure Handling

If regression tests fail:
1. Block merge/deployment
2. Investigate root cause
3. Fix issue
4. Re-run tests
5. Document incident

## References
- [Change Impact](./change_impact_robot.md)
- [Development Process](../development/development_process.md)

## Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | QA Team | Initial version |
