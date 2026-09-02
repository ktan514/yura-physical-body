# Canonical Observation

Status: Draft for Issue #4 Review
Revision: 0.1-draft

## 1. 目的

`CanonicalObservationBatch` は、Physical Bodyが物理世界から取得した知覚・sensor情報をYura Systemへ返す共通表現である。

Bodyは測定・検出・追跡・融合までを行う。
人格的・意味的判断はYura側で行う。

---

## 2. Top-level model

```text
CanonicalObservationBatch
├─ envelope
├─ observations[]
└─ batch_quality?
```

各observationは独立した`observation_id`を持つ。

---

## 3. Observation common fields

```text
Observation
├─ observation_id
├─ type
├─ observed_at
├─ source_endpoint_ids[]
├─ source_frame_refs[]
├─ frame_id
├─ quality
├─ provenance
├─ track_ref?
└─ payload
```

### `quality`

```text
quality
├─ status
│  ├─ valid
│  ├─ degraded
│  ├─ unavailable
│  └─ invalid
├─ confidence? [0.0,1.0]
├─ uncertainty?
├─ visibility?
└─ occlusion?
```

confidenceが算出できないalgorithmで、便宜的な数値を捏造してはならない。

---

## 4. Track semantics

Person / Object / Hand / Sound Source等はframe単位の検出だけでなく継続trackを表現できる。

```text
TrackRef
├─ track_id
├─ track_type
├─ track_epoch
└─ lifecycle_state
```

`track_id`はBody perception subsystem内の一時的識別子であり、人物の永続identityではない。

Yuraが記憶上の人物identityと関連付ける場合、そのmappingはYura側で管理する。

---

## 5. PersonObservation

```text
PersonObservation
├─ track_ref
├─ position_m?
├─ orientation?
├─ velocity_mps?
├─ bounding_volume?
├─ body_pose_ref?
├─ face_ref?
├─ head_pose?
├─ gaze_direction?
├─ speaking_probability?
└─ quality
```

Bodyはperson identity/nameを必須fieldとして持たない。

---

## 6. FaceObservation

```text
FaceObservation
├─ track_ref
├─ parent_person_track_ref?
├─ position_m?
├─ orientation?
├─ landmarks?
├─ head_pose?
├─ gaze_direction?
└─ quality
```

Face recognitionによる人物同定をBody Contractの必須責務にしない。

---

## 7. BodyPoseObservation

```text
BodyPoseObservation
├─ track_ref
├─ parent_person_track_ref?
├─ joints[]
│  ├─ canonical_joint_id
│  ├─ position_m?
│  ├─ orientation?
│  └─ confidence?
└─ quality
```

関節IDはCanonical Body namespaceに対応可能な標準IDを利用する。

---

## 8. HandObservation

```text
HandObservation
├─ track_ref
├─ parent_person_track_ref?
├─ handedness
│  ├─ left
│  ├─ right
│  └─ unknown
├─ position_m?
├─ orientation?
├─ keypoints?
├─ pose_features?
└─ quality
```

---

## 9. GestureCandidateObservation

Gesture detectionはperception levelのcandidateとして表現する。

```text
GestureCandidateObservation
├─ parent_track_ref
├─ gesture_id
├─ phase?
├─ probability/confidence?
└─ quality
```

`wave`等のcandidateをBodyが検出しても、

- 挨拶として受け取る
- 返事する
- 無視する

といった行動判断はYura側で行う。

---

## 10. ObjectObservation

```text
ObjectObservation
├─ track_ref
├─ category
├─ category_confidence?
├─ position_m?
├─ orientation?
├─ velocity_mps?
├─ dimensions_m?
├─ bounding_volume?
└─ quality
```

Object categoryはperception結果として扱ってよい。

所有者、固有名、意味記憶との関連付けはYura側責務である。

---

## 11. SoundSourceObservation

```text
SoundSourceObservation
├─ track_ref
├─ azimuth_rad?
├─ elevation_rad?
├─ direction_unit?
├─ position_m?
├─ energy?
├─ voice_probability?
├─ associated_person_track_refs[]?
└─ quality
```

複数sound sourceを同時に表現可能とする。

associated personは確定identityではなく、sensor fusionによるcandidate relationである。

---

## 12. TouchObservation

```text
TouchObservation
├─ surface_id
├─ position_local?
├─ pressure_normalized?
├─ contact_area?
├─ duration_s?
├─ motion_vector_local?
└─ quality
```

Bodyは物理接触の測定までを行う。

「撫でられた」「叩かれた」等の高位解釈は、必要に応じてYura側で行う。

ただしBody側がraw sensorからcontact pattern candidateを生成することは、perception preprocessingとして別Capabilityで許可できる。

---

## 13. ProximityObservation

```text
ProximityObservation
├─ sensor_id
├─ distance_m?
├─ direction_unit?
└─ quality
```

---

## 14. EnvironmentObservation

将来、環境sensorを追加するためのnamespaceを持つ。

例:

- ambient_light
- temperature
- humidity
- external vibration
- air-quality等

Physical Bodyの内部component温度等は原則`BodyHealth`側で扱い、外界sensorとは区別する。

---

## 15. Observation coordinate

Spatial observationは必ず`frame_id`を明示する。

Consumerはframe_id不明の3D位置をWORLD座標と仮定してはならない。

frame tree、axis convention、transform validityは#5でFreezeする。

---

## 16. Uncertainty

位置・姿勢等についてalgorithmが不確実性を出力可能な場合、次を表現可能とする。

```text
uncertainty
├─ covariance?
├─ standard_deviation?
├─ angular_error_estimate?
└─ method?
```

同じfieldに複数の不確実性表現を混在させる場合はmethodを明示する。

---

## 17. Provenance

```text
provenance
├─ pipeline_id
├─ pipeline_version
├─ algorithm_id?
├─ model_id?
├─ model_version?
├─ calibration_revision?
├─ transform_revision?
└─ source_media_refs[]?
```

目的:

- Yura側で推定の由来を確認できる
- model更新前後の差を検証できる
- calibration不整合を追跡できる
- Verificationで再現可能性を確保する

---

## 18. Raw mediaとの関係

Canonical Observationはraw RGB frame/audio sample本体を必須fieldとして内包しない。

必要な場合は`source_media_refs`等でmedia stream/frameへ関連付ける。

Raw camera/audio streamのtransport・authorizationは#5/#8で定義する。

---

## 19. Missing / unavailable

Sensor loss時に最後の正常値を新しいObservationとして再送し続けてはならない。

次のいずれかで明示する。

- observation update停止 + Health/Capability change
- `quality.status = unavailable`
- track lifecycle終了

stale判断の時間条件は#5/#7で定義する。

---

## 20. Batch ordering

同一batch内のobservationは意味上の優先順位を持たない。

関連関係は`track_ref`、`parent_track_ref`、association field等で表す。

配列順序へ意味を埋め込まない。

---

## 21. Extension policy

新しいObservation typeは追加可能とする。

未知optional typeを受信したConsumerは、既知Observation処理を継続できなければならない。

既存typeのfield意味を変更するために同じfield名を再利用してはならない。
