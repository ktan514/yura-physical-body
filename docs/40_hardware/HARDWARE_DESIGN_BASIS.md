# Hardware Design Basis

Status: Draft Baseline v0.1
Purpose: ハードウェア要求仕様書を作成する前段の設計基準。

## 1. Reference Physical Form

デスク上に設置する据置型Physical Body。

頭部/表示部は以下の3自由度で姿勢変更する。

- Yaw
- Pitch
- Roll

表情UIは Eyes / Eyebrows。
SpeechはSpeaker。

## 2. Motion Design Priorities

優先順位は概ね以下とする。

1. Safety
2. Smooth low-speed motion
3. Quietness
4. Repeatability / feedback
5. Fine motion capability
6. Low backlash / low jitter
7. Mechanical robustness
8. Serviceability
9. Maximum speed

単純な最高速度を最優先しない。

## 3. Actuation

Full Systemでは閉ループ姿勢制御を要求する。

各軸について要求候補:
- target position
- actual position feedback
- velocity awareness
- acceleration limiting
- current / fault monitoring
- safe range enforcement

Brushless servo class は有力候補だが、特定方式への固定はハードウェア要求値確定後に行う。

## 4. Center of Mass / Rotation

Display Endpoint の重心と仮想回転中心を可能な限り近づける。

目的:
- required torque reduction
- thermal reduction
- quieter operation
- improved micro-motion
- reduced static load

## 5. Cabling

全可動域で次を満たすこと。
- excessive twist を避ける
- tension を避ける
- fatigue を抑える
- display交換が可能
- sensor/communication/power wiring が保守可能

Yaw無限回転を必須とはしない。
必要可動域はFull Hardware Requirements工程で数値化する。

## 6. Compute

Reference full configuration:

```text
Yura Compute
   ↓ network
Body Edge Computer
   ├ Display Endpoint (iPhone reference)
   ├ Vision / Depth
   ├ Mic Array / Audio
   ├ Sensors
   └ Real-time MCU
          ↓
        Motors
```

Body Edge Computer と MCU は責務を分離する。

## 7. Audio

完成形では専用 microphone array を設計対象とする。

理由:
- stable geometry
- sound-source localization
- beamforming
- AEC
- head movement independent acoustic frame

iPhone microphone は追加capture endpointとして利用可能だが、専用arrayを置換する前提にはしない。

## 8. Sensors

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

## 9. Handoff

Full System Design Freeze 後に、Hardware Engineer向けに別途以下を作成する。

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

本書自体は制作依頼仕様書ではない。
