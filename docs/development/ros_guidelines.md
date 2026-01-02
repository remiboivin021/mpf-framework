# ROS Guidelines

## Purpose

This document provides guidelines for using ROS (Robot Operating System) or ROS2 in robotics projects built with MPF, with a focus on safety, security, and industrial-grade practices.

## ROS Version Selection

### ROS 1 vs ROS 2

**Use ROS 2 for:**
- New projects
- Projects requiring security (SROS2)
- Real-time requirements (DDS QoS)
- Multi-robot systems
- Long-term support needs

**Use ROS 1 only if:**
- Maintaining legacy system
- Critical dependency on ROS 1-only packages
- Migration path to ROS 2 is defined

### Recommended ROS 2 Distribution

- **Production**: Latest LTS (Long Term Support) release
- **Development**: Can use current release

## Architecture Integration

### Clean Architecture with ROS

```
┌─────────────────────────────────────────────┐
│              Interfaces Layer                │
│         (ROS Launch, CLI, HMI)              │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│           Application Layer                  │
│         (Use Cases, Orchestration)           │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              Domain Layer                    │
│        (Business Logic, Entities)            │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│         Infrastructure Layer                 │
│    (ROS Nodes, Topics, Services, Actions)    │
└──────────────────────────────────────────────┘
```

**Key Principle:** ROS is isolated in the Infrastructure layer only.

### Node Design

**One Logical Function Per Node:**
```rust
// Good: Single responsibility
pub struct SensorFusionNode {
    // Fuses IMU + odometry → pose estimate
}

// Bad: Multiple responsibilities
pub struct EverythingNode {
    // Sensor fusion + motion control + planning
}
```

## Safety Considerations

### Safety-Critical Communication

**Never rely solely on ROS for safety:**
- Hardware emergency stop required
- Watchdog supervision external to ROS
- Safety interlocks independent of ROS

**For safety-related ROS communication:**
```rust
struct SafetyMessage {
    sequence: u64,
    timestamp: SystemTime,
    command: SafetyCommand,
    checksum: u32,
}

impl SafetyMessage {
    fn validate(&self) -> Result<(), SafetyError> {
        // Verify sequence number
        // Check timestamp freshness
        // Validate checksum
        Ok(())
    }
}
```

### Determinism

**Challenge:** ROS is not deterministic by default

**Mitigation:**
- Use real-time OS (with rt patches or Zephyr)
- Configure DDS QoS for predictable behavior
- Keep ROS nodes simple and bounded
- Monitor worst-case execution time

## Security with SROS2

### Enable Security

```bash
# Create security keystore
ros2 security create_keystore demo_keystore

# Create keys for each node
ros2 security create_key demo_keystore /my_robot/sensor_node
ros2 security create_key demo_keystore /my_robot/controller_node

# Set environment variables
export ROS_SECURITY_KEYSTORE=~/demo_keystore
export ROS_SECURITY_ENABLE=true
export ROS_SECURITY_STRATEGY=Enforce
```

### Access Control Policies

```xml
<?xml version="1.0" encoding="UTF-8"?>
<policy version="0.2.0">
  <enclaves>
    <enclave path="/my_robot">
      <profiles>
        <profile ns="/" node="motion_controller">
          <topics publish="ALLOW">
            <topic>cmd_vel</topic>
          </topics>
          <topics subscribe="ALLOW">
            <topic>sensor_data</topic>
            <topic>safety_status</topic>
          </topics>
          <services reply="DENY" />
        </profile>
      </profiles>
    </enclave>
  </enclaves>
</policy>
```

## Communication Patterns

### Topics

**Use for:**
- Continuous data streams (sensor data)
- Many-to-many communication
- Fire-and-forget messaging

**QoS Configuration:**
```rust
use rclrs::QoSProfile;

fn sensor_qos() -> QoSProfile {
    QoSProfile::default()
        .best_effort()  // Okay to drop old data
        .durability_volatile()
        .history_keep_last(10)
}

fn command_qos() -> QoSProfile {
    QoSProfile::default()
        .reliable()  // Must deliver
        .durability_volatile()
        .history_keep_last(1)
        .deadline(std::time::Duration::from_millis(100))  // Max latency
}
```

### Services

**Use for:**
- Request-response patterns
- Configuration changes
- One-time queries

**Timeout handling:**
```rust
async fn call_service_with_timeout(
    client: &rclrs::Client<ServiceType>,
    request: ServiceType::Request,
) -> Result<ServiceType::Response, ServiceError> {
    let future = client.async_send_request(request);
    
    match tokio::time::timeout(Duration::from_secs(5), future).await {
        Ok(Ok(response)) => Ok(response),
        Ok(Err(e)) => Err(ServiceError::CallFailed(e)),
        Err(_) => Err(ServiceError::Timeout),
    }
}
```

### Actions

**Use for:**
- Long-running tasks
- Tasks needing feedback
- Cancellable operations

**Example:**
```rust
// Action server for navigation
struct NavigateToAction {
    goal: NavigateToGoal,
    feedback_pub: Publisher<NavigateToFeedback>,
}

impl ActionServer for NavigateToAction {
    fn execute(&mut self) -> Result<NavigateToResult, ActionError> {
        while !self.goal_reached() {
            // Check for cancellation
            if self.is_cancel_requested() {
                return Err(ActionError::Cancelled);
            }
            
            // Publish feedback
            self.feedback_pub.publish(self.current_progress());
            
            // Execute one step
            self.step()?;
        }
        
        Ok(NavigateToResult::success())
    }
}
```

## Parameters

### Dynamic Reconfiguration

**Safety-critical parameters must not be dynamically reconfigurable.**

**For non-safety parameters:**
```rust
use rclrs::ParameterValue;

struct NodeParams {
    max_speed: f64,
    update_rate: f64,
}

impl NodeParams {
    fn from_ros_params(node: &Node) -> Result<Self, ParamError> {
        let max_speed = node.declare_parameter("max_speed", 1.0)?;
        let update_rate = node.declare_parameter("update_rate", 10.0)?;
        
        // Validate parameters
        if max_speed <= 0.0 || max_speed > 5.0 {
            return Err(ParamError::OutOfBounds("max_speed"));
        }
        
        Ok(NodeParams { max_speed, update_rate })
    }
}
```

## Error Handling

### Node Failure Handling

**Every node must handle failures gracefully:**

```rust
impl RosNode {
    fn run(&mut self) -> Result<(), NodeError> {
        // Set up error handling
        self.register_signal_handlers();
        
        loop {
            match self.spin_once() {
                Ok(_) => continue,
                Err(NodeError::Recoverable(e)) => {
                    log::warn!("Recoverable error: {}", e);
                    self.attempt_recovery()?;
                }
                Err(NodeError::Fatal(e)) => {
                    log::error!("Fatal error: {}", e);
                    self.shutdown_gracefully();
                    return Err(NodeError::Fatal(e));
                }
            }
        }
    }
}
```

## Logging and Diagnostics

### Structured Logging

```rust
use rclrs::Logger;

fn log_sensor_reading(logger: &Logger, sensor_id: &str, value: f64) {
    logger.info(&format!(
        "sensor_reading: id={}, value={:.3}, timestamp={}",
        sensor_id, value, SystemTime::now()
    ));
}
```

### Diagnostics

**Publish diagnostic information:**
```rust
use diagnostic_msgs::msg::DiagnosticStatus;

fn publish_diagnostics(pub: &Publisher<DiagnosticStatus>) {
    let mut status = DiagnosticStatus::default();
    status.level = DiagnosticStatus::OK;
    status.name = "motion_controller".to_string();
    status.message = "Operating normally".to_string();
    
    // Add key-value diagnostics
    status.values.push(KeyValue {
        key: "temperature".to_string(),
        value: format!("{:.1}", get_temperature()),
    });
    
    pub.publish(status);
}
```

## Testing ROS Nodes

### Unit Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_message_processing() {
        let processor = MessageProcessor::new();
        let input = create_test_message();
        let output = processor.process(input).unwrap();
        assert_eq!(output.result, ExpectedResult);
    }
}
```

### Integration Testing

```rust
#[test]
fn test_node_integration() {
    let context = rclrs::Context::new(env::args()).unwrap();
    let node = SensorNode::new(&context).unwrap();
    
    // Publish test input
    let test_pub = node.create_publisher("input_topic").unwrap();
    test_pub.publish(test_message);
    
    // Wait for output
    let output = wait_for_message("output_topic", Duration::from_secs(1))?;
    assert_eq!(output, expected_output);
}
```

## Performance Optimization

### Message Size

**Keep messages small:**
- Use appropriate data types
- Avoid large arrays when possible
- Consider compression for large data

### Publishing Rate

**Choose appropriate rates:**
- Sensor data: As fast as needed, typically 10-100 Hz
- Commands: 10-50 Hz
- Status: 1-10 Hz
- Diagnostics: 0.1-1 Hz

### Zero-Copy Transport

**Use intra-process communication for large messages:**
```rust
// Configure for zero-copy within same process
let qos = QoSProfile::default()
    .reliable()
    .history_keep_last(1);
// ROS 2 will automatically use intra-process when possible
```

## Launch Files

### Structured Launch

```python
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration

def generate_launch_description():
    return LaunchDescription([
        # Arguments
        DeclareLaunchArgument(
            'use_sim_time',
            default_value='false',
            description='Use simulation time'
        ),
        
        # Nodes
        Node(
            package='my_robot',
            executable='sensor_node',
            name='sensor_node',
            parameters=[{
                'use_sim_time': LaunchConfiguration('use_sim_time'),
                'sensor_rate': 50.0,
            }],
            respawn=True,  # Auto-restart on failure
        ),
        
        Node(
            package='my_robot',
            executable='controller_node',
            name='controller_node',
            parameters=['/config/controller_params.yaml'],
        ),
    ])
```

## Package Structure

```
my_robot_package/
├── package.xml
├── CMakeLists.txt  (for C++)
├── Cargo.toml      (for Rust)
├── launch/
│   ├── robot.launch.py
│   └── simulation.launch.py
├── config/
│   ├── params.yaml
│   └── rviz.rviz
├── src/
│   ├── nodes/
│   │   ├── sensor_node.rs
│   │   └── controller_node.rs
│   └── lib.rs
├── msg/
│   └── CustomMessage.msg
├── srv/
│   └── CustomService.srv
└── action/
    └── CustomAction.action
```

## Common Pitfalls

### Avoid These Anti-Patterns

**1. Global State:**
```rust
// Bad
static mut GLOBAL_STATE: Option<State> = None;

// Good
struct Node {
    state: State,  // Encapsulated state
}
```

**2. Blocking in Callbacks:**
```rust
// Bad
fn callback(&mut self, msg: SensorMsg) {
    std::thread::sleep(Duration::from_secs(1));  // Blocks executor!
}

// Good
fn callback(&mut self, msg: SensorMsg) {
    self.queue.push(msg);  // Quick processing only
}
```

**3. Unchecked Timing:**
```rust
// Bad
loop {
    spin_once();  // Uncontrolled rate
}

// Good
let mut rate = Rate::new(Duration::from_millis(10));
loop {
    spin_once();
    rate.sleep();
}
```

## Migration from ROS 1

**Step-by-step migration:**
1. Audit ROS 1 dependencies
2. Update message/service definitions
3. Port nodes incrementally
4. Bridge ROS 1 and ROS 2 during transition
5. Validate functionality at each step
6. Complete migration and remove bridge

## References

- ROS 2 Documentation: https://docs.ros.org
- SROS2: https://design.ros2.org/articles/ros2_security.html
- [Development Process](./development_process.md)
- [Coding Rules](./coding_rules.md)

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | TBD | Development Team | Initial ROS guidelines |
