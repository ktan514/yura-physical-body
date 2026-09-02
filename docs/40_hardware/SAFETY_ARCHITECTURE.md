# Physical Body Safety Architecture

Status: Draft for Issue #6 Review
Revision: 0.1-draft

## 1. 目的

Physical Bodyが人の近傍で動作することを前提に、motion、power、communication、feedback、thermal、mechanical hazardに対する安全設計原則と状態遷移を定義する。

本書は法規適合宣言ではない。Design Freeze時点で適用規格・販売形態・電源・無線・接触条件を再評価する。

## 2. Safety design principle

安全設計は次の順で行う。

1. hazardを機構・配置・低energy化で可能な限り除去する
2. 残留hazardをguard / limit / monitoring / fail-safeで低減する
3. softwareだけに依存しないlocal protectionを設ける
4. 残留riskをtest可能なacceptance conditionへ落とす

参考とする安全設計体系:

- ISO 12100:2010 および後継版のrisk assessment / risk reduction原則
- ISO 13482:2014、および2026年時点で承認段階のISO/FDIS 13482
- ISO/TR 23482-1:2020 のsafety-related test methods

## 3. Safety authority

### 3.1 Yura System

YuraはDesired Body Stateを生成するが、最終的なhardware safety authorityではない。

### 3.2 Body Edge

Body Edgeは:

- freshness判断
- capability projection
- soft limit
- health aggregation
- safe-state request

を担う。

### 3.3 Real-time MCU / local safety layer

MCUまたは同等のlocal safety layerはnetwork/Yura/Edgeが停止しても次を継続する。

- actuator watchdog
- hard/soft range enforcementの最終段
- velocity/acceleration ceiling
- over-current / over-temperature reaction
- encoder plausibility
- emergency stop input
- controlled stop / torque disable decision

## 4. Safety states

少なくとも次を区別する。

### NORMAL

- fresh targetあり
- feedback valid
- calibration valid
- safety monitor正常

### DEGRADED

例:

- sensor一部loss
- clock quality degraded
- payload profile fallback
- non-critical endpoint loss

利用可能Capabilityを縮小し、必要に応じmotion range/speedをderateする。

### SAFE_HOLD

目的は「古い指令を続行しない」ことである。

entry例:

- Canonical Body State age >250 ms
- target stream invalid
- transient network loss

behavior:

- 新しいtrajectory progressionを停止
- 現在actual pose付近へvelocityを0に収束
- new semantic motionを生成しない
- holding torqueは必要最小限
- automatic home motionは行わない

### SAFE_STOP

entry例:

- Yura/Body session liveness loss >=1 s
- critical sensor/feedback degradation
- explicit safety stop request

behavior:

- controlled deceleration
- current poseで停止することを基本とする
- safety analysisで明示された場合のみpark poseへ移動
- stop後、gravity-safeな方法でposeを維持またはde-energize

### FAULT

例:

- encoder invalid
- actuator driver fault
- over-temperature critical
- repeated watchdog
- calibration corruption

normal motionを再enableせず、diagnostic/recovery procedureを要求する。

### EMERGENCY_STOP

人またはlocal safety chainからの緊急停止。

network round tripやYura判断を待ってはならない。

## 5. Emergency stop performance

local emergency-stop inputが成立してから:

- safety controllerがstop reactionを開始: **50 ms以内**
- maximum normal commanded speed、maximum supported payloadで、motion cessation: **300 ms以内**
- stop reaction開始後の追加angular travel: **15°以下**

上記を満たすため、emergency decelerationはnormal expression用acceleration limitを超えてよい。ただしtip-over、mechanical stress、payload脱落を生じてはならない。

Emergency Stop解除だけでnormal motionへ自動復帰してはならない。明示的reset、health check、fresh-state gateを通す。

## 6. Watchdog

MCU/local safety controllerはEdge target更新に対する独立watchdogを持つ。

- watchdog timeout ceiling: **100 ms**

watchdog timeout時:

1. target progression停止
2. velocity commandを0へ収束
3. Edgeへfault/degraded event通知
4. 通信状態に応じSAFE_HOLDまたはSAFE_STOPへ遷移

watchdogはOS process schedulingやcloud availabilityに依存してはならない。

## 7. Power loss / brownout

### 7.1 Prohibition

電源喪失時にDisplay Endpointまたはhead assemblyがfree-fall / uncontrolled rotationしてはならない。

### 7.2 Required means

mechanismは少なくとも次のいずれか、または組合せでgravity hazardを抑える。

- passive counterbalance
- spring balance
- normally-engaged brake
- self-locking / non-backdrivable transmission（fine-motion/quietness requirementsと両立する場合）
- mechanical damper
- safe physical stop

### 7.3 Torque-off condition

actuator torque-offは、torqueを失っても:

- endpointが落下しない
- uncontrolled accelerationしない
- cableを破損しない
- user contact hazardを増加させない

ことがmechanical designで確認できる場合のみ正常safe behaviorとして使用する。

## 8. Pinch / shear / entrapment

### 8.1 Design intent

powered normal operationで人との意図的接触はFull Systemの基本要求ではない。

したがって、接触力を制御して安全を成立させるより、まずaccessible pinch/shear zoneを機構的に除去・guardする。

### 8.2 Requirements

- normal operating rangeで指・皮膚・髪・衣服を巻き込む開口・shear edgeを最小化する
- moving gapを外装でguardできる場合はguardを優先する
- cable entryがpinch pointにならない
- residual accessible hazardはrisk assessmentで明示する
- final probe dimension / allowed contact force / energy値は#9で適用規格とmechanism geometryを基にFreezeする

`PAR-MOT-021` / `PAR-MOT-022` / `PAR-SAF-005` はこの理由により#6では無根拠に数値固定しない。

## 9. Stability / payload retention

- tip-over requirementは `MOTION_MECHANICAL_REQUIREMENTS.md` に従う
- Display Endpoint mountはmaximum supported payloadを全normal pose・maximum normal accelerationで保持する
- mount releaseは意図的なservice actionなしに発生してはならない
- magnetのみで保持する場合もsecondary retentionまたは十分なretention marginを示す
- cable tensionがmount release方向へ直接作用しないroutingとする

## 10. Thermal / current protection

actuator / driver / power pathは少なくとも:

- current monitoring
- driver fault
- temperature monitoring
- warning threshold
- derating threshold
- stop threshold

を持つ。

具体温度値は選定component ratingへ依存するため、component selection前には固定しない。

原則:

- warning/derating/stopはmanufacturer absolute maximumより十分低いmarginで設定する
- thermal protectionでreal-time safety loopを停止させない
- fan等のactive cooling故障がunsafe motionへ直結しない

## 11. Calibration safety

normal motion enable条件:

- axis feedback valid
- calibration revision valid
- payload profile accepted
- hard/soft limit relation valid
- home/absolute pose plausibility valid

calibration失敗・unknown payloadではFull range/high-speed motionを許可しない。

## 12. Fault classification

### Critical

- MCU loss
- actuator feedback loss
- impossible encoder jump
- emergency stop
- over-current critical
- over-temperature critical
- mechanical limit violation

→ SAFE_STOPまたはFAULT。

### Non-critical

- one camera loss
- display diagnostics loss
- non-safety sensor loss

→ DEGRADED可能。

## 13. Recovery

FAULT/EMERGENCY_STOPからのrecoveryには少なくとも:

1. cause cleared
2. local safety input reset
3. actuator/feedback self-check
4. calibration validity確認
5. Body Capability再発行
6. fresh Canonical Body State受信
7. motion enable

を要求する。

過去buffered motionの再生は禁止する。

## 14. Risk assessment artifact

#9までに、少なくとも次のhazardをrisk registerへ登録する。

- pinch/shear
- impact
- endpoint drop
- tip-over
- cable entanglement
- electrical/brownout
- battery/charger（採用時）
- thermal burn
- unexpected restart
- encoder/control runaway
- network stale motion
- maintenance mode motion

各hazardはcause / hazardous situation / severity / exposure / avoidance / mitigation / verificationへtraceする。
