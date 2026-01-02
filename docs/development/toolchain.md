# Toolchain

## Purpose

This document describes the development toolchain for robotics projects built with MPF.

## Core Tools

### Rust Toolchain

**Installation:**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable
rustup component add clippy rustfmt
```

**Required Components:**
- `rustc`: Rust compiler
- `cargo`: Package manager and build tool
- `clippy`: Linter
- `rustfmt`: Code formatter

### Version Control

**Git:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor "vim"
```

**GitHub CLI:**
```bash
gh auth login
```

### ROS / ROS2 (If Applicable)

**Installation (ROS 2 Humble):**
```bash
sudo apt install ros-humble-desktop
source /opt/ros/humble/setup.bash
```

## Development Tools

### IDEs and Editors

**Recommended:**
- **VSCode** with rust-analyzer extension
- **CLion** with Rust plugin  
- **Vim/Neovim** with rust.vim

### Debugging Tools

- **GDB**: GNU Debugger
- **LLDB**: LLVM Debugger
- **Valgrind**: Memory debugging (for C/C++ FFI)

### Profiling Tools

- **perf**: Linux performance analyzer
- **flamegraph**: Visualization
- **cargo-flamegraph**: Rust-specific profiling

## Build Tools

### Cross-Compilation

```bash
# Add target
rustup target add armv7-unknown-linux-gnueabihf

# Build for target
cargo build --target=armv7-unknown-linux-gnueabihf --release
```

### Containerization

**Docker for reproducible builds:**
```dockerfile
FROM rust:1.75
WORKDIR /app
COPY . .
RUN cargo build --release
```

## Quality Tools

### Static Analysis

- `cargo clippy`: Linting
- `cargo audit`: Security vulnerabilities
- `cargo deny`: Dependency management

### Testing Tools

- `cargo test`: Unit and integration tests
- `cargo tarpaulin`: Code coverage
- `criterion`: Benchmarking

## Documentation Tools

### Code Documentation

```bash
cargo doc --no-deps --open
```

### Project Documentation

- **MkDocs**: Documentation site
- **mdBook**: Rust book-style documentation

## Hardware Tools (If Applicable)

### Firmware Flashing

- OpenOCD
- Black Magic Probe
- ST-Link

### Serial Communication

- `minicom`
- `screen`
- `picocom`

## Tool Qualification

For safety-critical development, tools may need qualification per IEC 61508.

| Tool | Classification | Qualification Required |
|------|---------------|------------------------|
| Rust Compiler | T2 | Recommended |
| Clippy | T3 | Recommended |
| Test Framework | T3 | Yes |

## References

- [Development Process](./development_process.md)
- [Coding Rules](./coding_rules.md)

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Development Team | Initial toolchain documentation |
