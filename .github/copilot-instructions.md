# MPF Robot Framework – GitHub Copilot Instructions

## Overview

This repository is the **parent template** for Modular Project Framework (MPF) specialized for **robotics projects** (with or without RTOS, ROS/ROS2 or other middleware).  
It is **not meant to contain business logic**. Its purpose is to:

1. Serve as a **starter kit** for industrial-grade robotics projects.
2. Provide **scripts, governance, and documentation** for industrial compliance.
3. Define a **clear project structure** following Clean Architecture.
4. Bootstrap **child module repositories** (template repos) for your project.

> Important: **Child template repos are NOT included in this repository.**  
> They are **initialized dynamically** via the `init-project.sh` script once you create a project from this parent template.

---

## Repo Structure

This repository contains:

- **`scripts/`**: Automation scripts for project initialization, environment parsing, confirmation prompts, and submodule setup.
- **`config/`**: Environment variables (`config.env`) and commit lint configuration.
- **`docs/`**: Documentation framework structured for **robotics safety, ISO/IEC compliance, and audit readiness**.
- **`tools/`**: CI/CD, quality, and release utilities.

---

## Workflow Overview

### Step 1 – Clone the parent template

```bash
gh repo create my-org/my-project --template mpf-robot-framework
git clone git@github.com:my-org/my-project.git
cd my-project
```

### Step 2 – Configure environment

```
config/config.env contains:

PROJECT_NAME=...
PROJECT_ORG=...
PROJECT_REPO=...
PROJECT_TYPE=robotics
USE_RTOS=true/false
MIDDLEWARE=ROS2/ROS1/NONE
LICENSE=Apache-2.0
DEFAULT_BRANCH=main
```
run validate-env.sh to check if gh is intalled and if we're connected

### Step 3 – Confirm configuration

The init-project.sh script will display all important environment variables.

You must confirm that the values are correct.

If confirmation fails, the script exits and asks you to edit config.env manually.

./scripts/init-project.sh

### Step 4 – Initialize child template repositories

The script will automatically create and configure the following child template repos as submodules:

| Submodule | Purpose |
|-----------|---------|
| domain | Core business logic / robot state / invariants |
| application |	Use cases, orchestration, workflows |
| infrastructure | ROS nodes, drivers, HIL interfaces, hardware integration |
| interfaces	CLI, REST API, HMI, diagnostics |
| shared	Logging, error model, safety utilities, configuration |

- Each child template is a separate GitHub repository.
- These submodules are linked automatically to your project repository, not stored inside the parent template.

### Step 5 – Commit message conventions

All commits must include a WHY + WHAT section.

Example:

```feat(motion_control): add emergency stop logic

WHY:
Robot may continue moving after sensor failure,
risking human collision.

WHAT:
- Added watchdog on motion controller
- Emergency stop triggered on timeout
- Updated degraded mode handling
```

Enforced via Git hook hooks/commit-msg and commitlint.

### Step 6 – Documentation compliance

```
docs/
├── README.md                        # Introduction générale, overview du repo
├── standards/
│   ├── applicable_standards.md      # Applicabilité globale, audit & norme
│   ├── standards_mapping.md         # Mapping standards / projet
│   └── deviations_and_justifications.md
├── cybersecurity/
│   ├── threat_model.md              # Menaces sur le robot / projet
│   ├── attack_surfaces.md
│   ├── secure_communication.md
│   ├── access_control.md
│   └── update_security.md
├── development/
│   ├── development_process.md       # Process global dev / CI / code review
│   ├── ros_guidelines.md            # Guidelines middleware (ROS/RTOS)
│   ├── coding_rules.md
│   ├── simulation_policy.md         # Politique simulation vs réel
│   ├── ci_cd_robotics.md
│   └── toolchain.md
├── change_management/
│   ├── change_impact_robot.md       # Politique global impact changes
│   ├── safety_reassessment.md
│   └── regression_policy.md
├── configuration_management/
│   ├── robot_configuration.md       # Scaffolding / naming convention
│   ├── calibration_management.md
│   ├── parameter_management.md
│   └── release_baselines.md
├── operations/
│   ├── deployment.md
│   ├── startup_shutdown.md
│   ├── maintenance.md
│   ├── incident_response.md
│   └── decommissioning.md
└── safety_case/
    ├── safety_case_overview.md      # Templates pour Safety Case
    ├── assumptions_and_scope.md
    ├── top_level_claims.md
    ├── hazard_analysis_summary.md
    ├── safety_arguments.md
    ├── gsn_textual.md
    ├── evidence_mapping.md
    └── known_limitations.md

```

- Each folder contains template README.md or placeholder files to be filled during development.

### Important Notes for Copilot Users

1. Do not attempt to write business logic in the parent repo; it is only orchestration + governance.

2. Child modules are independently versioned and follow the same Clean Architecture principles.

3. Copilot suggestions should respect audit and safety guidelines:

- Include WHY + WHAT in code comments and commits
- Always check ROS node interactions and RTOS constraints
- Avoid creating hidden side-effects
4. Scripts will enforce industrial-grade reproducibility, including:

- Submodule initialization
- Git hooks
- CI/CD templates

## Engineering Principles

### YAGNI (You Aren’t Gonna Need It)

- Do not implement features without a validated requirement
- Every feature must be traceable to a requirement ID
- Future-proofing is forbidden in safety-critical code
- No speculative abstractions

### KISS – Keep It Simple, Stupid

**Principle:**

Always prioritize simplicity and readability. Avoid unnecessary abstraction or hidden logic (“magic”).

**Practical Rules:**

- Each function should do one simple thing.
- Traits and interfaces should be simple and explicit.
- Avoid:
    - Dynamic factories
    - Complex dependency injection containers
    - Async/futures in safety-critical paths
- Any complex code must be justified and clearly commented.

**Example (Rust):**
```rust
// Bad: unnecessary nested abstractions
trait MotionExecutor { fn run(&self, cmd: MotionCmd); }
struct SafeMotionWrapper<T: MotionExecutor> { inner: T }
impl<T: MotionExecutor> MotionExecutor for SafeMotionWrapper { ... }

// Good: simple and explicit
fn execute_motion(cmd: MotionCmd) -> Result<(), MotionError> { ... }
```

### Fail-Fast / Fail-Safe

**Principle:**

- Fail-Fast: detect errors as soon as they occur.
- Fail-Safe: ensure the system remains in a safe state under any failure.

**Practical Rules:**

- Never ignore a Result or error.
- On critical error:
    - Enter degraded mode or trigger Emergency Stop.
    - Log errors only outside of ISR context.
- Always provide a safe fallback.

**Example:**
```rust
fn control_motion(cmd: MotionCmd) -> Result<(), MotionError> {
    cmd.validate_limits(&actuator_limits)?;
    if !safety_context.is_safe_to_move() {
        enter_degraded_mode();
        return Err(MotionError::UnsafeCondition);
    }
    execute_with_watchdog(cmd, MOTION_TIMEOUT_MS)
}
```

### Design by Contract (DbC)

**Principle:**
Each module, function, or method must have clear contracts:

- Preconditions
- Postconditions
- Invariants

**Practical Rules:**

- Validate all inputs.
- Enforce limits (e.g., ActuatorLimits).
- Clearly define expected state before and after execution.

**Example:**

```rust
fn set_velocity(velocity: f32) -> Result<(), MotionError> {
    ensure!(velocity <= MAX_VELOCITY, MotionError::OutOfBounds);
    actuator.set_velocity(velocity)?;
    Ok(())
}
```

### SOLID

**Principle:** Follow the 5 SOLID principles for maintainable and safe code.

| Principle	| Application for Rust / SIL3|
|-----------|----------------------------|
| S Single Responsibility | Each module/function has only one responsibility. E.g., SafetyService should not do network logging. |
| O Open/Closed	| Open for extension but closed for modification. Use traits to extend behavior. |
| L Liskov Substitution	| Any trait/type implementation can be replaced without breaking contracts. |
| I Interface Segregation | Avoid “fat” traits. Prefer small, specific traits. |
| D Dependency Inversion | Depend on traits/abstractions, not concrete modules (Domain and Application layers only). |

**Example (Rust – SRP & DIP):**

```rust
trait ActuatorRepository { fn read_position(&self, id: ActuatorId) -> Position; }

struct MotionService<R: ActuatorRepository> { repo: R }

impl<R: ActuatorRepository> MotionService<R> {
    fn control(&self) { ... }
}
```

## Copilot-Specific Zephyr Rules
- Never suggest direct Zephyr API usage outside Infrastructure layer
- Never introduce dynamic memory allocation in safety-critical code
- Never suggest blocking calls in ISR or safety threads
- Always assume preemptive scheduling and concurrency
- Always include stack size considerations when defining new threads


## SIL 3 Zephyr/Rust Enforcement Checklist (Copilot Mandatory Rules)

The following checklist defines **non-negotiable SIL 3 constraints**.
Copilot MUST comply with these rules when generating, modifying, or reviewing code.

---

### 1. Architecture & Layering (MANDATORY)

- Never introduce Zephyr APIs outside the **Infrastructure layer**
- Never allow Domain or Application layers to:
  - Depend on Zephyr headers
  - Depend on RTOS concepts (threads, mutexes, timers)
- All RTOS interactions must be abstracted via traits/interfaces
- ISR handlers must never contain business logic

---

### 2. Rust Safety Rules (MANDATORY)

- `unsafe` is **FORBIDDEN by default**
- `unsafe` is allowed ONLY if:
  - Located in Infrastructure layer
  - Surrounded by `// SAFETY:` comments
  - Justified by a requirement reference (e.g. `REQ-SAF-012`)
- Never generate:
  - `unwrap()`
  - `expect()`
  - `panic!`
- Never rely on implicit integer conversions
- Always use strong typing (newtypes, enums) for safety-related values

---

### 3. Memory Management (SIL 3)

- No dynamic allocation after system initialization
- No heap usage in safety-critical paths
- Prefer:
  - Stack allocation
  - `heapless` containers
  - Static buffers
- Explicitly size all Zephyr thread stacks
- Never create kernel objects dynamically at runtime

---

### 4. Concurrency & Scheduling (CRITICAL)

- Assume preemptive scheduling at all times
- Always consider race conditions and reentrancy
- Safety-critical threads must:
  - Have higher priority than functional threads
  - Never block indefinitely
  - Never sleep
- Priority inversion must be prevented (priority inheritance required)
- Shared data must be protected with:
  - Lock-free structures OR
  - Bounded-time mutexes

---

### 5. ISR Rules (HARD LIMITS)

- ISR code must:
  - Be minimal
  - Execute in bounded and deterministic time
- Forbidden in ISR context:
  - Blocking calls
  - Logging
  - Heap allocation
  - Mutex locking
- ISR must only:
  - Capture data
  - Signal events
  - Defer processing to threads or workqueues

---

### 6. Timing & Determinism (SIL 3)

- No unbounded loops
- No recursion in safety-related code
- All timeouts must be explicit and bounded
- Control loops must:
  - Execute in dedicated high-priority threads
  - Respect < 1ms latency constraints
- Worst-case execution time (WCET) must be estimable

---

### 7. Watchdog & Supervision

- External hardware watchdog is mandatory for safety
- Zephyr watchdog is allowed only as secondary supervision
- Watchdog refresh must:
  - Be performed only by healthy system state
  - Fail-safe on missed deadlines
- Watchdog logic must be testable and injectable

---

### 8. Error Handling & Degraded Modes

- All errors must be explicitly handled
- Never ignore `Result` or `Option`
- On error:
  - Log (outside ISR only)
  - Enter degraded or safe state
- Safety violations must:
  - Trigger Emergency Stop
  - Be reported via diagnostic channel
- Silent failures are forbidden

---

### 9. Diagnostics & Traceability

- All safety-related logic must reference a requirement ID:
  - Example: `REQ-SAF-001`, `REQ-MCU-004`
- Safety decisions must be traceable and logged
- Diagnostic Trouble Codes (DTC) must be deterministic
- Diagnostic communication must not interfere with control loops

---

### 10. Testing & Validation (NON-OPTIONAL)

- All safety-critical paths require 100% coverage
- Tests must include:
  - Fault injection
  - Communication loss
  - Watchdog timeout
  - Task starvation
  - Priority inversion scenarios
- RTOS-related behavior must be tested:
  - Scheduling
  - Latency
  - Thread preemption

---

### 11. Forbidden Patterns (ABSOLUTE)

Copilot MUST NEVER generate:
- Busy waiting
- Dynamic thread creation
- Dynamic memory allocation in runtime
- Blocking calls in safety threads
- Logging in ISR
- Shared mutable state without protection
- Hidden side effects in constructors

---

### 12. Copilot Self-Check (REQUIRED)

Before proposing any code, Copilot must implicitly verify:
1. Does this impact safety?
2. Does this violate RTOS determinism?
3. Is memory usage bounded?
4. Is scheduling behavior explicit?
5. Is the failure mode safe?

If any answer is unclear → DO NOT PROPOSE CODE.

## Commit Message Content Rules (Copilot Mandatory)

- All commits MUST include a structured commit message body
- The `Why:` section is mandatory for ALL commits, including SIL0
- Copilot MUST always explain the motivation behind a change
- Vague or generic explanations are forbidden

For SIL2 and SIL3 commits:
- Safety Impact and Requirements sections are mandatory
- SIL3 commits MUST include a Failure Mode description

## SIL-Aware Commit Rules

- All commits MUST declare a SIL level `[SILx]`
- `[SIL0]` is mandatory for non-safety changes
- `[SIL2]` and `[SIL3]` commits MUST include:
  - Extended description
  - Safety impact summary
  - Requirement references
- Copilot MUST refuse to generate SIL3 commit messages without requirement IDs