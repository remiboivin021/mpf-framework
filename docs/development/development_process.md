# Development Process

## Purpose

This document defines the software development process for robotics projects built with the Modular Project Framework (MPF). The process is designed to ensure quality, safety, and compliance with industrial standards.

## Development Lifecycle

### Process Model

We follow an iterative development model with safety validation at each stage:

```
Requirements → Design → Implementation → Verification → Validation → Release
       ↑                                                               ↓
       └───────────────────── Feedback ──────────────────────────────┘
```

### Phases

#### 1. Requirements Analysis

**Activities:**
- Gather and document requirements
- Perform risk assessment
- Identify safety requirements
- Define acceptance criteria
- Create traceability matrix

**Outputs:**
- Requirements Specification
- Safety Requirements Specification
- Hazard Analysis (HAZOP/FMEA)

**Review Gates:**
- Requirements review
- Safety review
- Stakeholder approval

#### 2. Architecture and Design

**Activities:**
- Define system architecture
- Design software components
- Identify interfaces
- Allocate safety requirements
- Define test strategy

**Outputs:**
- Architecture Document
- Design Specifications
- Interface Specifications
- Safety Architecture
- Test Plan

**Review Gates:**
- Architecture review
- Design review
- Safety design review

#### 3. Implementation

**Activities:**
- Write code following [Coding Rules](./coding_rules.md)
- Implement unit tests
- Document code
- Perform static analysis
- Code reviews

**Outputs:**
- Source code
- Unit tests
- Code documentation
- Static analysis reports

**Quality Gates:**
- Code review approval
- All tests pass
- Static analysis clean
- Code coverage targets met

#### 4. Verification

**Activities:**
- Unit testing
- Integration testing
- System testing
- Static analysis
- Dynamic analysis

**Outputs:**
- Test results
- Coverage reports
- Analysis reports
- Defect reports

**Quality Gates:**
- All tests pass
- Coverage > 90% for safety-critical code
- No critical/high severity defects

#### 5. Validation

**Activities:**
- Validate requirements are met
- Safety validation
- Performance testing
- User acceptance testing
- Field testing

**Outputs:**
- Validation test results
- Safety validation report
- Performance test results
- User acceptance sign-off

**Quality Gates:**
- All requirements validated
- Safety requirements confirmed
- Performance criteria met
- User acceptance obtained

#### 6. Release

**Activities:**
- Create release package
- Generate documentation
- Security scan
- Sign binaries
- Deploy to staging
- Production deployment

**Outputs:**
- Release package
- Release notes
- Deployment documentation
- Security scan report

**Quality Gates:**
- All quality gates passed
- Documentation complete
- Security approved
- Deployment tested

## Agile Practices

### Sprint Structure

**Sprint Duration:** 2 weeks

**Sprint Activities:**
- Sprint Planning
- Daily Stand-ups
- Sprint Review
- Sprint Retrospective

**Definition of Done:**
- Code complete and reviewed
- Tests written and passing
- Documentation updated
- Static analysis clean
- Safety requirements verified (if applicable)

### User Stories

**Format:**
```
As a [role]
I want to [action]
So that [benefit]

Acceptance Criteria:
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] ...

Safety Considerations:
- [Safety aspects if applicable]

Requirements Traceability:
- REQ-XXX-YYY
```

### Story Points

Use Fibonacci sequence: 1, 2, 3, 5, 8, 13

- **1-2 points**: Simple, well-understood tasks
- **3-5 points**: Moderate complexity
- **8+ points**: Complex, should be broken down

## Code Review Process

### Review Requirements

**All code must be reviewed before merging.**

**Review Checklist:**
- [ ] Follows coding standards
- [ ] Tests are adequate
- [ ] Documentation is clear
- [ ] No obvious bugs
- [ ] Performance is acceptable
- [ ] Security considerations addressed
- [ ] Safety requirements met (if applicable)
- [ ] Error handling is appropriate
- [ ] Resource management is correct

### Review Workflow

```
Developer → Create PR → Automated Checks → Peer Review → Approval → Merge
                              ↓ fail              ↓ reject
                           Fix Issues          Address Feedback
```

**Automated Checks:**
- Build succeeds
- All tests pass
- Static analysis clean
- Code coverage adequate
- Commit messages follow convention

**Peer Review:**
- At least one approving review required
- Safety-critical code requires two reviews
- One reviewer must be familiar with the subsystem

### Review Guidelines

**For Reviewers:**
- Provide constructive feedback
- Focus on significant issues first
- Suggest improvements, don't demand perfection
- Approve when code meets standards
- Use [Conventional Comments](https://conventionalcomments.org/)

**For Authors:**
- Respond to all comments
- Explain your reasoning when disagreeing
- Fix issues promptly
- Update PR description as needed
- Re-request review after significant changes

## Testing Strategy

### Test Levels

#### Unit Tests

**Purpose:** Test individual functions/modules

**Characteristics:**
- Fast execution (< 100ms per test)
- No external dependencies
- Deterministic
- High coverage (> 90% for safety-critical)

**Example:**
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_velocity_limit_enforcement() {
        let mut controller = MotionController::new();
        let result = controller.set_velocity(MAX_VELOCITY + 1.0);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), MotionError::VelocityExceeded);
    }
}
```

#### Integration Tests

**Purpose:** Test component interactions

**Characteristics:**
- Test multiple modules together
- May use test doubles for external systems
- Test interfaces between components

#### System Tests

**Purpose:** Test complete system behavior

**Characteristics:**
- End-to-end testing
- Real or simulated hardware
- Test complete workflows

#### Hardware-in-the-Loop (HIL) Tests

**Purpose:** Test with actual hardware

**Characteristics:**
- Real hardware components
- Validate hardware interactions
- Performance validation
- Safety system validation

### Test Categories

#### Functional Tests

- Verify requirements are met
- Positive and negative test cases
- Boundary value testing
- Equivalence partitioning

#### Safety Tests

- Fault injection
- Emergency stop verification
- Watchdog testing
- Degraded mode testing
- Recovery testing

#### Performance Tests

- Latency measurements
- Throughput testing
- Resource utilization
- Real-time constraint validation

#### Security Tests

- Penetration testing
- Vulnerability scanning
- Fuzzing
- Authentication/authorization testing

### Continuous Testing

**On Every Commit:**
- Unit tests
- Static analysis
- Fast integration tests

**Nightly:**
- Full test suite
- Performance tests
- Extended integration tests

**Weekly:**
- HIL tests
- Security scans
- Long-running tests

### Test-Driven Development (TDD)

**Process:**
1. Write failing test
2. Implement minimal code to pass
3. Refactor
4. Repeat

**Benefits:**
- Better test coverage
- Cleaner interfaces
- Living documentation

## Static Analysis

### Tools

**Rust:**
- `cargo clippy` - Linting
- `cargo fmt` - Formatting
- `cargo audit` - Security vulnerabilities
- `cargo deny` - Dependency management

**Additional:**
- CodeQL - Security analysis
- SonarQube - Code quality

### Configuration

```toml
# Clippy configuration in Cargo.toml
[lints.clippy]
pedantic = "warn"
nursery = "warn"
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"
```

### Analysis Frequency

- **On save**: Format checking (IDE)
- **Pre-commit**: Linting, formatting
- **CI/CD**: Full static analysis
- **Weekly**: Deep analysis, security scans

## Continuous Integration / Continuous Deployment

See [CI/CD for Robotics](./ci_cd_robotics.md) for detailed information.

**CI Pipeline:**
```
Commit → Build → Unit Tests → Static Analysis → Integration Tests → Report
```

**CD Pipeline (for staging):**
```
CI Pass → Package → Sign → Deploy to Staging → Smoke Tests → Notify
```

**Production Deployment:**
- Manual approval required
- Phased rollout
- Automated rollback on failure

## Documentation Requirements

### Code Documentation

**Required for all public APIs:**
```rust
/// Controls the robot's motion system.
///
/// # Safety
///
/// This controller directly commands actuators. Incorrect usage can cause
/// unsafe robot motion. Always validate commands against safety limits.
///
/// # Examples
///
/// ```
/// let mut controller = MotionController::new();
/// controller.set_velocity(1.0)?;
/// ```
pub struct MotionController {
    // ...
}
```

### Architecture Documentation

- System architecture diagram
- Component diagrams
- Sequence diagrams for critical flows
- Interface specifications

### User Documentation

- Installation guide
- User manual
- API documentation
- Troubleshooting guide

## Configuration Management

### Version Control

**Branch Strategy:**
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature branches
- `hotfix/*`: Emergency fixes
- `release/*`: Release preparation

**Protected Branches:**
- `main`: Requires PR, reviews, CI pass
- `develop`: Requires PR, CI pass

### Commit Conventions

See [Git Conventions](../engineering/best_practices/git.md)

All commits must include:
- Conventional commit type
- SIL level declaration
- WHY section
- WHAT section

### Change Control Board

**For Major Changes:**
- Architecture changes
- Safety-critical modifications
- API breaking changes

**CCB Activities:**
- Review proposed change
- Assess impact
- Approve or reject
- Track implementation

## Quality Metrics

### Code Quality

| Metric | Target | Measurement |
|--------|--------|-------------|
| Test Coverage | > 80% overall, > 90% safety-critical | Automated |
| Static Analysis | 0 critical, < 5 high | Automated |
| Code Review | 100% before merge | Process |
| Documentation | 100% public APIs | Review |

### Process Quality

| Metric | Target | Measurement |
|--------|--------|-------------|
| Defect Density | < 0.5 defects/KLOC | Tracking system |
| Mean Time to Resolution | < 7 days (non-critical) | Tracking system |
| Code Review Time | < 24 hours | Tracking system |
| Build Success Rate | > 95% | CI logs |

### Predictive Metrics

| Metric | Purpose |
|--------|---------|
| Velocity | Sprint planning |
| Defect Trends | Quality prediction |
| Technical Debt | Maintenance planning |

## Risk Management

### Technical Risks

**Identify:**
- Architecture risks
- Technology risks
- Integration risks
- Performance risks

**Mitigate:**
- Proof of concepts
- Early prototypes
- Incremental integration
- Performance testing

### Safety Risks

See [Hazard Analysis](../safety_case/hazard_analysis_summary.md)

## Compliance and Audit

### Audit Artifacts

- Requirements traceability matrix
- Design documents
- Code review records
- Test results
- Static analysis reports
- Release documentation

### Audit Process

- Regular internal audits
- Pre-release audits
- External audits (as required)
- Post-incident audits

## Tools and Environment

See [Toolchain](./toolchain.md) for detailed tool information.

**Required Tools:**
- Git for version control
- Rust toolchain
- ROS/ROS2 (if applicable)
- CI/CD system
- Issue tracking system
- Documentation system

## Training and Onboarding

### Developer Onboarding

**Week 1:**
- Development process overview
- Toolchain setup
- Code reading
- Safety training

**Week 2-4:**
- Mentored development
- Pair programming
- Code reviews (as reviewer and author)

### Ongoing Training

- Safety training: Annual
- Security training: Annual
- Tool training: As needed
- Standards training: As needed

## References

- [Coding Rules](./coding_rules.md)
- [ROS Guidelines](./ros_guidelines.md)
- [CI/CD for Robotics](./ci_cd_robotics.md)
- [Toolchain](./toolchain.md)
- IEC 62304: Medical device software lifecycle
- ISO/IEC 12207: Software lifecycle processes

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Development Team | Initial development process |
