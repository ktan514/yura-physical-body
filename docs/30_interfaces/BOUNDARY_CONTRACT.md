# Yura ↔ Physical Body Boundary Contract

Status: Draft Baseline v0.1

## 1. Contract Principle

境界は「動作命令」ではなく状態ストリームと観測ストリームで構成する。

禁止例:

```json
{"command":"tilt_head"}
```

基本例:

```json
{
  "timestamp": 0,
  "sequence": 0,
  "head": {
    "orientation": {
      "yaw": 0.0,
      "pitch": 0.0,
      "roll": 0.0
    }
  },
  "eyes": {
    "gaze": [0.0, 0.0, 1.0],
    "openness_left": 1.0,
    "openness_right": 1.0
  },
  "eyebrows": {
    "left_inner": 0.0,
    "left_outer": 0.0,
    "right_inner": 0.0,
    "right_outer": 0.0
  }
}
```

## 2. Yura → Body

### CanonicalBodyState
Yura が現在望む身体状態。

想定カテゴリ:
- root pose
- head position/orientation
- gaze target/vector
- eyes
- eyebrows
- future torso / shoulder / arms
- expression continuous parameters
- speech/playback synchronization metadata

### BodyStreamControl
- stream start / stop
- reset
- target latency class
- contract version

## 3. Body → Yura

### CanonicalObservation
- person
- face
- head pose
- gaze
- body pose
- hand
- gesture
- object
- sound source
- touch
- proximity
- environmental / device observations

### ActualBodyState
- actual joint/pose state
- display state
- tracking error
- timestamp

### BodyCapability
- supported DoF
- limits
- update rates
- sensor capabilities
- display capabilities
- optional features

### BodyHealth
- actuator state
- thermal state
- power state
- sensor state
- clock state
- connection state
- faults

## 4. Coordinate Model

Minimum frame tree:

```text
WORLD
└── BODY_BASE
    ├── HEAD_YAW
    │   └── HEAD_PITCH
    │       └── HEAD_ROLL
    │           ├── DISPLAY
    │           └── CAMERA_*
    ├── MIC_ARRAY
    └── SENSOR_*
```

Contract上の角度・長さ・時間の単位は固定し、暗黙変換を禁止する。

初期候補:
- angle: radians
- distance: meter
- time: monotonic nanoseconds + synchronized wall-clock metadata

正式単位は Interface Design工程でFreezeする。

## 5. Streaming

Canonical Body State は低頻度コマンドではなく一定周期のstreamを前提とする。

設計目標レンジ:
- Yura → Body canonical stream: 30–120 Hz
- Display rendering: device refresh rate
- Edge → MCU target stream: system dependent
- MCU inner control loop: hundreds of Hz to kHz class

数値は性能設計・実機評価で確定する。

## 6. Stale / Loss Handling

全messageに sequence / timestamp / source を持たせる。

Body は以下を検出する。
- stale state
- duplicate
- out-of-order
- excessive latency
- clock discontinuity

通信断時は最後の姿勢を無期限保持せず、定義された safe behavior へ遷移する。

## 7. Capability Negotiation

接続時にBodyは、少なくとも以下を通知する。

- contract versions
- supported physical axes
- axis limits
- actual-state feedback availability
- display type/features
- cameras
- depth
- microphones / array
- touch
- IMU
- perception modules
- maximum/nominal stream rates

Yuraは未対応Capabilityを前提にしてはならない。
