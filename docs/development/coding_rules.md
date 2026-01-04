# Coding Rules

## Purpose

This document defines coding standards and best practices for robotics projects built with MPF. These rules ensure code quality, safety, maintainability, and compliance with industrial standards.

## General Principles

1. **Safety First**: Safety requirements take precedence over all other concerns
2. **Simplicity**: Keep code simple and readable (KISS principle)
3. **Explicitness**: Make behavior explicit, avoid hidden logic
4. **Fail-Safe**: Design for safe failure modes
5. **Traceability**: Link code to requirements

## Rust-Specific Rules

### Forbidden Constructs

**NEVER use in production code:**

```rust
// Forbidden: unwrap()
let value = option.unwrap();  // ❌

// Correct: explicit error handling
let value = option.ok_or(Error::MissingValue)?;  // ✅

// Forbidden: expect()
let value = result.expect("this should never fail");  // ❌

// Correct: proper error handling
let value = result?;  // ✅

// Forbidden: panic!
if condition {
    panic!("something went wrong");  // ❌
}

// Correct: return error
if condition {
    return Err(Error::InvalidCondition);  // ✅
}
```

### Unsafe Code

**`unsafe` is forbidden except:**
- In Infrastructure layer only
- With explicit safety documentation
- With requirement traceability

```rust
// Acceptable unsafe with documentation
/// # Safety
///
/// This function is safe to call when:
/// - `ptr` is non-null
/// - `ptr` points to valid memory
/// - Memory at `ptr` is properly aligned for type T
///
/// Requirement: REQ-INF-042
unsafe fn read_hardware_register<T>(ptr: *const T) -> T {
    // SAFETY: Caller guarantees ptr validity per function contract
    std::ptr::read_volatile(ptr)
}
```

### Error Handling

**All errors must be handled explicitly:**

```rust
// Define error types
#[derive(Debug, thiserror::Error)]
pub enum MotionError {
    #[error("velocity {0} exceeds limit {1}")]
    VelocityExceeded(f32, f32),
    
    #[error("actuator {0} not responding")]
    ActuatorTimeout(ActuatorId),
    
    #[error("safety interlock active")]
    SafetyInterlock,
}

// Use Result for fallible operations
pub fn set_velocity(velocity: f32) -> Result<(), MotionError> {
    if velocity > MAX_VELOCITY {
        return Err(MotionError::VelocityExceeded(velocity, MAX_VELOCITY));
    }
    
    actuator.set_velocity(velocity)?;
    Ok(())
}
```

### Memory Management

**No dynamic allocation in safety-critical paths:**

```rust
// Use heapless for bounded collections
use heapless::Vec;

struct SafetyController {
    // Fixed-size buffer, no heap allocation
    sensor_buffer: Vec<SensorReading, 10>,
}

// For non-safety-critical code, heap is allowed
struct DataLogger {
    log_entries: std::vec::Vec<LogEntry>,  // OK in Infrastructure layer
}
```

### Type Safety

**Use strong typing:**

```rust
// Bad: primitive obsession
fn set_velocity(velocity: f32) -> Result<(), Error> {
    // What are the units? m/s? km/h?
}

// Good: newtype pattern
#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
pub struct Velocity(f32);  // Always in m/s

impl Velocity {
    pub fn from_mps(mps: f32) -> Result<Self, Error> {
        if mps < 0.0 || mps > MAX_VELOCITY_MPS {
            return Err(Error::OutOfBounds);
        }
        Ok(Velocity(mps))
    }
    
    pub fn as_mps(&self) -> f32 {
        self.0
    }
}

fn set_velocity(velocity: Velocity) -> Result<(), Error> {
    // Now units are clear
}
```

### Concurrency

**Thread safety must be explicit:**

```rust
use std::sync::{Arc, Mutex};

// Document thread safety
/// Thread-safe sensor registry.
/// Can be safely shared across threads.
pub struct SensorRegistry {
    sensors: Arc<Mutex<HashMap<SensorId, Sensor>>>,
}

impl SensorRegistry {
    pub fn register(&self, id: SensorId, sensor: Sensor) -> Result<(), Error> {
        let mut sensors = self.sensors
            .lock()
            .map_err(|_| Error::LockPoisoned)?;
        sensors.insert(id, sensor);
        Ok(())
    }
}
```

## Naming Conventions

### General Rules

- Use descriptive names
- Avoid abbreviations (except well-known ones)
- Be consistent across codebase

### Rust Naming

```rust
// Types: UpperCamelCase
struct MotionController { }
enum SafetyState { }
trait Actuator { }

// Functions and methods: snake_case
fn calculate_velocity() { }
fn set_position() { }

// Constants: SCREAMING_SNAKE_CASE
const MAX_VELOCITY: f32 = 5.0;
const DEFAULT_TIMEOUT_MS: u64 = 1000;

// Modules: snake_case
mod motion_control;
mod sensor_fusion;

// Lifetimes: short, descriptive
fn process<'a, 'buf>(data: &'a Data, buffer: &'buf mut Buffer) { }
```

## Code Organization

### Module Structure

```rust
// src/motion_control/mod.rs
pub mod controller;
pub mod kinematics;
pub mod trajectory;

// Re-export public API
pub use controller::MotionController;
pub use trajectory::Trajectory;

// Keep internal details private
mod internal_utils;
```

### File Size

- **Maximum**: 500 lines per file
- **Recommended**: < 300 lines
- **Split when**: File has multiple responsibilities

## Documentation

### Required Documentation

**All public items must be documented:**

```rust
/// Controls robot motion within safety limits.
///
/// # Safety
///
/// This controller enforces velocity and acceleration limits.
/// Emergency stop can be triggered at any time via `emergency_stop()`.
///
/// # Examples
///
/// ```
/// let mut controller = MotionController::new(config)?;
/// controller.set_velocity(Velocity::from_mps(1.0)?)?;
/// ```
///
/// # Requirements
///
/// - REQ-MOT-001: Enforce velocity limits
/// - REQ-SAF-005: Emergency stop within 100ms
pub struct MotionController {
    // ...
}
```

### Safety Documentation

**Safety-critical code requires extra documentation:**

```rust
/// # Safety Requirements
///
/// - REQ-SAF-012: Watchdog must be refreshed every 50ms
/// - REQ-SAF-013: Failure to refresh triggers emergency stop
///
/// # Failure Modes
///
/// - Watchdog timeout: Triggers emergency stop
/// - Hardware watchdog fault: Resets system
///
/// # Verification
///
/// - TEST-SAF-012: Verify watchdog timing
/// - TEST-SAF-013: Verify emergency stop trigger
fn refresh_watchdog() {
    // Implementation
}
```

## Comments

### When to Comment

**Comment WHY, not WHAT:**

```rust
// Bad: explains what (obvious from code)
// Increment counter
counter += 1;

// Good: explains why
// Keep track of consecutive failures for fault detection
consecutive_failures += 1;
```

### Safety Comments

**Safety-critical sections need comments:**

```rust
// SAFETY: Emergency stop must disable all actuators atomically
// to prevent partial motion during stop sequence. This is enforced
// by the hardware safety circuit. See REQ-SAF-003.
unsafe {
    write_hardware_register(EMERGENCY_STOP_REGISTER, 0xFF);
}
```

## Testing

### Test Coverage

- **Unit tests**: > 80% coverage
- **Safety-critical code**: > 90% coverage
- **Integration tests**: All major workflows

### Test Organization

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_velocity_limit_enforcement() {
        // Arrange
        let controller = MotionController::new_for_test();
        
        // Act
        let result = controller.set_velocity(Velocity::from_mps(100.0).unwrap());
        
        // Assert
        assert!(result.is_err());
        assert!(matches!(result, Err(MotionError::VelocityExceeded(_, _))));
    }
    
    #[test]
    fn test_emergency_stop() {
        // Test emergency stop functionality
        // REQ-SAF-005
    }
}
```

## Performance

### Optimization Guidelines

1. **Measure first**: Don't optimize without profiling
2. **Hot paths**: Optimize only critical paths
3. **Clarity first**: Prefer clear code over clever code
4. **Document tradeoffs**: Explain performance-related decisions

### Real-Time Constraints

```rust
/// Executes control loop with strict timing requirements.
///
/// # Timing
///
/// This function must complete in < 1ms (measured WCET: 0.8ms).
/// Exceeding this deadline may cause control instability.
///
/// # Requirement: REQ-CTRL-008
fn control_loop_iteration() -> Result<(), ControlError> {
    // Time-critical code only
}
```

## Security

### Input Validation

**Validate all external inputs:**

```rust
pub fn set_target_position(position: Position) -> Result<(), Error> {
    // Validate input
    if !position.is_within_workspace() {
        return Err(Error::PositionOutOfWorkspace);
    }
    
    // Check for NaN/Inf
    if !position.is_finite() {
        return Err(Error::InvalidPosition);
    }
    
    // Proceed with validated input
    internal_set_position(position)
}
```

### Secrets Management

**Never hardcode secrets:**

```rust
// Bad
const API_KEY: &str = "secret123";  // ❌

// Good
fn get_api_key() -> Result<String, Error> {
    std::env::var("API_KEY")
        .map_err(|_| Error::MissingApiKey)  // ✅
}
```

## Formatting

### Use rustfmt

```toml
# rustfmt.toml
max_width = 100
tab_spaces = 4
edition = "2021"
```

**Run before every commit:**
```bash
cargo fmt --all
```

### Code Layout

```rust
// Order of items in a module
// 1. Use statements
use std::collections::HashMap;
use crate::types::*;

// 2. Constants
const MAX_RETRIES: u32 = 3;

// 3. Type definitions
pub struct Controller { }
pub enum State { }

// 4. Trait implementations
impl Controller { }

// 5. Private functions
fn internal_helper() { }

// 6. Tests
#[cfg(test)]
mod tests { }
```

## Linting

### Clippy Configuration

```toml
# Cargo.toml
[lints.clippy]
# Deny unsafe patterns
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"
todo = "deny"

# Warn on complexity
cognitive_complexity = "warn"
too_many_arguments = "warn"

# Enable pedantic checks
pedantic = "warn"
```

**Run regularly:**
```bash
cargo clippy --all-targets --all-features -- -D warnings
```

## Review Checklist

Before submitting code for review:

- [ ] All tests pass
- [ ] Code formatted with `rustfmt`
- [ ] No clippy warnings
- [ ] Documentation complete
- [ ] Safety requirements documented
- [ ] Error handling explicit
- [ ] No `unwrap()`, `expect()`, `panic!()`
- [ ] Performance acceptable
- [ ] Security considered
- [ ] Requirements traceability included

## Language-Specific Guidelines

### Rust Safety Guidelines

Based on MISRA-C adapted for Rust:

1. Avoid `unsafe` when possible
2. No raw pointers in safe interfaces
3. Bounds checking enabled
4. Integer overflow checks in debug/release
5. No uninitialized variables
6. Explicit error propagation

### When Using C/C++ (FFI)

```rust
// Wrap unsafe FFI in safe Rust interface
mod ffi {
    extern "C" {
        fn hardware_read(addr: u32) -> u32;
    }
}

// Safe wrapper
pub fn read_sensor() -> Result<u32, Error> {
    // SAFETY: Address is valid hardware register per datasheet
    // Requirement: REQ-HW-015
    let value = unsafe { ffi::hardware_read(SENSOR_ADDR) };
    
    // Validate reading
    if value == SENSOR_ERROR_CODE {
        return Err(Error::SensorFault);
    }
    
    Ok(value)
}
```

## References

- [Engineering Principles](../engineering/best_practices/concepts.md)
- [Development Process](./development_process.md)
- Rust API Guidelines: https://rust-lang.github.io/api-guidelines/
- MISRA C Guidelines (adapted for Rust)

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Development Team | Initial coding rules |
