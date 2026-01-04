# CI/CD for Robotics

## Purpose

This document defines continuous integration and continuous deployment practices for robotics projects built with MPF.

## CI Pipeline

### Build Stage

```yaml
build:
  stage: build
  script:
    - cargo build --release --all-targets
    - cargo build --release --target=armv7-unknown-linux-gnueabihf  # Cross-compile
  artifacts:
    paths:
      - target/release/
```

### Test Stage

```yaml
test:
  stage: test
  script:
    - cargo test --all
    - cargo test --release
  coverage: '/^TOTAL.*\s+(\d+\%)$/'
```

### Analysis Stage

```yaml
analysis:
  stage: analysis
  script:
    - cargo clippy -- -D warnings
    - cargo audit
    - cargo deny check
```

## CD Pipeline

### Staging Deployment

- Automatic deployment on merge to `develop`
- Smoke tests after deployment
- Notification on success/failure

### Production Deployment

- Manual approval required
- Deployment to subset of fleet first
- Gradual rollout
- Automatic rollback on failure

## Hardware-in-the-Loop CI

### HIL Test Setup

```
┌──────────────┐      ┌──────────────┐
│  CI Server   │─────▶│  Robot Unit  │
│              │      │  (Test Stand)│
└──────────────┘      └──────────────┘
```

### HIL Test Categories

- Safety system verification
- Actuator response
- Sensor integration
- Communication protocols

## Artifact Management

### Build Artifacts

- Signed binaries
- Debug symbols (separate)
- Release notes
- Test reports

### Versioning

Use semantic versioning: `MAJOR.MINOR.PATCH`

## References

- [Development Process](./development_process.md)
- [Update Security](../cybersecurity/update_security.md)

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Development Team | Initial CI/CD guidelines |
