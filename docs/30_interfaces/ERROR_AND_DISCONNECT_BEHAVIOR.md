# Error / Disconnect / Recovery Behavior

Status: Draft for Issue #5 Review
Revision: 0.1-draft

## 1. 目的

stale、duplicate、out-of-order、network loss、endpoint restart、Yura disconnect等が発生しても、過去のBody Stateを誤適用せず、安全性と状態整合性を維持するための状態遷移を定義する。

---

## 2. 原則

1. 古いmotion commandを「遅れて届いたから」という理由で再生しない。
2. connection復旧だけでNormalへ即復帰しない。
3. Capability / Contract / Calibration / Clock / Healthを再検証してからmotion enableする。
4. Yura disconnect中にBodyが人格的な新規motionを独自生成しない。
5. Safety controllerはnetwork/Yuraの生存に依存しない。

---

## 3. Communication lifecycle state

```text
DISCONNECTED
    ↓
CONNECTING
    ↓
AUTHENTICATING
    ↓
NEGOTIATING
    ↓
SYNCHRONIZING
    ↓
VALIDATING
    ↓
READY
    ↓
ACTIVE
```

異常時:

```text
ACTIVE
  ├─ quality低下 → DEGRADED
  ├─ state freshness喪失 → SAFE_HOLD
  ├─ critical fault → SAFE_STOP
  └─ unrecoverable → FAULT
```

復旧時:

```text
DEGRADED / SAFE_HOLD
        ↓
RECOVERING
        ↓
NEGOTIATING / SYNCHRONIZING / VALIDATING
        ↓
READY
        ↓ fresh state required
ACTIVE
```

---

## 4. Body Runtime stateとの関係

Communication lifecycleとBody Health stateは別概念だが対応する。

| Communication | Body Health例 |
|---|---|
| ACTIVE | Normal |
| DEGRADED | Degraded |
| SAFE_HOLD | Degraded / Safe Stop準備 |
| SAFE_STOP | Safe Stop |
| FAULT | Fault |

通信がREADYでもHardware faultがあればNormalにしない。

---

## 5. Sequence handling

各streamで最後にacceptedした`sequence`を保持する。

### newer

`sequence > last_accepted`なら候補として処理する。

### duplicate

`sequence == last_accepted`はduplicateとして再適用しない。

### out-of-order

`sequence < last_accepted`はlate/out-of-orderとしてdropする。

新しい`stream_id`では新sequence namespaceとして扱うが、session validation完了前にmotionへ適用しない。

---

## 6. Timestamp freshness

Sequenceが新しくてもsample timeが古ければstaleになり得る。

Receiverは:

- sequence ordering
- aligned sample time
- message age

を併用する。

ClockがUNSYNCEDでcross-device ageを安全に判定できない場合、より保守的なdegraded policyへ移行する。

---

## 7. CanonicalBodyState freshness stages

Full System reference policy:

### FRESH

latest valid state age <= **100 ms**

通常追従可能。

### STALE

> 100 ms and <= **250 ms**

- future extrapolationを停止
- latest targetへの速度を安全に減衰
- stale telemetryを記録
- 状況によりDegradedへ遷移

### LOST

> **250 ms**

- 新規人格motion追従を停止
- `SAFE_HOLD`へ遷移
- 最後のmotion trajectoryをそのまま継続しない
- #6で定義するmechanically safe hold/decelerationを適用

### SESSION LOST

application liveness/transportが **1 s** 以上回復しない、またはconnection closed

- Safe Stop policyへ進む
- Yuraとの新sessionが確立するまでNormalへ戻らない

100/250/1000 msはFull System communication policyとしてFreezeし、#6のmechanical safe behaviorと整合確認する。

---

## 8. Hold semantics

`SAFE_HOLD`は「最後のtargetを無限にservoで保持」の意味ではない。

#6で定義する安全・発熱・重力条件に応じて:

- controlled deceleration
- safe pose
- limited torque hold
- torque off

等へ変換する。

通信層は人格的なreturn-to-home motionを生成しない。

---

## 9. Duplicate reliable control

side-effectful commandはidempotency keyを持つ。

同一commandのretryは:

- 結果を再返却可能
- side effectを二重実行しない

例:

- reset
- calibration apply
- mode transition

---

## 10. Capability revision change

ACTIVE中にCapabilityが変更された場合:

1. new capability revisionを受信
2. unsupportedとなったchannelへの出力を停止
3. Yuraへ新Capabilityを通知
4. 必要ならDegradedへ遷移
5. critical motion capability lossならSAFE_HOLD/SAFE_STOP

旧Capabilityを無期限cacheして使用しない。

---

## 11. Calibration change / invalidation

Calibration revision変更中:

- dependent transformを一時invalidにできる
- affected observation qualityをlower/Unavailableへする
- motion kinematicsに影響するcalibrationならmotion enableを停止して再validationする

---

## 12. Clock degradation

### LOCKED → DEGRADED

- high-precision cross-modal fusionのqualityを下げる
- moving camera world transformへuncertaintyを反映

### DEGRADED → UNSYNCED

- cross-device sample time依存処理を停止
- source-frame observationは可能なら継続
- safetyに時刻整合が必要な機能はdegrade/disable

### RESET_DETECTED

- old mappingを破棄
- new epochとして同期し直す

---

## 13. Yura disconnect

Yuraがdisconnectした場合:

Physical Bodyは:

- safety supervision継続
- health telemetry local記録継続
- sensor acquisitionをpolicyにより継続可能
- 人格的な新規blink/idle/head/gaze motionを生成しない
- reconnectまでlast semantic actionを反復しない

必要ならneutral safe display stateへ移行するが、その表現は「ゆらの感情」と誤認されないdiagnostic/safe behaviorとして定義する。

---

## 14. Body Edge restart

Edge restart後:

1. MCUをsafe communication stateへ置く
2. endpoint rediscovery
3. local configuration load
4. calibration validity check
5. clock synchronization
6. Yura Contract negotiation
7. Capability/Health publish
8. fresh CanonicalBodyState受信
9. motion enable

restart前commandをdisk queueから再生しない。

---

## 15. MCU disconnect

MCU disconnectまたはmotion feedback lossはcriticalとする。

- Physical motionをNormal扱いしない
- Body Healthへcritical fault
- ActualBodyStateをfreshと偽らない
- safe hardware pathが利用可能なら作動

具体安全出力は#6/#8。

---

## 16. Display disconnect

Display loss自体は必ずしもmechanical critical faultではない。

Capability policyにより:

- head motion継続 + display unavailable
- speech継続
- Degradedへ移行

を許容できる。

ただしdisplay geometryがmechanical payload/calibrationに関係する場合、物理安全条件を再評価する。

---

## 17. Sensor loss

Non-critical sensor loss:

- Capability revision更新
- affected Observation停止
- Degraded operation継続可能

Critical safety sensor loss:

- SAFE_HOLD/SAFE_STOPへ移行

criticalityは#6/#7/#8でsensorごとに定義する。

---

## 18. Reconnect safety gate

Reconnect後にACTIVEへ戻るための必須gate:

- authenticated peer
- compatible Contract version
- valid session/stream IDs
- acceptable clock state
- current Capability snapshot
- required Calibration valid
- no blocking critical fault
- fresh CanonicalBodyState受信

一つでも不成立ならACTIVEへ移行しない。

---

## 19. Fresh-state gate

Reconnect後、以前のlast stateではなく**新sessionで生成されたfresh CanonicalBodyState**を少なくとも1件受信してからmotion enableする。

これによりreconnect直後のold target replayを防ぐ。

---

## 20. Partial recovery

全Capabilityが戻らなくても安全であればDEGRADEDとして復帰可能。

例:

- depth camera unavailable
- one optional touch sensor unavailable

ただしYuraへ新Capabilityを通知し、利用可能と仮定させない。

---

## 21. Fault reason

state transitionにはmachine-readable reasonを付与する。

例:

- `STATE_STALE`
- `YURA_DISCONNECTED`
- `CLOCK_UNSYNCED`
- `CAPABILITY_CHANGED`
- `CALIBRATION_INVALID`
- `MCU_LOST`
- `MOTION_FEEDBACK_LOST`
- `AUTH_FAILED`
- `PROTOCOL_INCOMPATIBLE`

human-readable diagnosticsも併記可能。

---

## 22. Recovery hysteresis

network/clock qualityがthreshold付近で揺れる場合にNormal/Degradedを高速反復しないようhysteresis/debounceを実装する。

具体値は#8実装時に決定できるが、安全側遷移を遅らせる用途には使用しない。

---

## 23. Fault injection verification

最低限次を試験する。

- duplicate state
- reverse order state
- delayed state
- 100 ms超delay
- 250 ms超state loss
- connection 1 s以上loss
- 1%/5% packet loss
- clock jump/reset
- capability revision change
- calibration invalidation
- Yura restart
- Edge restart
- MCU disconnect
- Display disconnect
- non-critical sensor loss

---

## 24. Freeze事項

Issue #5で次をFreezeする。

- sequence older/duplicateは再適用しない
- Body State latest-wins
- FRESH <= 100 ms
- STALE >100–250 ms
- LOST >250 msでSAFE_HOLD
- session/liveness loss 1 sでSafe Stop系へ遷移
- reconnect時にContract/Clock/Capability/Calibration/Healthを再validation
- fresh-state gate通過前にmotion enableしない
- restart前commandをreplayしない
- Yura disconnect中に人格motionをBody側で生成しない
