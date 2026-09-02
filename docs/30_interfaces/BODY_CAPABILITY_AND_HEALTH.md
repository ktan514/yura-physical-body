# Body Capability / Actual State / Health

Status: Draft for Issue #4 Review
Revision: 0.1-draft

## 1. 目的

本書はBodyが「何を再現・観測できるか」「実際に何を再現できているか」「現在健全か」をYuraへ伝える共通modelを定義する。

---

## 2. BodyCapabilitySnapshot

Body Capabilityは接続時だけの固定値ではない。
Endpoint loss、degraded mode、device交換等により変化し得るためrevision付きsnapshotとする。

```text
BodyCapabilitySnapshot
├─ envelope
├─ body_instance_id
├─ profile_id
├─ capability_revision
├─ contract_versions
├─ body_channels
├─ observation_capabilities
├─ endpoints
├─ stream_limits
└─ extensions
```

---

## 3. Body channel capability

各Canonical Body channelについて少なくとも次を表現可能にする。

```text
BodyChannelCapability
├─ channel_id
├─ support
│  ├─ supported
│  ├─ unsupported
│  └─ temporarily_unavailable
├─ feedback_available
├─ range?
├─ resolution?
├─ nominal_update_rate_hz?
├─ maximum_update_rate_hz?
└─ constraints?
```

### 例

Physical Body:

```text
head.pose.orientation   supported
head.pose.position      unsupported
eyes                    supported
eyebrows                supported
mouth                    unsupported
torso                    unsupported
```

Live2D Body:

```text
head.pose.orientation   supported
head.pose.position      implementation dependent
eyes                    supported
eyebrows                supported
mouth                    supported
torso                    supported/partial
```

---

## 4. Partial capability

単純なbooleanだけではなくpartial supportを表現できる。

例:

- head orientationは3DoFのみ
- gazeは2D display projectionのみ
- eyebrowはinner/outer heightのみ
- depth cameraは現在offline

Canonical channelの一部しか再現できない場合、subchannel単位でCapabilityを宣言する。

---

## 5. Observation capability

```text
ObservationCapability
├─ observation_type
├─ support
├─ source_endpoint_ids[]
├─ nominal_rate_hz?
├─ maximum_rate_hz?
├─ operating_envelope_ref?
├─ quality_metrics_supported[]
└─ raw_media_reference_available?
```

認識精度そのものはRequirement Parameter Registerの受入条件とし、Capabilityだけで「精度保証済み」を意味しない。

---

## 6. Endpoint descriptor

```text
EndpointDescriptor
├─ endpoint_id
├─ endpoint_type
│  ├─ display
│  ├─ camera
│  ├─ depth
│  ├─ microphone
│  ├─ speaker
│  ├─ sensor
│  ├─ motion_controller
│  └─ other
├─ vendor/model?
├─ hardware_revision?
├─ firmware_version?
├─ software_version?
├─ capabilities[]
└─ connection_state
```

Endpoint modelは#8で詳細化する。

---

## 7. ActualBodyState

`ActualBodyState` はBodyが実際に再現しているCanonical stateのfeedbackである。

```text
ActualBodyState
├─ envelope
├─ body_instance_id
├─ applied_desired_stream_id?
├─ applied_desired_sequence?
├─ actual_state
├─ tracking
├─ applied_constraints[]
└─ quality
```

`actual_state`は`CanonicalBodyState`と同じcanonical channel意味論を再利用する。

ただしBodyが実測できないchannelについて、Desired値をActual値としてコピーしてはならない。

---

## 8. Tracking metadata

```text
tracking
├─ per_channel[]
│  ├─ channel_id
│  ├─ feedback_status
│  ├─ error?
│  ├─ saturated?
│  ├─ limited?
│  └─ limit_reason?
└─ aggregate_status
```

### 例

Yura Desired:

```text
head orientation = target A
```

Physical Body:

```text
kinematic projection
→ roll limit適用
→ encoder actual pose B
```

Bodyは`ActualBodyState=B`と、constraint適用情報を返す。

---

## 9. Constraint reason

Canonical Body Stateを完全再現できなかった場合、理由を機械可読にする。

例:

- unsupported_channel
- soft_limit
- hard_limit_guard
- velocity_limit
- acceleration_limit
- thermal_derating
- current_limit
- collision_safety
- degraded_mode
- calibration_invalid
- endpoint_unavailable

詳細code registryは#6/#8で拡張する。

---

## 10. BodyHealthSnapshot

```text
BodyHealthSnapshot
├─ envelope
├─ body_instance_id
├─ health_revision
├─ overall_state
├─ safety_state
├─ component_health[]
├─ active_faults[]
├─ warnings[]
├─ calibration_state
└─ resource_state?
```

---

## 11. Overall state

Full Systemの基本stateを次とする。

- `normal`
- `degraded`
- `safe_stop`
- `fault`

意味:

### normal

宣言Capabilityが通常条件で利用可能。

### degraded

一部Capabilityを失ったが、残存機能を安全に利用可能。

### safe_stop

通常動作を停止し、安全維持処理のみ実行。

### fault

安全または機能成立上の重大異常。手動/自動recoveryが必要。

状態遷移条件は#5/#6/#8でFreezeする。

---

## 12. Component health

```text
ComponentHealth
├─ component_id
├─ component_type
├─ state
│  ├─ ok
│  ├─ warning
│  ├─ degraded
│  ├─ failed
│  └─ unknown
├─ telemetry?
├─ last_update
└─ detail_codes[]
```

---

## 13. Fault model

```text
Fault
├─ fault_id
├─ fault_code
├─ severity
├─ component_id?
├─ detected_at
├─ active
├─ recoverable
├─ automatic_action?
└─ detail?
```

Severity例:

- info
- warning
- error
- critical

critical faultの具体条件はSafety Designで定義する。

---

## 14. Calibration state

```text
CalibrationState
├─ overall_valid
├─ active_revision
├─ calibrated_at?
├─ component_entries[]
└─ invalid_reasons[]
```

Calibration invalidなsensor/axisを正常値として扱わない。

---

## 15. Capability change lifecycle

例: depth camera故障

```text
1. BodyHealth: camera failed
2. Capability revision N→N+1
3. depth observation capability = temporarily_unavailable
4. 既存depth trackをunavailable/endへ遷移
5. Yuraは新Capabilityを基に動作を継続
```

Capabilityを失ったBodyが古いCapability snapshotのまま正常に見せ続けてはならない。

---

## 16. Reconnect

Endpoint reconnect時、BodyはすぐにCapabilityを復活させるとは限らない。

必要に応じて、

- device identification
- firmware/version check
- calibration check
- self-test
- time synchronization

完了後にCapability revisionを更新する。

---

## 17. Body instance identity

`body_instance_id`はPhysical個体/Body runtime instanceを識別する。

人物人格identityとして使用しない。

同じYuraが別Bodyへ接続した場合、Yura人格そのものが変わった扱いにはしない。

---

## 18. Capability negotiation principle

Yuraは接続時にCapabilityを取得し、少なくとも次を確認する。

- compatible contract version
- core Body channels
- Actual State feedback availability
- observation capabilities
- endpoint health
- stream limits

必須Capability不足時の接続拒否/限定接続policyは#5で定義する。

---

## 19. Unknown capability

Consumerが未知optional capabilityを受け取った場合、既知Capabilityを利用継続する。

未知Capabilityを既知Capabilityへ勝手に読み替えない。

未知Capabilityがsession成立に必須であることをBodyが要求する場合はnegotiation failureとする。
