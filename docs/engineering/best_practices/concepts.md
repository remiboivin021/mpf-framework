# Engineering Principles

This document outlines the core engineering principles that guide development in the Modular Project Framework (MPF).

## YAGNI (You Aren't Gonna Need It)

**Principle:** Do not implement features or abstractions that are not immediately needed.

**Guidelines:**
- Do not implement features without a validated requirement
- Every feature must be traceable to a requirement ID
- Future-proofing is forbidden in safety-critical code
- No speculative abstractions

**Rationale:** Unnecessary features increase complexity, maintenance burden, and potential failure points in safety-critical systems.

## KISS (Keep It Simple, Stupid)

**Principle:** Prioritize simplicity and readability in all code and design decisions.

**Guidelines:**
- Prioritize simplicity and readability
- Avoid unnecessary abstractions
- Each function should do one simple thing
- Any complex code must be justified and clearly commented

**Rationale:** Simple code is easier to verify, test, and maintain. In safety-critical systems, complexity is a liability.

## Fail-Fast / Fail-Safe

**Principle:** Detect errors immediately and ensure the system remains in a safe state under any failure condition.

**Guidelines:**
- Detect errors as soon as they occur
- Ensure the system remains in a safe state under any failure
- Never ignore errors
- Always provide a safe fallback

**Rationale:** Early error detection prevents cascading failures. Fail-safe behavior protects against harm to humans and equipment.

## Design by Contract (DbC)

**Principle:** Define explicit contracts for all modules, functions, and interfaces.

**Guidelines:**
- Clear preconditions, postconditions, and invariants
- Validate all inputs
- Enforce limits explicitly
- Define expected state before and after execution

**Rationale:** Explicit contracts make behavior predictable and verifiable, essential for safety certification.

## SOLID Principles

The SOLID principles guide object-oriented design in the framework:

- **S** - Single Responsibility Principle: Each module/function has only one responsibility
- **O** - Open/Closed Principle: Open for extension but closed for modification
- **L** - Liskov Substitution Principle: Any trait/type implementation can be replaced without breaking contracts
- **I** - Interface Segregation Principle: Avoid "fat" traits/interfaces; prefer small, specific ones
- **D** - Dependency Inversion Principle: Depend on traits/abstractions, not concrete modules

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
