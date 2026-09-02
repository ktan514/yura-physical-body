# Physical Perception Architecture

Status: Draft Baseline v0.1

## 1. Principle

Physical Body は感覚信号を取得・測定・追跡・融合する。
人格的・意味的判断はYura Systemで行う。

例:
- Body: `person track #2 is at (x,y,z)`
- Yura: `その人物は人間さんである`
- Body: `sound source track #4 is at azimuth θ`
- Yura: `誰かが呼びかけたので振り向く`

## 2. Vision Pipeline

Full System設計対象:

```text
RGB / Depth
   ↓
Frame synchronization
   ↓
Detection
   ├ Person
   ├ Face
   ├ Hand
   └ Object
   ↓
Tracking
   ↓
Pose / Landmark / Gaze
   ↓
3D spatialization
   ↓
Sensor Fusion
   ↓
Canonical Observation
```

## 3. Person

Observation候補:
- track_id
- position 3D
- velocity
- body bounding volume
- body pose
- head pose
- face location
- gaze estimate
- confidence
- visibility / occlusion state

## 4. Object

Observation候補:
- track_id
- class/category
- position
- orientation where available
- size
- velocity
- confidence
- visible / occluded state

Yura側で所有者・名称・意味記憶と関連付ける。

## 5. Hand / Gesture

Full Systemでは以下をslotとして持つ。
- left/right hand
- position
- pose
- motion
- gesture candidate
- confidence

Gestureの社会的意味解釈はYura側。

## 6. Depth

Depth sensing をFull Systemに含める。

利用目的:
- person distance
- object world position
- proximity
- occlusion reasoning support
- coordinate calibration support

具体方式は未固定。

## 7. Audio Pipeline

```text
Mic Array
   ↓
capture / synchronization
   ↓
AEC
   ↓
noise processing
   ↓
VAD
   ↓
beamforming
   ↓
DOA / localization
   ↓
source tracking
   ↓
audio-visual association
   ↓
Canonical Observation
```

## 8. Acoustic Echo Cancellation

Yura自身のSpeaker出力をReference signalとして利用し、自声の再入力を抑制可能とする。

Full Systemではbarge-in（Yura発話中の人間発話検知）を阻害しない設計を目標とする。

## 9. Sound Source Tracking

単発角度ではなく継続trackとして扱う。

Observation候補:
- track_id
- azimuth
- elevation where available
- estimated position where available
- energy
- voice probability
- confidence
- linked person track candidate

## 10. Sensor Fusion

融合対象:
- visual person track
- face/head/gaze
- depth
- sound source
- touch
- proximity
- IMU
- body pose / encoder state

Sensor Fusionは測定・track associationまでを責務とし、Yuraの人格判断を行わない。

## 11. AI / Classical Processing

方式は機能ごとに選定する。

- DSPで十分なものはDSP
- Classical CVで十分なものはClassical CV
- 軽量認識モデルが実用上妥当なものはlocal perception model

生成AIを不要な測定処理へ導入しない。
一方、AIを使わないこと自体を目的化して精度・保守性を損なわない。
