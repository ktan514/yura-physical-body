# Hardware Design Basis

Status: Draft for Issue #6 Review
Revision: 0.3-draft
Purpose: ハードウェア要求仕様書を作成する前段の設計基準。

## 1. Reference Physical Form

デスク上に常設する据置型Physical Body。

頭部/表示部は以下の3回転自由度を持つ。

- Yaw
- Pitch
- Roll

表情UIはEyes / Eyebrowsを基本とし、SpeechはSpeakerから出力する。

## 2. Hardware design philosophy

Physical Bodyは単なる可動display standではなく、Yuraの連続Body Stateを物理世界へ再現するBody implementationである。

したがってHardware設計では、最大速度より以下を優先する。

1. Safety
2. Smooth low-speed motion
3. Quietness
4. Repeatability / actual-state feedback
5. Fine motion capability
6. Low backlash / low jitter
7. Thermal headroom
8. Mechanical robustness
9. Serviceability
10. Maximum speed

## 3. Requirement vs implementation freedom

System側は次を固定する。

- required DoF
- normal usable range
- motion quality
- payload envelope
- response / control performance
- safety behavior
- failure behavior
- calibration / feedback requirements
- verification method

Hardware Engineerは要求を満たす範囲で次を選定する。

- actuator technology
- transmission
- bearing arrangement
- gimbal / linkage / spherical mechanism
- counterbalance / spring / brake
- material
- encoder arrangement
- cable routing detail

Brushless servo classは有力候補だが、固定技術ではない。

## 4. Motion baseline

詳細正本は `MOTION_MECHANICAL_REQUIREMENTS.md` とする。

主要design envelope:

- Yaw: **左右合計180°以上**。360°連続回転は必須ではない
- Pitch: 上25°以上 / 下30°以上
- Roll: 左右各20°以上
- normal max velocity: 120°/s
- nominal expressive velocity: 60°/s級
- normal max acceleration: 360°/s²
- normal max jerk: 2000°/s³
- static pose error: ±0.5°以内
- dynamic error: p95 2.0°以内
- micro motion: 0.25° target変化を滑らかに再現

## 5. Payload / center of gravity

Reference Display Endpointは交換可能なpayloadとして扱う。

- nominal removable payload: 350 g以下
- maximum removable payload: 500 g以下

Display Endpointのcenter of massと有効回転中心を可能な限り近づける。

特定mechanism geometryを強制せず、static holding torqueのcontinuous actuator rating比でheadroomを評価する。

- nominal payload worst pose: 35%以下を目標
- maximum payload worst pose: 50%以下を目標

## 6. Closed-loop actuation

Full Systemでは各powered axisについてActual poseを取得する。

最低限:

- target position
- actual position feedback
- velocity awareness
- acceleration / jerk limiting
- current / fault monitoring
- safe range enforcement
- local watchdog

output pose equivalent sensing resolutionは0.1°以下を要求する。

## 7. Real-time architecture

```text
Yura Compute
  CanonicalBodyState 60 Hz nominal
        ↓
Body Edge Computer
  capability / constraint projection
        ↓ >=200 Hz target
Real-time MCU
  trajectory / feedback / safety >=500 Hz
        ↓
Actuators / Encoders
```

Yura/networkが停止してもMCU/local safety layerは安全制御を継続する。

## 8. Power-loss safety

power loss時にhead/displayがfree-fallしてはならない。

必要に応じて:

- passive counterbalance
- spring
- normally-engaged brake
- self-locking transmission
- damper
- physical stop

を使用する。

torque-offはmechanically safeであることを確認できた場合のみsafe stateとして使用する。

## 9. Cabling

全normal usable rangeで:

- excessive twistを避ける
- tensionを避ける
- pinchを避ける
- manufacturer minimum bend radiusを守る
- display交換可能
- sensor/communication/power wiringを保守可能

Yaw無限回転は要求しないが、**左右合計180°以上の通常可動域**を成立させる配線設計を要求する。

representative expressive motionで1,000,000 cyclesをdesign life targetとする。

## 10. Acoustic design

normal expressive motionのreference requirement:

- 0.5 m位置
- background 25 dBA以下を目標
- LAeq 32 dBA以下
- LAFmax 40 dBA以下

motor/gear/fan noiseがAudio Perceptionへ与える影響は#7でも評価する。

## 11. Mechanical stability

maximum payload / worst normal pose / cable loadを含むstatic overturning momentに対し1.5以上のstability factorを持つ。

さらにworst normal poseでdisplay center相当位置へ10 Nを2秒quasi-staticに加えてもtip-overしないことを要求する。

## 12. Safety architecture

詳細正本は `SAFETY_ARCHITECTURE.md` とする。

少なくとも:

- NORMAL
- DEGRADED
- SAFE_HOLD
- SAFE_STOP
- FAULT
- EMERGENCY_STOP

を区別する。

250 ms超のCanonical state lossではSAFE_HOLD、1 sのsession/liveness lossではSAFE_STOP系へ移行する#5 policyをmechanical motionへ具体化する。

## 13. Audio

完成形では専用microphone arrayを設計対象とする。

理由:

- stable geometry
- sound-source localization
- beamforming
- AEC
- head movement independent acoustic frame

iPhone microphoneは追加capture endpointとして利用可能だが、専用arrayを置換する前提にはしない。

## 14. Sensors

Full System設計対象:

- RGB camera
- depth sensing
- microphone array
- touch
- proximity / ToF
- IMU
- encoder
- current / voltage
- temperature

配置・数量・性能はPerception requirementsから派生させる。

## 15. Safety standards readiness

現時点で規格適合を宣言しない。

Design Freezeまでに少なくとも以下の適用可能性を再評価する。

- ISO 12100:2010および後継版
- ISO 13482:2014および後継ISO/FDIS 13482
- ISO/TR 23482-1:2020
- IEC 62368-1:2023

## 16. Hardware Handoff

Full System Design Freeze後にHardware Engineer向けに別途以下を確定する。

- 要望書
- Hardware Requirements Specification
- Mechanical Requirements
- Motion Requirements
- Electrical / Power Requirements
- Sensor Requirements
- Safety Requirements
- Interface Control Document
- Calibration Specification
- Acceptance Test Specification
- Requirement Traceability Matrix

本書および#6文書はHandoff資料の設計正本となるが、現時点では最終制作依頼書ではない。
