# Simulation Policy

## Purpose

This document defines the policy and best practices for using simulation in robotics development with MPF.

## Simulation Strategy

### Simulation vs Real Hardware

**Use Simulation For:**
- Algorithm development
- Initial testing
- Regression testing
- Edge case testing
- Training and demonstrations

**Use Real Hardware For:**
- Final validation
- Performance verification
- Safety validation
- Hardware integration testing
- Production deployment

### Simulation Fidelity Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **L1 - Kinematic** | Basic motion, no physics | Algorithm development |
| **L2 - Dynamic** | Physics simulation | Control algorithm testing |
| **L3 - Sensor** | Realistic sensor models | Perception testing |
| **L4 - High-Fidelity** | Detailed physics + sensors | Pre-deployment validation |

## Simulation Tools

### Recommended Simulators

- **Gazebo**: General-purpose robot simulation
- **Isaac Sim**: NVIDIA's high-fidelity simulator
- **Webots**: Multi-robot simulation
- **Custom**: Domain-specific simulators

### Integration with ROS

```python
# Launch file with sim/real switch
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration

def generate_launch_description():
    use_sim = LaunchConfiguration('use_sim_time')
    
    return LaunchDescription([
        DeclareLaunchArgument('use_sim_time', default_value='false'),
        # Conditional node loading based on sim/real
    ])
```

## Simulation-to-Reality Gap

### Known Differences

1. **Physics**: Simplified vs real-world complexity
2. **Sensors**: Perfect vs noisy real sensors
3. **Timing**: Deterministic vs real-time variations
4. **Wear**: No wear simulation vs hardware degradation

### Mitigation Strategies

- Add noise to simulated sensors
- Model delays and jitter
- Test on real hardware regularly
- Document known gaps

## Testing Requirements

### Simulation Testing

**Required:**
- Functional correctness
- Basic safety checks
- Performance benchmarks

**Not Sufficient:**
- Safety certification
- Production deployment
- Hardware compatibility

### Hardware Testing

**Always required for:**
- Safety-critical features
- Production releases
- Performance validation
- Hardware integration

## References

- [Development Process](./development_process.md)
- [ROS Guidelines](./ros_guidelines.md)

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Development Team | Initial simulation policy |
