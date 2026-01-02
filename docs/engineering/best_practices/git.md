# Git Conventions

This document describes the Git commit message conventions and workflow practices for the Modular Project Framework (MPF).

## Commit Message Format

All commits must follow a structured format including **WHY** + **WHAT** sections:

### Structure

```
<type>(<scope>): <subject>

WHY:
<explanation of why this change is necessary>

WHAT:
- <list of changes made>
- <specific modifications>
- <updated components>
```

### Example

```
feat(motion_control): add emergency stop logic

WHY:
Robot may continue moving after sensor failure,
risking human collision.

WHAT:
- Added watchdog on motion controller
- Emergency stop triggered on timeout
- Updated degraded mode handling
```

## Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code refactoring without changing behavior
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependency updates
- `ci`: CI/CD configuration changes
- `build`: Build system or external dependency changes

## Safety Integrity Levels (SIL)

All commits must declare a SIL level in the commit message:

### SIL Levels

- **`[SIL0]`**: Non-safety changes
  - Documentation updates
  - Build configuration
  - Non-functional improvements
  - No impact on runtime behavior

- **`[SIL2]`**: Safety-related changes
  - Requires extended description
  - Must include safety impact assessment
  - Must reference requirement IDs
  - Example: Changes to control logic, sensor processing

- **`[SIL3]`**: Critical safety changes
  - Requires failure mode description
  - Must reference requirement IDs
  - Must include verification plan
  - Example: Emergency stop logic, safety interlocks

### SIL2 Example

```
[SIL2] fix(sensor): correct IMU calibration offset

WHY:
IMU calibration was using incorrect offset causing 2-degree error
in pitch estimation. REQ-SAF-042 mandates <1 degree accuracy.

WHAT:
- Updated calibration offset from 0.05 to 0.02
- Added unit test verifying accuracy requirement
- Updated calibration procedure documentation

SAFETY IMPACT:
Incorrect pitch estimation could cause robot to misjudge terrain
slope, leading to potential tip-over in edge cases.

REQUIREMENTS: REQ-SAF-042, REQ-SEN-015
```

### SIL3 Example

```
[SIL3] feat(safety): implement emergency stop watchdog

WHY:
System must detect and respond to control loop failures within 100ms
to prevent unsafe robot motion. REQ-SAF-001 (critical requirement).

WHAT:
- Added hardware watchdog timer on safety controller
- Implemented software heartbeat from control loop
- Triggers emergency stop on missed heartbeat
- Added diagnostic reporting for watchdog events

SAFETY IMPACT:
Prevents uncontrolled robot motion in case of software crash or
deadlock. Critical for human safety in collaborative workspace.

FAILURE MODE:
False positives would cause unnecessary emergency stops. Mitigated
by 3-heartbeat tolerance and diagnostic logging.

REQUIREMENTS: REQ-SAF-001, REQ-SAF-003, REQ-CTRL-008
VERIFICATION: TEST-SAF-001, TEST-SAF-002
```

## Enforcement

These conventions are enforced via:

- **Git hooks**: Pre-commit and commit-msg hooks validate format
- **commitlint**: Automated linting of commit messages
- **CI/CD**: Pull requests are blocked if commits don't follow conventions

## Best Practices

### Atomic Commits
- Each commit should represent a single logical change
- Avoid mixing multiple unrelated changes in one commit
- Makes code review easier and simplifies rollback if needed

### Meaningful Commit Messages
- Subject line should be concise but descriptive
- WHY section explains the motivation, not just what changed
- WHAT section lists specific changes for reviewability

### Reference Issues
- Link to issue numbers when applicable: `Fixes #123`
- Reference requirement IDs for traceability
- Include relevant test IDs for verification

### Commit History
- Keep commit history clean and meaningful
- Avoid "WIP" or "fix typo" commits in main branches
- Squash related commits when merging if appropriate

## Workflow

### Feature Branch Workflow
1. Create feature branch from `main`
2. Make atomic commits following conventions
3. Open pull request with descriptive title and description
4. Address review feedback in additional commits
5. Squash if needed before merging to `main`

### Pull Request Requirements
- All commits must follow SIL conventions
- PR description must explain overall change
- CI checks must pass
- Code review approval required
- No direct commits to `main` branch
