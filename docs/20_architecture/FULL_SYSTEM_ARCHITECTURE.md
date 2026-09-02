# Full System Architecture

Status: Draft Baseline v0.1

## 1. Logical Architecture

```text
                         YURA SYSTEM
┌──────────────────────────────────────────────────────┐
│ Cognition / Memory / Emotion / Desire / Attention   │
│ World Model / Activity                              │
│                                                      │
│ Body Motion & Expression Core                       │
│                                                      │
│ Canonical Body State        Canonical Observation   │
└───────────────┬──────────────────────▲───────────────┘
                │                      │
================ Body Contract Boundary =================
                │                      │
                ▼                      │
┌──────────────────────────────────────────────────────┐
│ PHYSICAL BODY EDGE RUNTIME                           │
│                                                      │
│ Contract Gateway                                     │
│ Device Registry / Capability Manager                 │
│ Coordinate Transform / Calibration                   │
│ Clock / Synchronization                              │
│ Perception / Sensor Fusion                           │
│ Audio DSP                                            │
│ Body State Projection                               │
│ Device Health / Fault Management                     │
└───────┬──────────────┬──────────────┬────────────────┘
        │              │              │
        ▼              ▼              ▼
 Display Endpoint   Vision/Depth   Audio/Sensors
 (iPhone ref.)      Endpoints      Endpoints
        │
        └────────────────┐
                         ▼
              REAL-TIME MOTION CONTROLLER
              MCU / Motor Control
              - interpolation
              - kinematics
              - feedback
              - safety
                         │
                         ▼
                  Yaw / Pitch / Roll
```

## 2. Responsibility Boundary

### Yura System
- Attention target
- Emotion
- Intention
- High-level body expression generation
- Canonical Body State generation
- Interpretation of Canonical Observation
- Semantic identity / memory association

### Physical Body Edge Runtime
- Device abstraction
- perception preprocessing
- tracking
- sensor fusion
- coordinate transforms
- time alignment
- capability reporting
- Body State projection to available hardware
- health aggregation
- communication termination

### Real-time Motion Controller
- real-time actuator loops
- interpolation / trajectory execution
- encoder feedback
- motion safety
- watchdog
- emergency state

### Display Endpoint
- Eyes / Eyebrows rendering
- gaze rendering
- blink / visual interpolation
- optional camera/audio endpoint functionality
- no independent personality decision

## 3. Compute Partitioning

Full System の論理構成は以下の3階層を前提とする。

1. **Yura Compute**
   - Yura Core
   - AI / cognition

2. **Body Edge Compute**
   - Raspberry Pi級またはより高性能なSBC/Edge Computerを含む
   - Perception / Sensor Fusion / Device Coordination
   - 実装機種は性能設計で決定

3. **Real-time Control**
   - MCU
   - motor / safety / hardware I/O

iPhone は Compute Tier の代替ではなく Display/Sensor Endpoint として扱う。

## 4. Motion Dataflow

```text
Yura Body Motion Generator
        ↓ continuous canonical state
Physical Body Edge
        ↓ capability projection / coordinate conversion
Motion Target Stream
        ↓
Real-time MCU
        ↓ high-rate interpolation / feedback control
Actuators
        ↓
Encoder / IMU
        └──────── Actual Body State ────────→ Yura
```

## 5. Perception Dataflow

```text
Camera / Depth / Mic Array / Touch / IMU
                ↓
        Body Edge Perception
                ↓
 detection / tracking / DSP / fusion
                ↓
        Canonical Observation
                ↓
              Yura
```

Body Edge は「人が怒っている」「話しかけるべき」等の人格判断を行わない。

## 6. Physical Head

Reference mechanism:

- Head Yaw
- Head Pitch
- Head Roll

要求:
- simultaneous continuous control
- actual pose feedback
- low-noise operation
- smooth low-speed control
- minimal backlash / jitter
- center-of-rotation and center-of-mass optimization
- cable routing through full required workspace
- serviceable Display Endpoint mount

## 7. Display Endpoint

Reference implementation: iPhone.

iPhone採用により以下を利用可能とする。

- high-quality display
- touch
- camera
- microphone
- speaker
- local rendering
- network connectivity

ただし専用Displayや他端末へ交換可能なContractとする。

## 8. Full vs V1

Full System architecture の subsystem は V1 で未実装でも削除しない。
V1 document は subsystem ごとに `implemented / stubbed / deferred` を定義する。
