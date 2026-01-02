# Applicable Standards

## Overview

This document identifies the industrial standards applicable to projects built using the Modular Project Framework (MPF). Compliance with these standards is essential for industrial-grade robotics systems, particularly for safety-critical applications.

## Safety Standards

### ISO 13849 - Safety of Machinery

**Applicability:** Safety-related parts of control systems

- **Part 1**: General principles for design
- **Part 2**: Validation

**Scope:**
- Safety-critical control logic
- Emergency stop systems
- Safety interlocks
- Risk reduction measures

### IEC 61508 - Functional Safety

**Applicability:** Safety-related electrical/electronic/programmable electronic systems

- **Safety Integrity Levels (SIL)**: SIL 1-3 classification
- **Systematic capability**: SC 1-3

**Scope:**
- Overall functional safety management
- Safety lifecycle
- Verification and validation
- Tool qualification

### ISO 10218 - Robots and Robotic Devices

**Applicability:** Industrial robots and robot systems

- **Part 1**: Robots
- **Part 2**: Robot systems and integration

**Scope:**
- Collaborative robot operations
- Human-robot interaction
- Safety-rated monitored stop
- Speed and separation monitoring

### ISO/TS 15066 - Collaborative Robots

**Applicability:** Collaborative industrial robot systems

**Scope:**
- Power and force limiting
- Biomechanical limits
- Risk assessment for collaborative operations

## Software Standards

### IEC 62304 - Medical Device Software

**Applicability:** Software lifecycle processes (adapted for robotics)

**Scope:**
- Software development planning
- Requirements analysis
- Architecture design
- Unit implementation and verification
- Integration and integration testing
- System testing
- Release
- Software maintenance

### MISRA C/C++ / MISRA Rust

**Applicability:** Coding standards for safety-critical software

**Scope:**
- Code quality
- Predictability
- Maintainability
- Avoidance of undefined behavior

## Cybersecurity Standards

### IEC 62443 - Industrial Communication Networks

**Applicability:** Network and system security for industrial automation and control systems

**Scope:**
- Security lifecycle
- Security levels
- System requirements
- Component requirements

### ISO/SAE 21434 - Road Vehicles Cybersecurity

**Applicability:** Cybersecurity engineering (adapted for mobile robotics)

**Scope:**
- Cybersecurity management
- Risk assessment
- Threat analysis and risk assessment (TARA)
- Security validation

## Quality Standards

### ISO 9001 - Quality Management Systems

**Applicability:** Overall quality management

**Scope:**
- Quality management principles
- Process approach
- Continuous improvement

### ISO/IEC 25010 - Software Quality

**Applicability:** Software product quality

**Scope:**
- Functional suitability
- Performance efficiency
- Compatibility
- Usability
- Reliability
- Security
- Maintainability
- Portability

## Environmental Standards

### IEC 60068 - Environmental Testing

**Applicability:** Environmental conditions and testing procedures

**Scope:**
- Temperature
- Humidity
- Vibration
- Shock

## Documentation Standards

### IEC 82079 - Instructions for Use

**Applicability:** User documentation

**Scope:**
- Content and format
- User information

## Electromagnetic Compatibility

### IEC 61000 - Electromagnetic Compatibility (EMC)

**Applicability:** EMC requirements

**Scope:**
- Emission limits
- Immunity requirements

## Project-Specific Applicability

Each project using MPF must document:

1. Which standards apply to their specific application
2. The required compliance level for each standard
3. Any deviations or exclusions with justification
4. Mapping of requirements to standard clauses

See [Standards Mapping](./standards_mapping.md) and [Deviations and Justifications](./deviations_and_justifications.md) for project-specific documentation templates.

## Regulatory Considerations

Depending on the deployment region and application domain, additional regulatory requirements may apply:

- **EU**: Machinery Directive 2006/42/EC, Radio Equipment Directive 2014/53/EU
- **US**: OSHA regulations, UL standards
- **Asia**: GB standards (China), JIS standards (Japan)

## References

- ISO 13849-1:2015 - Safety of machinery
- IEC 61508:2010 - Functional safety
- ISO 10218-1:2011 - Robots and robotic devices
- ISO/TS 15066:2016 - Collaborative robots
- IEC 62304:2015 - Medical device software
- IEC 62443 series - Industrial network and system security
- ISO/SAE 21434:2021 - Road vehicles cybersecurity

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Team | Initial version |
