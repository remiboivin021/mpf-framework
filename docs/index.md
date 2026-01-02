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

The framework follows core engineering principles essential for safety-critical robotics development:

- **YAGNI (You Aren't Gonna Need It)**: Avoid unnecessary features and abstractions
- **KISS (Keep It Simple, Stupid)**: Prioritize simplicity and readability
- **Fail-Fast / Fail-Safe**: Detect errors early and maintain safe states
- **Design by Contract (DbC)**: Define explicit contracts for all interfaces
- **SOLID Principles**: Guide object-oriented design decisions

For detailed guidelines and rationale, see [Engineering Principles](./engineering/best_practices/concepts.md).

## Git Conventions

All commits must follow structured conventions with **WHY** + **WHAT** sections and declare a Safety Integrity Level (SIL):

- **`[SIL0]`**: Non-safety changes (documentation, build config)
- **`[SIL2]`**: Safety-related changes (requires impact assessment and requirement references)
- **`[SIL3]`**: Critical safety changes (requires failure mode description and verification plan)

For complete commit message format, examples, and workflow practices, see [Git Conventions](./engineering/best_practices/git.md).

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

This project is licensed under the terms described in the [LICENSE](https://github.com/remiboivin021/mpf-framework/blob/main/LICENSE) file.

## Support

For issues, questions, or contributions, please use the GitHub issue tracker or discussions.
