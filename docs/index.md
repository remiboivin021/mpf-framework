# Modular Project Framework (MPF)

## Overview

The Modular Project Framework (MPF) is an industrial-grade framework for structuring complex software systems using a multi-repository, clean architecture approach. It is specifically designed for robotics projects with support for RTOS, ROS/ROS2, and other middleware.

## Purpose

This repository serves as:

- **A Project Orchestrator**: Central coordination point for modular projects
- **A Bootstrapper**: Rapid initialization tool for modular projects
- **A Governance Hub**: Centralized documentation and compliance management

## What This Repository Is NOT

- It does **not** contain business logic
- It does **not** build or deploy products directly
- It does **not** replace module repositories

## Quick Start

### Prerequisites

- Git
- GitHub CLI (`gh`)
- Bash shell

### Setup Steps

1. **Use this repository as a GitHub template**
   ```bash
   gh repo create my-org/my-project --template mpf-robot-framework
   git clone git@github.com:my-org/my-project.git
   cd my-project
   ```

2. **Configure environment**
   
   Edit `config/config.env` with your project details:
   ```bash
   PROJECT_NAME=...
   PROJECT_ORG=...
   PROJECT_REPO=...
   PROJECT_TYPE=robotics
   USE_RTOS=true/false
   MIDDLEWARE=ROS2/ROS1/NONE
   LICENSE=Apache-2.0
   DEFAULT_BRANCH=main
   ```

3. **Validate configuration**
   ```bash
   ./scripts/validate-env.sh
   ```

4. **Initialize project**
   ```bash
   ./scripts/init-project.sh
   ```

## Architecture

The framework follows Clean Architecture principles with the following modular structure:

### Child Module Repositories

The initialization script automatically creates and configures these child template repositories as submodules:

| Module | Purpose |
|--------|---------|
| **domain** | Core business logic, robot state, and invariants |
| **application** | Use cases, orchestration, and workflows |
| **infrastructure** | ROS nodes, drivers, HIL interfaces, hardware integration |
| **interfaces** | CLI, REST API, HMI, diagnostics |
| **shared** | Logging, error model, safety utilities, configuration |

> **Note**: Child template repos are **NOT** included in this repository. They are initialized dynamically via the `init-project.sh` script.

## Engineering Principles

### YAGNI (You Aren't Gonna Need It)

- Do not implement features without a validated requirement
- Every feature must be traceable to a requirement ID
- Future-proofing is forbidden in safety-critical code
- No speculative abstractions

### KISS (Keep It Simple, Stupid)

- Prioritize simplicity and readability
- Avoid unnecessary abstractions
- Each function should do one simple thing
- Any complex code must be justified and clearly commented

### Fail-Fast / Fail-Safe

- Detect errors as soon as they occur
- Ensure the system remains in a safe state under any failure
- Never ignore errors
- Always provide a safe fallback

### Design by Contract (DbC)

- Clear preconditions, postconditions, and invariants
- Validate all inputs
- Enforce limits explicitly
- Define expected state before and after execution

## Commit Message Conventions

All commits must follow a structured format including **WHY** + **WHAT** sections:

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

This is enforced via Git hooks and commitlint.

## Safety Integrity Levels (SIL)

All commits must declare a SIL level:

- `[SIL0]`: Non-safety changes
- `[SIL2]`: Safety-related changes (requires extended description, safety impact, requirement references)
- `[SIL3]`: Critical safety changes (requires failure mode description and requirement IDs)

## Documentation Structure

The framework includes comprehensive documentation for industrial compliance:

- **Standards**: Applicable standards, mappings, and deviations
- **Cybersecurity**: Threat models, attack surfaces, secure communication
- **Development**: Development process, ROS guidelines, coding rules
- **Change Management**: Change impact analysis, safety reassessment
- **Configuration Management**: Robot configuration, calibration, parameters
- **Operations**: Deployment, maintenance, incident response
- **Safety Case**: Safety case documentation and evidence mapping

## Contributing

Please read our [Contributing Guidelines](https://github.com/remiboivin021/mpf-framework/blob/main/CONTRIBUTING.md) and [Code of Conduct](https://github.com/remiboivin021/mpf-framework/blob/main/CODE_OF_CONDUCT.md) before submitting contributions.

## License

See the LICENSE file in the root of the repository for licensing information.

## Support

For issues, questions, or contributions, please use the GitHub issue tracker or discussions.
