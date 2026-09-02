# Full System Verification Strategy

Status: Draft Baseline v0.1

## 1. Purpose

要求 → 設計 → 実装 → 検証のTraceabilityを維持する。

Full Systemで定義した機能がV1でDeferredとなっていても、要求IDは削除しない。

## 2. Verification Levels

1. Contract validation
2. Software unit/component test
3. Hardware component test
4. Hardware-in-the-loop
5. Physical Body integration
6. Yura ↔ Physical Body integration
7. Human acceptance / behavior evaluation

## 3. Motion Verification

将来数値化する項目:
- motion range
- tracking error
- settling behavior
- minimum smooth movement
- low-speed jitter
- backlash
- acoustic noise
- latency
- simultaneous 3-axis behavior
- communication-loss transition
- repeatability

## 4. Perception Verification

- person detection/tracking
- 3D person position
- face/head/gaze
- object tracking
- hand/gesture
- depth
- sound direction
- sound tracking
- AEC
- audio-visual association
- sensor fusion latency/confidence

## 5. Boundary Verification

Simulatorを用意し、実機なしでも以下を検証可能にする。

- CanonicalBodyState stream
- Capability negotiation
- ActualBodyState
- CanonicalObservation
- stale/out-of-order handling
- disconnect/reconnect
- version compatibility

## 6. Hardware Handoff Acceptance

制作依頼時には各Hardware Requirementに対し、客観的な確認方法を割り当てる。
要求値だけで測定方法が存在しない仕様を作らない。
