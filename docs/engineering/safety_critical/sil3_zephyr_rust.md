# SIL3 Zephyr/Rust Enforcement Rules

## Purpose

This document defines mandatory enforcement rules for Safety Integrity Level 3 (SIL3) development using Zephyr RTOS and Rust. These rules are **NON-NEGOTIABLE** and must be followed for all safety-critical code.

## Architecture & Layering (MANDATORY)

### Layer Isolation Rules

**MUST NOT:**
- Introduce Zephyr APIs outside Infrastructure layer
- Allow Domain or Application layers to depend on Zephyr headers
- Allow Domain or Application layers to depend on RTOS concepts (threads, mutexes, timers)
- Place business logic in ISR handlers

**MUST:**
- Abstract all RTOS interactions via traits/interfaces
- Keep Zephyr isolated to Infrastructure layer only
- Use dependency inversion at layer boundaries

### Example: Correct Layer Isolation

```rust
// Domain layer - NO Zephyr dependencies
pub trait TimeProvider {
    fn now(&self) -> Timestamp;
}

// Infrastructure layer - Zephyr implementation
use zephyr_sys::k_uptime_get;

struct ZephyrTimeProvider;
impl TimeProvider for ZephyrTimeProvider {
    fn now(&self) -> Timestamp {
        // SAFETY: k_uptime_get is safe to call from any context
        // Requirement: REQ-INF-TIME-001
        Timestamp::from_ms(unsafe { k_uptime_get() })
    }
}
```

## Rust Safety Rules (MANDATORY)

### Forbidden Constructs

**FORBIDDEN by default:**
```rust
// ❌ NEVER use these in production code
value.unwrap()
value.expect("message")
panic!("error")
unreachable!()
unimplemented!()
```

### Unsafe Code Rules

**`unsafe` is FORBIDDEN except:**
1. Located in Infrastructure layer ONLY
2. Surrounded by `// SAFETY:` comments explaining why it's safe
3. Justified by a requirement reference (e.g., REQ-SAF-012)

```rust
// ✅ Acceptable unsafe usage
/// Reads hardware register for safety watchdog
///
/// # Safety
///
/// This is safe because:
/// - Register address is valid per hardware datasheet (0x40000100)
/// - Read access has no side effects
/// - Register is always readable
///
/// Requirement: REQ-SAFE-WD-001
pub fn read_watchdog_status() -> u32 {
    const WATCHDOG_STATUS_REG: *const u32 = 0x40000100 as *const u32;
    
    // SAFETY: See function documentation
    unsafe { std::ptr::read_volatile(WATCHDOG_STATUS_REG) }
}
```

### Integer Safety

**MUST:**
- Use explicit integer conversions
- Check for overflow/underflow
- Use appropriate integer types

```rust
// ❌ Bad: implicit conversion
fn bad_conversion(value: u32) -> u16 {
    value as u16  // May truncate!
}

// ✅ Good: explicit checked conversion
fn good_conversion(value: u32) -> Result<u16, ConversionError> {
    u16::try_from(value)
        .map_err(|_| ConversionError::Overflow)
}
```

## Memory Management (SIL3)

### No Dynamic Allocation in Safety Paths

**FORBIDDEN in safety-critical code:**
- Heap allocation after initialization
- `Vec`, `String`, `Box` in runtime safety code
- Dynamic sizing

**REQUIRED:**
- Stack allocation only
- Fixed-size buffers (`heapless` crate)
- Static allocation

```rust
use heapless::Vec;

// ✅ Fixed-size, no heap allocation
struct SafetyController {
    sensor_readings: Vec<SensorReading, 16>,  // Max 16 readings
}

// ❌ Heap allocation - NOT allowed in safety code
struct UnsafeController {
    sensor_readings: std::vec::Vec<SensorReading>,  // Uses heap!
}
```

### Stack Size

**MUST:**
- Explicitly size all Zephyr thread stacks
- Analyze worst-case stack usage
- Add margin for safety (e.g., 2x measured usage)

```c
// Zephyr thread definition
#define SAFETY_THREAD_STACK_SIZE 2048
K_THREAD_STACK_DEFINE(safety_stack, SAFETY_THREAD_STACK_SIZE);
```

## Concurrency & Scheduling (CRITICAL)

### Threading Assumptions

**MUST assume:**
- Preemptive scheduling at all times
- Race conditions can occur
- Reentrancy issues possible

**MUST NOT assume:**
- Sequential execution
- Atomic operations without explicit synchronization

### Safety Thread Requirements

**Safety-critical threads MUST:**
- Have higher priority than functional threads
- NEVER block indefinitely
- NEVER sleep
- Complete in bounded time

```rust
// ✅ Correct: Non-blocking safety check
fn safety_check() -> SafetyStatus {
    let status = read_safety_sensors();
    validate_safety_conditions(status)
    // Returns immediately
}

// ❌ Wrong: Blocking in safety thread
fn wrong_safety_check() -> SafetyStatus {
    thread::sleep(Duration::from_millis(100));  // FORBIDDEN!
    // ...
}
```

### Shared Data Protection

**MUST:**
- Protect shared data with synchronization primitives
- Use lock-free structures OR bounded-time mutexes
- Prevent priority inversion

```rust
use core::sync::atomic::{AtomicBool, Ordering};

// ✅ Lock-free for safety-critical flag
struct SafetySystem {
    emergency_stop: AtomicBool,
}

impl SafetySystem {
    pub fn trigger_emergency_stop(&self) {
        self.emergency_stop.store(true, Ordering::Release);
    }
    
    pub fn is_emergency_stop_active(&self) -> bool {
        self.emergency_stop.load(Ordering::Acquire)
    }
}
```

## ISR Rules (HARD LIMITS)

### ISR Code Requirements

**ISR code MUST:**
- Be minimal (< 10 lines ideal)
- Execute in deterministic time
- Be bounded and analyzable

**ISR code MUST NOT:**
- Block
- Log (logging is expensive)
- Allocate memory
- Lock mutexes
- Call complex functions

```rust
// ✅ Correct ISR: minimal, fast, deterministic
#[interrupt]
fn safety_isr() {
    // Quick: Just set flag and exit
    SAFETY_EVENT_FLAG.store(true, Ordering::Release);
}

// ❌ Wrong ISR: too complex
#[interrupt]
fn wrong_isr() {
    log::info!("ISR triggered");  // Logging in ISR!
    mutex.lock();  // Locking in ISR!
    process_data();  // Complex processing in ISR!
}
```

### ISR to Thread Communication

**MUST use:**
- Flags/atomics for simple signaling
- Lock-free queues for data passing
- Zephyr workqueues for deferred work

```rust
// ✅ ISR signals thread via atomic flag
static SENSOR_READY: AtomicBool = AtomicBool::new(false);

#[interrupt]
fn sensor_isr() {
    SENSOR_READY.store(true, Ordering::Release);
}

// Processing thread
fn sensor_thread() {
    loop {
        if SENSOR_READY.swap(false, Ordering::Acquire) {
            process_sensor_data();  // Heavy work in thread, not ISR
        }
        yield_cpu();
    }
}
```

## Timing & Determinism (SIL3)

### Timing Requirements

**FORBIDDEN:**
- Unbounded loops
- Recursion in safety-related code
- Operations without timeout

**REQUIRED:**
- All timeouts explicit and bounded
- WCET (Worst-Case Execution Time) estimable
- Control loops < 1ms latency

```rust
// ❌ Unbounded loop
fn bad_wait() {
    while !condition_met() {
        // Could wait forever!
    }
}

// ✅ Bounded loop with timeout
fn good_wait(timeout: Duration) -> Result<(), TimeoutError> {
    let start = Instant::now();
    let max_iterations = 1000;
    let mut iterations = 0;
    
    while !condition_met() {
        if start.elapsed() > timeout || iterations >= max_iterations {
            return Err(TimeoutError);
        }
        iterations += 1;
        yield_cpu();
    }
    Ok(())
}
```

## Watchdog & Supervision

### Hardware Watchdog (MANDATORY)

**MUST:**
- Use external hardware watchdog for safety
- Zephyr watchdog is secondary only
- Refresh ONLY when system is healthy

```rust
pub struct WatchdogManager {
    last_refresh: Instant,
}

impl WatchdogManager {
    /// Refresh watchdog only if system is healthy
    ///
    /// Requirement: REQ-SAF-WD-002
    pub fn refresh_if_healthy(&mut self) -> Result<(), WatchdogError> {
        // Check system health
        if !self.system_healthy() {
            // Don't refresh - let watchdog trigger reset
            return Err(WatchdogError::SystemUnhealthy);
        }
        
        // Refresh hardware watchdog
        self.refresh_hardware_watchdog();
        self.last_refresh = Instant::now();
        Ok(())
    }
    
    fn system_healthy(&self) -> bool {
        // Verify all safety checks pass
        safety_checks_pass() && 
        control_loop_responsive() &&
        sensors_operational()
    }
}
```

## Error Handling & Degraded Modes

### Error Propagation

**MUST:**
- Handle all errors explicitly
- NEVER ignore `Result` or `Option`
- Enter safe state on error

```rust
// ✅ Proper error handling
pub fn control_motion(cmd: MotionCmd) -> Result<(), MotionError> {
    cmd.validate()?;
    
    if !safety_system.is_safe_to_move() {
        enter_degraded_mode();
        return Err(MotionError::UnsafeCondition);
    }
    
    execute_motion(cmd)?;
    Ok(())
}
```

### Degraded Mode

**On error, system MUST:**
- Enter safe state
- Log error (outside ISR)
- Trigger appropriate safety response
- Enable recovery when safe

## Diagnostics & Traceability

### Requirement Traceability

**MUST include in code:**
```rust
/// Emergency stop function
///
/// Requirements:
/// - REQ-SAF-001: Emergency stop within 100ms
/// - REQ-SAF-003: Hardware-based safety
///
/// Verification:
/// - TEST-SAF-001: Emergency stop timing
/// - TEST-SAF-002: Hardware fault injection
pub fn emergency_stop() -> Result<(), SafetyError> {
    // Implementation
}
```

### Logging Rules

**MUST NOT:**
- Log in ISR context
- Log in time-critical code
- Block on logging

**MUST:**
- Log safety events
- Include timestamps
- Log to non-volatile storage for critical events

## Testing & Validation (NON-OPTIONAL)

### Coverage Requirements

- Safety-critical code: 100% coverage
- All other code: > 80% coverage

### Required Test Types

**MUST test:**
- Fault injection
- Communication loss
- Watchdog timeout
- Task starvation
- Priority inversion scenarios
- RTOS scheduling behavior

## Forbidden Patterns (ABSOLUTE)

**NEVER do these:**
```rust
// ❌ Busy waiting
while !condition { }

// ❌ Dynamic thread creation at runtime
std::thread::spawn(|| { });

// ❌ Runtime memory allocation in safety code
let vec = Vec::new();

// ❌ Logging in ISR
#[interrupt]
fn isr() { log::info!("event"); }

// ❌ Shared mutable state without protection
static mut COUNTER: u32 = 0;

// ❌ Blocking in safety threads
mutex.lock();  // Could block indefinitely

// ❌ Hidden side effects
fn seems_innocent() {
    // Secretly modifies global state
    unsafe { GLOBAL += 1; }
}
```

## Self-Check Before Code Review

Before submitting code, verify:
1. ☐ Does this impact safety? (SIL level documented)
2. ☐ Is memory usage bounded?
3. ☐ Is scheduling behavior explicit?
4. ☐ Are all timeouts bounded?
5. ☐ No `unsafe` outside Infrastructure?
6. ☐ No unwrap/expect/panic?
7. ☐ ISR code is minimal?
8. ☐ Requirements referenced?
9. ☐ Tests cover failure modes?
10. ☐ WCET is estimable?

## Enforcement

These rules are enforced by:
- Code review (mandatory)
- Static analysis (Clippy with custom lints)
- Runtime checks (in debug builds)
- Formal review for SIL3 code

**Violations are grounds for rejecting code.**

## References

- IEC 61508: Functional Safety
- ISO 26262: Road vehicles functional safety
- MISRA C/MISRA Rust: Coding guidelines
- Zephyr RTOS Documentation
- [Coding Rules](../development/coding_rules.md)
- [Engineering Principles](./best_practices/concepts.md)

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Safety Team | Initial SIL3 enforcement rules |
