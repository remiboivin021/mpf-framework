# Modular Project Framework (MPF)

MPF is an industrial-grade framework for structuring complex software systems
using a multi-repository, clean architecture approach.

## What this repository is
- A project orchestrator
- A bootstrapper for modular projects
- A governance and documentation hub

## What this repository is NOT
- It does not contain business logic
- It does not build or deploy products
- It does not replace module repositories

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

## Documentation

For complete documentation, see the [documentation site](https://remiboivin021.github.io/mpf-framework/).

## Architecture

See the [documentation](https://remiboivin021.github.io/mpf-framework/) for detailed architecture information.
