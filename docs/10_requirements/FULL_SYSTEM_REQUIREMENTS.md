# Full System Requirements

Status: Draft Baseline v0.1

## 1. System Boundary

### FSR-SYS-001
Physical Body は Yura System と独立した subsystem として接続可能でなければならない。

### FSR-SYS-002
Live2D / 3D / Physical Body は同一の Canonical Body State を入力境界として利用可能でなければならない。

### FSR-SYS-003
Physical Body から Yura System へは Canonical Observation と Actual Body State を出力できなければならない。

### FSR-SYS-004
Physical Body は人格・感情・会話方針・注意対象を独自決定してはならない。

## 2. Motion

### FSR-MOT-001
基準機体は Head Yaw / Pitch / Roll の3回転自由度を持つ。

### FSR-MOT-002
3軸は独立かつ同時に連続制御可能でなければならない。

### FSR-MOT-003
動作プリセット名ではなく連続 Body State を追従可能でなければならない。

### FSR-MOT-004
各可動軸は Desired State と Actual State の閉ループ管理が可能でなければならない。

### FSR-MOT-005
低速域・微小変位域で滑らかに制御可能でなければならない。

### FSR-MOT-006
Physical Body Edge と Real-time Controller は多段周期制御を可能としなければならない。

## 3. Display / Expression

### FSR-DSP-001
主要表情UIは Eyes / Eyebrows で構成する。

### FSR-DSP-002
口の描画を表情表現の必須要素としてはならない。

### FSR-DSP-003
Speech は Speaker から出力する。

### FSR-DSP-004
Display Endpoint は交換可能なデバイスとして抽象化する。

### FSR-DSP-005
iPhone を Reference Display Endpoint として利用可能にする。

## 4. Vision Perception

Full System は次の perception capability を設計対象に含む。

- Person detection
- Person tracking
- Face detection
- Face landmark
- Head pose estimation
- Gaze estimation
- Body pose
- Object detection
- Object tracking
- Hand detection
- Hand pose
- Gesture detection
- RGB-D / depth processing
- Spatial position estimation
- Motion / optical-flow based tracking
- Sensor fusion

各機能が V1 で実装されるか否かは別途決定する。

## 5. Audio Perception

Full System は次を設計対象に含む。

- microphone array
- audio capture
- Acoustic Echo Cancellation
- noise reduction
- Voice Activity Detection
- beamforming
- sound-source localization
- direction-of-arrival estimation
- sound-source tracking
- speaker-track association

## 6. Physical Sensors

Full System は将来拡張可能なセンサー境界を持つ。

- touch
- proximity / ToF
- IMU
- motor encoders
- current / voltage
- temperature
- hardware fault signals

## 7. Coordinate System

### FSR-COORD-001
WORLD / BODY_BASE / HEAD / DISPLAY / CAMERA / MIC_ARRAY 等の座標系を定義する。

### FSR-COORD-002
首運動による Camera frame の変化を考慮した座標変換を行えること。

### FSR-COORD-003
Perception Observation は可能な限り共通3D座標へ変換可能であること。

## 8. Timing

全ての時系列データは最低限以下を持つ。

- timestamp
- sequence
- source identifier
- clock / synchronization metadata

Camera / Audio / Motor / Display / Observation 間の時間関係を復元可能であること。

## 9. Capabilities

接続時に Physical Body は実装可能な自由度・センサー・表示能力・更新周期・制約を Capability として公開する。

## 10. Safety

Full System は以下を設計対象とする。

- hard/soft motion limits
- velocity limits
- acceleration limits
- current/thermal protection
- watchdog
- communication-loss behavior
- safe pose / torque-off strategy
- emergency stop
- startup self-check
- calibration validity
- actuator fault detection

## 11. Fault Tolerance

- Yura System disconnect
- Edge Runtime restart
- Display Endpoint disconnect
- MCU disconnect
- sensor loss
- partial capability loss
- timestamp discontinuity
- stale command
- out-of-order command

を定義された状態遷移として処理する。

## 12. Versioning

Body Contract は独立バージョンを持ち、互換性確認・Capability Negotiation を行えること。
