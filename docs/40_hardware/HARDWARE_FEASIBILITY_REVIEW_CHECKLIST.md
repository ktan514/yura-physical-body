# Hardware Feasibility Review Checklist

Status: Draft for Issue #6 Review
Revision: 0.1-draft

## 1. 目的

Hardware Engineerが#6の要求を受け取り、具体機構へ落とす前に実現性・trade-off・追加情報を確認するためのchecklist。

本書は機構案の回答templateとして利用できる。

## 2. Mechanism concept

- [ ] Yaw / Pitch / Roll 3DoFを同時連続制御できる
- [ ] normal usable rangeを満たす
- [ ] hard stopより先にcable/connectorが損傷しない
- [ ] center of mass / gravity torqueを十分抑えられる
- [ ] nominal/max payloadを保持できる
- [ ] Display Endpointを保守交換できる

提案mechanism:

- axis arrangement:
- transmission:
- counterbalance/brake:
- estimated moving mass:
- estimated inertia:

## 3. Actuation

- [ ] 120°/s normal maximumを満たせる
- [ ] 360°/s² / 2000°/s³のnormal profileを満たせる
- [ ] low-speed 0.25° motionを滑らかに再現可能
- [ ] static/dynamic tracking errorを満たせる見込み
- [ ] output pose sensing <=0.1° equivalentを実現可能
- [ ] backlash <=0.5° equivalentを実現可能
- [ ] 0.5mで32dBA級のnormal motionを実現できる見込み

候補actuator:

- Yaw:
- Pitch:
- Roll:

## 4. Thermal / torque margin

- [ ] nominal payload worst poseでstatic holding torque <=35% continuous rating
- [ ] maximum payload worst poseで<=50% continuous rating
- [ ] continuous micro-motionでthermal saturationしない
- [ ] current/temperature telemetryを取得可能

必要なcountermeasure:

- 

## 5. Safety

- [ ] power loss時にfree-fallしない
- [ ] local watchdog <=100msを実現可能
- [ ] emergency stop reaction <=50msを実現可能
- [ ] stop <=300ms / additional travel <=15°を満たせる見込み
- [ ] pinch/shear zoneをguard/eliminateできる
- [ ] normal motionでhard stopへ依存しない
- [ ] tip-over factor >=1.5を実現できる
- [ ] 10N incidental horizontal-force testを満たせる

residual hazard:

- 

## 6. Cable / serviceability

- [ ] full normal rangeでcable tension/pinchなし
- [ ] manufacturer bend radiusを確保
- [ ] representative motion 1,000,000 cyclesを狙える構成
- [ ] Display Endpoint交換時に機構分解が最小限
- [ ] calibration procedureを実行可能

## 7. Control / MCU

- [ ] Edge target >=200Hzを受けられる
- [ ] inner/effective loop >=500Hz
- [ ] 3軸同期trajectoryを実行可能
- [ ] encoder plausibility/faultをlocal判定可能
- [ ] emergency stopをnetwork非依存で処理可能

## 8. Trade-offs / blockers

要求を満たすうえでtrade-offまたはblockerがある場合、要求を黙って緩和せず以下を記録する。

| Requirement / Parameter | Concern | Proposed alternative | Impact |
|---|---|---|---|
| | | | |

## 9. Hardware Engineer review outcome

- [ ] Feasible as written
- [ ] Feasible with minor design clarification
- [ ] Requirement trade-off review required
- [ ] Major architecture conflict

Notes:

- 
