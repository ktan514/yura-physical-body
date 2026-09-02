# Motion Control Responsibility Boundary

Status: Draft for Issue #6 Review
Revision: 0.1-draft

## 1. 目的

Yura System、Physical Body Edge、Real-time MCU、actuator/encoderの間で、誰が何を決めるかを固定する。

## 2. Layering

```text
Yura Body Motion / Expression Core
    ↓ CanonicalBodyState 60 Hz nominal
Physical Body Edge
    ↓ capability projection / constraint projection
Motion Target Stream >= 200 Hz
Real-time MCU
    ↓ trajectory / feedback / local safety >= 500 Hz
Actuator / Encoder / IMU
```

## 3. Yura authority

Yuraが決める:

- semantic motion
- personality-visible timing
- head orientation
- gaze
- blink
- idle micro-motion
- expression amplitude
- speech-linked acting

Yuraはservo angle、gear ratio、motor currentを扱わない。

## 4. Edge responsibility

Edgeが行う:

- Canonical quaternion → mechanism targetへのprojection
- capability range projection
- payload profile適用
- soft limit
- timestamp/freshness評価
- interpolation input generation
- constraint reason生成
- ActualBodyState aggregation

Edgeは新しいsemantic gestureを追加しない。

## 5. MCU responsibility

MCU/local motion controllerが行う:

- target interpolation
- synchronized multi-axis trajectory execution
- output feedback control
- velocity/acceleration/jerk enforcement
- local watchdog
- encoder plausibility
- current/temperature safety
- emergency stop
- hard/soft safety ceilingの最終防御

## 6. 3-axis simultaneous motion

Yaw/Pitch/Rollを独立servoとして順番に到達させてはならない。

3-axis pose targetは共通trajectory timebase上で同時に追従する。

要求:

- target quaternionから機構axis targetへのmappingは同一sample timeを使用
- axisごとの速度制約により到達時間が異なる場合、必要に応じtrajectory durationを全axisで協調させる
- 1軸だけが先に停止することで意図しない機械的gestureを生まないようにする

## 7. Kinematic mapping

Canonical authorityは3D quaternionであり、mechanical Yaw/Pitch/Rollはadapter内部表現である。

Hardware mechanismのaxisが理想直交・一点交差でない場合も、calibrated kinematic modelでCanonical head poseへmappingする。

Yuraへraw motor angleをCanonical poseとして返してはならない。

## 8. Constraint projection

BodyがDesired Stateをそのまま再現できない場合:

1. safety limit
2. mechanism range
3. velocity/acceleration/jerk
4. thermal/current derating
5. payload profile

の順でconstraintを適用する。

constraint適用後のtarget/actualとreasonをActualBodyStateで報告する。

silent clippingは禁止する。

## 9. Interpolation

Body側補間は意味生成ではない。

許可:

- sample間quaternion interpolation
- time-aligned smooth trajectory
- acceleration/jerk limiting
- actuator rate conversion

禁止:

- Yuraが出していないnod追加
- gaze先行をBodyが勝手に作る
- spontaneous blink
- idle sway追加

## 10. Motion enable gate

actuator motion enableには次が必要。

- capability negotiation完了
- calibration valid
- feedback valid
- no critical fault
- emergency stop released/reset
- accepted payload profile
- fresh CanonicalBodyState
- MCU watchdog active

## 11. Feedback path

Actual poseは少なくとも:

- output axis pose
- reconstructed Canonical head quaternion
- axis velocity
- tracking error
- limit/derating state
- timestamp

をEdgeへ提供可能にする。

IMUを使用する場合はencoderと独立したplausibility/referenceとして利用できるが、IMU単独を静的absolute joint pose authorityにしない。

## 12. Stop behavior

### SAFE_HOLD

- target progression停止
- current pose付近でzero velocityへ収束
- last desired trajectoryを継続しない

### SAFE_STOP

- controlled deceleration
- automatic home移動は原則行わない
- stop後はpassive safe support / brake / bounded holding torque

### Emergency stop

- local safety pathで最優先
- Yura/Edge acknowledgment不要

## 13. Service / calibration mode

service modeでは通常range/speed profileとは異なるtest motionを許可できる。

ただし:

- explicit local enable
- diagnostic表示
- user presence awareness
- normal Yura motionとの排他
- emergency stop有効

を必須とする。

## 14. Hardware Engineerへの実装自由度

次は要求を満たす限り任意:

- controller architecture
- motor type
- transmission
- encoder arrangement
- control law（PID/FOC/model-based等）
- trajectory generator implementation

ただし上記責務境界とsafety state semanticsは変更しない。
