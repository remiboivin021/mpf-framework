# Engineering Principles

This document outlines the core engineering principles that guide development in the Modular Project Framework (MPF).

## YAGNI (You Aren't Gonna Need It)

**Principle:**

Do not implement features or abstractions that are not immediately needed.

**Practical Rules:**

- Do not implement features without a validated requirement
- Every feature must be traceable to a requirement ID
- Future-proofing is forbidden in safety-critical code
- No speculative abstractions

**Example (Rust):**
```rust
// Bad: over-engineered for future needs
trait DataSource<T> { fn fetch(&self) -> Result<T, Error>; }
struct ConfigSource<T> { source: Box<dyn DataSource<T>> }

// Good: simple implementation for current need
struct Config { pub max_speed: f32 }
impl Config {
    fn load() -> Result<Self, Error> { ... }
}
```

## KISS – Keep It Simple, Stupid

**Principle:**

Always prioritize simplicity and readability. Avoid unnecessary abstraction or hidden logic ("magic").

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

## Fail-Fast / Fail-Safe

**Principle:**

- Fail-Fast: detect errors as soon as they occur.
- Fail-Safe: ensure the system remains in a safe state under any failure.

**Practical Rules:**

- Never ignore a Result or error.
- On critical error:
    - Enter degraded mode or trigger Emergency Stop.
    - Log errors only outside of ISR context.
- Always provide a safe fallback.

**Example (Rust):**
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

## Design by Contract (DbC)

**Principle:**

Each module, function, or method must have clear contracts:

- Preconditions
- Postconditions
- Invariants

**Practical Rules:**

- Validate all inputs.
- Enforce limits (e.g., ActuatorLimits).
- Clearly define expected state before and after execution.

**Example (Rust):**

```rust
fn set_velocity(velocity: f32) -> Result<(), MotionError> {
    ensure!(velocity <= MAX_VELOCITY, MotionError::OutOfBounds);
    actuator.set_velocity(velocity)?;
    Ok(())
}
```

## SOLID

**Principle:** Follow the 5 SOLID principles for maintainable and safe code.

| Principle | Application for Rust / SIL3 |
|-----------|----------------------------|
| S Single Responsibility | Each module/function has only one responsibility. E.g., SafetyService should not do network logging. |
| O Open/Closed | Open for extension but closed for modification. Use traits to extend behavior. |
| L Liskov Substitution | Any trait/type implementation can be replaced without breaking contracts. |
| I Interface Segregation | Avoid "fat" traits. Prefer small, specific traits. |
| D Dependency Inversion | Depend on traits/abstractions, not concrete modules (Domain and Application layers only). |

**Example (Rust – SRP & DIP):**

```rust
trait ActuatorRepository { fn read_position(&self, id: ActuatorId) -> Position; }

struct MotionService<R: ActuatorRepository> { repo: R }

impl<R: ActuatorRepository> MotionService<R> {
    fn control(&self) { ... }
}
```

## Additional Guidelines

### For Safety-Critical Code
- Minimize state mutations
- Avoid hidden side effects
- Make all dependencies explicit
- Document all assumptions
- Use strong typing to prevent errors at compile time

### For Real-Time Systems
- Avoid unbounded loops
- Avoid recursion in safety-related code
- All timeouts must be explicit and bounded
- Consider worst-case execution time (WCET)

### For Embedded/RTOS Systems
- No dynamic memory allocation after initialization
- Stack usage must be bounded and analyzed
- ISR code must be minimal and deterministic
- Priority inversion must be prevented
