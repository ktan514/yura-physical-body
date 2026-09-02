# Body Contract Abstract Data Model

Status: Draft for Issue #4 Review
Revision: 0.1-draft

## 1. 目的

本書はserialization/transportに依存しないBody Contractの抽象schemaを定義する。

JSON / Protobuf / MessagePack等の具体wire形式は#5以降で選定する。

---

## 2. Primitive types

| Type | 意味 |
|---|---|
| `Bool` | true/false |
| `String` | UTF-8論理文字列 |
| `OpaqueId` | 意味を持たない識別子 |
| `UInt64` | 非負整数sequence等 |
| `Real` | 有限実数。NaN/Infinityは原則invalid |
| `Timestamp` | source clockに紐づく時刻値 |
| `Duration` | 非負時間量 |

具体bit幅はwire format設計で固定する。

---

## 3. Common value types

### Vec3

| Field | Type | Required |
|---|---|---|
| x | Real | yes |
| y | Real | yes |
| z | Real | yes |

### Quaternion

| Field | Type | Required |
|---|---|---|
| x | Real | yes |
| y | Real | yes |
| z | Real | yes |
| w | Real | yes |

Constraint: normalized within tolerance defined by#5/#9 conformance test.

### Pose3

| Field | Type | Required |
|---|---|---|
| frame_id | String | yes |
| position_m | Vec3 | yes |
| orientation | Quaternion | yes |

### Quality

| Field | Type | Required |
|---|---|---|
| status | enum(valid,degraded,unavailable,invalid) | yes |
| confidence | Real 0..1 | no |
| uncertainty | object | no |
| visibility | Real 0..1 | no |
| occlusion | Real 0..1 | no |

---

## 4. MessageEnvelope

| Field | Type | Required |
|---|---|---|
| contract_version | String | yes |
| message_id | OpaqueId | yes |
| stream_id | OpaqueId | yes |
| sequence | UInt64 | yes |
| source_id | OpaqueId | yes |
| sampled_at | Timestamp | yes |
| generated_at | Timestamp | yes |
| source_clock_id | OpaqueId | yes |
| trace_id | OpaqueId | no |

---

## 5. CanonicalBodyState

| Field | Type | Required |
|---|---|---|
| envelope | MessageEnvelope | yes |
| profile_id | String | yes |
| root | Pose3 | profile dependent |
| head | HeadState | core profile: yes |
| gaze | GazeState | core profile: yes |
| face | FaceState | core profile: yes |
| nodes | map<String, NodeState> | no |
| speech_sync | SpeechSync | no |
| extensions | namespaced map | no |

### HeadState

| Field | Type | Required |
|---|---|---|
| pose | Pose3 | yes |

### GazeState

| Field | Type | Required |
|---|---|---|
| mode | enum(target_point,direction) | yes |
| frame_id | String | yes |
| target_point_m | Vec3 | iff mode=target_point |
| direction_unit | Vec3 | iff mode=direction |
| convergence_distance_m | Real >=0 | no |
| target_ref | OpaqueId | no |

Exactly one authority geometry corresponding to `mode` is required.

### EyeState

| Field | Type | Range | Required |
|---|---|---|---|
| openness | Real | 0..1 | yes |
| squint | Real | 0..1 | yes |
| pupil_scale | Real | 0..1 | no |
| iris_visibility | Real | 0..1 | no |

### EyesState

| Field | Type | Required |
|---|---|---|
| left | EyeState | yes |
| right | EyeState | yes |

### EyebrowState

| Field | Type | Range | Required |
|---|---|---|---|
| inner_height | Real | -1..1 | yes |
| outer_height | Real | -1..1 | yes |
| compression | Real | -1..1 | yes |
| depth_or_arch | Real | -1..1 | no |

### EyebrowsState

| Field | Type | Required |
|---|---|---|
| left | EyebrowState | yes |
| right | EyebrowState | yes |

### FaceState

| Field | Type | Required |
|---|---|---|
| eyes | EyesState | core profile: yes |
| eyebrows | EyebrowsState | core profile: yes |
| mouth | MouthState | no |

Physical Reference Profileはmouthをunsupportedとする。

### SpeechSync

| Field | Type | Required |
|---|---|---|
| utterance_id | OpaqueId | yes |
| speaking | Bool | yes |
| media_time_s | Real >=0 | yes |
| amplitude_envelope | Real 0..1 | no |
| phase | String | no |

---

## 6. CanonicalObservationBatch

| Field | Type | Required |
|---|---|---|
| envelope | MessageEnvelope | yes |
| observations | list<Observation> | yes |
| batch_quality | Quality | no |

Empty observation list is valid heartbeat/update if protocol allows it; transport policy is#5で確定する。

### Observation common

| Field | Type | Required |
|---|---|---|
| observation_id | OpaqueId | yes |
| type | String/registered enum | yes |
| observed_at | Timestamp | yes |
| source_endpoint_ids | list<OpaqueId> | yes |
| source_frame_refs | list<OpaqueId> | no |
| frame_id | String | spatial type: yes |
| quality | Quality | yes |
| provenance | Provenance | yes |
| track_ref | TrackRef | tracked type: yes |
| payload | type-specific object | yes |

---

## 7. TrackRef

| Field | Type | Required |
|---|---|---|
| track_id | OpaqueId | yes |
| track_type | String | yes |
| track_epoch | UInt64 | yes |
| lifecycle_state | enum(new,active,occluded,lost,ended) | yes |

`track_id + track_epoch`で再利用ambiguityを避ける。

---

## 8. Provenance

| Field | Type | Required |
|---|---|---|
| pipeline_id | String | yes |
| pipeline_version | String | yes |
| algorithm_id | String | no |
| model_id | String | no |
| model_version | String | no |
| calibration_revision | String | no |
| transform_revision | String | no |
| source_media_refs | list<OpaqueId> | no |

---

## 9. ActualBodyState

| Field | Type | Required |
|---|---|---|
| envelope | MessageEnvelope | yes |
| body_instance_id | OpaqueId | yes |
| applied_desired_stream_id | OpaqueId | no |
| applied_desired_sequence | UInt64 | no |
| actual_state | CanonicalBodyState-like channel snapshot | yes |
| tracking | TrackingState | yes |
| applied_constraints | list<ConstraintEvent> | yes |
| quality | Quality | yes |

Actual stateのinner envelopeは重複させず、実serializationではchannel payload typeとして定義してよい。

---

## 10. BodyCapabilitySnapshot

| Field | Type | Required |
|---|---|---|
| envelope | MessageEnvelope | yes |
| body_instance_id | OpaqueId | yes |
| profile_id | String | yes |
| capability_revision | UInt64 | yes |
| contract_versions | list/version-range | yes |
| body_channels | list<BodyChannelCapability> | yes |
| observation_capabilities | list<ObservationCapability> | yes |
| endpoints | list<EndpointDescriptor> | yes |
| stream_limits | object | yes |
| extensions | namespaced map | no |

---

## 11. BodyHealthSnapshot

| Field | Type | Required |
|---|---|---|
| envelope | MessageEnvelope | yes |
| body_instance_id | OpaqueId | yes |
| health_revision | UInt64 | yes |
| overall_state | enum(normal,degraded,safe_stop,fault) | yes |
| safety_state | object/enum | yes |
| component_health | list<ComponentHealth> | yes |
| active_faults | list<Fault> | yes |
| warnings | list<Fault/Warning> | yes |
| calibration_state | CalibrationState | yes |
| resource_state | object | no |

---

## 12. Presence rule

- Required field absence = invalid message
- Optional field absence = valueなし/機能未使用。0や前回値を意味しない
- `null` = schemaが明示許可しない限りinvalid
- Unknown optional field = 同一MAJORでは無視可能
- Unknown required semantics = negotiation/conformance failure

---

## 13. Numeric validation

- NaN / Infinityは原則invalid
- normalized fieldは定義range外をinvalid扱い
- quaternionはnormalization validation対象
- direction vectorはzero vector禁止
- distance/durationはfield定義により非負制約

---

## 14. Serialization separation

本schemaはlogical modelであり、以下をまだ固定しない。

- JSON field spellingの最終形
- binary encoding
- float32/float64
- endian
- network framing
- compression
- transport QoS

これらは#5/#8で決定する。
