# 3DoF Motion / Mechanical Requirements

Status: Draft for Issue #6 Review
Revision: 0.2-draft

## 1. 目的

本書は Yura Physical Body の Head Yaw / Pitch / Roll 3DoFについて、ハードウェア技術者が機構・actuator・bearing・transmission・counterbalance・cable routingを選定できる入力要求を定義する。

本書は gimbal、parallel linkage、spherical mechanism、direct drive、belt/gear drive等の具体方式を固定しない。

Canonical Body State、座標系、通信・freshness policyは `docs/30_interfaces/` を正本とする。

## 2. 設計優先順位

次の順を基本優先順位とする。

1. 人の近傍での安全性
2. power loss / communication loss時の予測可能性
3. 低速・微小運動の滑らかさ
4. 静音性
5. Actual pose feedback / repeatability
6. 低backlash・低jitter
7. thermal margin
8. serviceability / cable life
9. 最大速度

最高速度を得るために1〜8を犠牲にしてはならない。

## 3. Reference payload boundary

### 3.1 Display Endpoint payload

Display Endpoint mountに載る交換可能payloadを次で設計する。

- nominal removable payload: **350 g以下**
- maximum supported removable payload: **500 g以下**

removable payloadにはreference phone、case、交換adapter、endpoint側小型sensor等を含める。

機構自身のmoving massはこの値に含めない。Hardware Engineerはmoving assembly全体のmass/inertiaを別途算定する。

### 3.2 Payload交換

payload交換後は次を再評価または再calibrationできなければならない。

- mass / inertia class
- center of mass
- zero/home
- usable range
- velocity/acceleration limit
- tracking controller parameters
- safety limit

最大payloadを装着しただけでnominal expressive性能を必ず満たすことは要求しない。Capabilityは実際のpayload profileに応じてdegrade可能とする。

## 4. Normal usable range

正面neutralを含む通常使用可能範囲として、少なくとも次を提供する。

| Axis | Minimum normal usable range |
|---|---|
| Yaw | **左右合計180°以上**。左右配分は機構設計で決定し、左右いずれにも十分な振り向き量を確保する |
| Pitch | 上方向 **25°以上**、下方向 **30°以上** |
| Roll | 左右それぞれ **20°以上** |

Yawは360°連続回転を必須としない。normal usable rangeはYuraが通常表現として利用できる範囲であり、hard mechanical stop位置ではない。

各軸の実際のrangeはCapabilityとして報告する。

## 5. Soft / hard limit

- software soft limitはnormal usable rangeを包含する。
- physical hard limitまたは同等のmechanical protectionをsoft limit外側に持つ。
- soft limitとdamage thresholdの間に、encoder error・controller overshoot・calibration誤差を吸収する安全marginを持たせる。
- hard stopへ通常運転で衝突してはならない。
- cable、connector、flex PCB、sensor harnessがhard stopより先に損傷する構成を禁止する。
- calibration失敗時はnormal motionをenableしない。

## 6. Motion performance

### 6.1 Velocity

- nominal expressive angular velocity: **60°/s以下を中心に使用**
- maximum normal commanded angular velocity: **120°/s**
- maintenance/test modeでこれを超える場合、通常人格motionから分離し、明示的service modeとする。

### 6.2 Acceleration / jerk

normal motionにおける上限:

- angular acceleration: **360°/s²**
- angular jerk: **2000°/s³**

Emergency/Safety stopでは安全上必要な範囲でnormal limitを超えるdecelerationを許可するが、構造・payload・tip-over限界を超えてはならない。

### 6.3 Tracking accuracy

nominal payload、25±5°C、通常姿勢範囲で次を目標とする。

- static steady-state pose error: **各軸 ±0.5°以内**
- nominal expressive motion中 dynamic tracking error: **p95 2.0°以内**
- repeated target repeatability: **±0.5°以内**

ActualBodyStateには制約適用後のactual poseとtracking qualityを報告可能にする。

### 6.4 Fine motion

- **0.25°** の単軸target変化をstick-slipで失わず、方向を反転せず追従可能であること。
- 5°/s以下のlow-speed motionおよびhold状態で、encoderまたは外部光学計測によるuncommanded peak-to-peak jitterを **0.30°以下** とする。
- reversal testで観測されるmechanical backlash equivalentを **0.50°以下** とする。

微小motion qualityはencoderだけでなく、display centerまたは代表visible pointの外部光学計測でも確認する。

## 7. Response / control rates

### 7.1 Edge → MCU

Edgeからreal-time motion controllerへのtarget updateは **200 Hz以上**を設計下限とする。

### 7.2 MCU inner loop

actuator inner control loopは **500 Hz以上**を設計下限とし、1 kHz級をreference targetとする。

actuator内蔵servo loopを利用する場合、同等のeffective loop性能とwatchdog/safety control accessを示せればよい。

### 7.3 Physical response latency

reference local network、nominal workload、nominal payloadでCanonicalBodyState生成からactual head motion onsetまで:

- p50: **35 ms以下**
- p95: **60 ms以下**
- p99: **100 ms以下**

意図的なYura側motion timing/holdはlatency測定から除外し、通信・projection・trajectory・actuator responseを測定する。

## 8. Gravity / balance / thermal headroom

### 8.1 Principle

Display Endpointのcenter of massと有効回転中心を可能な限り近づける。

ただし特定mechanism geometryを強制しないため、最終判定はstatic holding torque ratioで行う。

### 8.2 Static holding torque ratio

25±5°C、neutralを除くworst normal poseで、gravity等によるstatic holding torqueは当該axis actuatorの連続許容torqueに対し:

- nominal payload: **35%以下**
- maximum payload: **50%以下**

を設計目標とする。

これを満たせない場合、counterbalance、spring、mass distribution、gear ratio、brake等でthermal/quietness/fine-motion headroomを確保する。

## 9. Position feedback / calibration

各powered axisはoutput poseを推定可能なclosed-loop feedbackを持つ。

要求:

- output pose equivalent sensing resolution: **0.1°以下**
- reboot後にabsolute poseを取得できる、またはsafe homing/calibrationで復元できる
- homing中はnormal Yura motionを禁止する
- encoder disagreement / impossible jump / missing feedbackをfaultとして検出する
- calibration revisionをBody Health/CalibrationDataへ反映可能とする

Motor internal encoderのみでoutput backlash後のposeを観測できない構成では、要求精度を満たせることを解析・実測で示す。

## 10. Mechanical stability

### 10.1 Static stability

最大payload、worst normal pose、想定cable loadを含む静的overturning momentに対し **1.5以上**のstability factorを持つ。

### 10.2 Incidental desk contact

平坦な水平desk上、worst normal pose、maximum payloadでdisplay center相当位置へ水平方向 **10 N** を2秒間quasi-staticに加えてもtip-overしてはならない。

滑りが先に発生する場合は、滑り自体が危険な落下・cable pullを生じないことを確認する。

## 11. Cable / flex life

- full normal rangeでcable tension、pinch、sharp bendingを発生させない。
- minimum bend radiusはcable/component manufacturer specification以上とする。
- Yaw無限回転は要求しない。
- **左右合計180°以上のYaw通常可動域**で配線寿命を成立させる。
- slip ring採用は任意。
- representative expressive motion profileで **1,000,000 motion cycles** をdesign life targetとする。
- endurance test後に断線、接触不良、insulation damage、calibration drift、motion quality悪化がacceptance limitを超えてはならない。

## 12. Acoustic requirement

quiet desk environmentでの存在感を優先する。

測定条件:

- microphone: mechanismから0.5 m
- background LAeq: 25 dBA以下を目標
- nominal payload
- normal expressive trajectory

要求:

- normal expressive motion LAeq: **32 dBA以下**
- normal range内のworst non-service motion LAFmax: **40 dBA以下**

service/calibration test motionは別profileとする。

Audio perception #7ではmotor/gear/fan noiseがAEC/DOA/VADへ与える影響も評価する。

## 13. Mechanism freedom

Hardware Engineerは本要求を満たす限り、次を自由に選択できる。

- direct drive / geared drive / belt drive
- brushless / stepper / servo等のactuation technology
- gimbal / linkage / spherical mechanism
- bearing layout
- spring / counterweight / brake
- structural material
- encoder arrangement

ただしopen-loopでActual poseを保証できない方式、power loss時にfree-fallする方式、通常運転でhard stopへ依存する方式は不可とする。

## 14. Acceptance trace

本書の各数値は `REQUIREMENT_PARAMETER_REGISTER.md` のPAR-*へ対応させ、#9でAcceptance Test Specificationへ変換する。
