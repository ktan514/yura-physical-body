# Yura ↔ Body Boundary Contract

Status: Draft for Issue #4 Review
Revision: 0.2-draft

## 1. 目的

本書は Yura System と各 Body implementation の間に存在する共通境界を定義する。

対象Body:

- Live2D Body
- 3D Body
- Physical Body
- 将来追加されるBody implementation

Physical Body固有のmotor angle、servo ID、display pixel coordinate、camera device API等をYura側の共通境界へ露出しない。

---

## 2. 最重要原則

### 2.1 状態を送る。動作名を送らない

主要な運動境界は次のようなsemantic commandではない。

```json
{"command": "tilt_head"}
```

```json
{"command": "nod"}
```

Yuraは時間連続な `CanonicalBodyState` を生成する。

Body implementationは、その時点のDesired Stateを自身の表現能力へ射影し、追従する。

### 2.2 Personality-visible motionのAuthorityはYura

次を含む、外から人格として知覚される変化はYura側Body Motion / Expression Coreをauthorityとする。

- head pose
- gaze
- blink
- eye openness
- eyebrow motion
- facial expression channel
- semantic gesture
- idle micro-motion
- breathing-like motion
- speaking中の演技的motion

Body implementationが独自にこれらの意味的motionを追加してはならない。

Body側で許可するのは原則として次である。

- current frame間の時間補間
- rendering refreshへの補間
- actuator trajectory interpolation
- kinematic projection
- capability projection
- anti-aliasing等の表示品質処理
- safety limit / fault handling
- diagnostic / calibration時の明示的test motion

### 2.3 Sensor measurementと意味判断を分ける

Bodyは物理世界を測定・検出・追跡する。

Bodyが扱ってよい例:

- person track #4 がこの位置に存在する
- object categoryがcupである可能性が高い
- sound source #2 が右側に存在する
- touchがhead surfaceで発生した

Yura側で扱う例:

- person track #4 は特定の人物である
- このcupはユーザー所有物である
- 声を掛けられたので振り向く
- 頭を撫でられて嬉しい

---

## 3. Contract Surface

Yura ↔ Bodyの共通境界は次の主要message familyで構成する。

### Yura → Body

1. `CanonicalBodyState`
   - Yuraが望む現在の身体状態
2. `BodyStreamControl`
   - stream lifecycle / reset / negotiationに関するcontrol
3. Media/Audio control
   - speaker/audio transportの詳細は#5/#8で確定する

### Body → Yura

1. `ActualBodyState`
   - Bodyが実際に再現できている身体状態
2. `CanonicalObservationBatch`
   - Physical worldから得たperception/sensor observation
3. `BodyCapabilitySnapshot`
   - 現在利用可能なBody能力
4. `BodyHealthSnapshot`
   - Body/endpoint/safety/fault状態

---

## 4. 共通Envelope

全stream messageは論理的に次のmetadataを持つ。

| Field | 意味 |
|---|---|
| `contract_version` | Body Contract version |
| `message_id` | message固有ID |
| `stream_id` | stream instance ID |
| `sequence` | stream内単調増加sequence |
| `source_id` | message producer |
| `sampled_at` | 状態/観測が成立したsource clock上の時刻 |
| `generated_at` | message生成時刻 |
| `source_clock_id` | timestampのclock domain |
| `trace_id` | 任意。cross-component trace用 |

時刻同期方式、wall-clockとの関係、許容offsetは#5でFreezeする。

---

## 5. Snapshot semantics

### 5.1 CanonicalBodyState

Contract v1系では `CanonicalBodyState` を **snapshot** として扱う。

- 送信対象としてactiveなchannelは各frameで値を明示する。
- 欠落fieldを「0へ戻せ」の意味に使わない。
- 欠落fieldを「前回値を無期限保持」の意味にも使わない。
- support状態は `BodyCapabilitySnapshot` をauthorityとする。
- stream freshness切れの扱いは#5で定義する。

Sparse delta protocolを将来追加する場合はCapabilityとして明示し、snapshot semanticsと混同しない。

### 5.2 Observation / Health / Capability

Observationはevent/track updateとして送信可能である。
CapabilityとHealthはrevision付きsnapshotとして扱う。

---

## 6. Presence / Null / Unsupported semantics

曖昧な`null`依存を避ける。

### CanonicalBodyState

- field存在 + valid value: Desired valueあり
- field不存在: そのschema elementを当該profile/frameで提供していない
- `null`: 原則使用禁止。schemaで明示的に許可された場合のみ使用

### BodyCapability

Bodyが実装できないchannelはCapability上で`unsupported`または未宣言として扱う。

### Observation

測定不能/一時lossは値を捏造せず、`quality.status`、confidence、uncertainty、visibility等で表現する。

---

## 7. Capability projection

例:

```text
Canonical Body State
  head 6DoF
  eyes
  eyebrows
  mouth
  torso
        │
        ├─ Live2D
        │   head/eyes/brows/mouth/torsoを利用
        │
        ├─ 3D
        │   skeleton/face rigへ射影
        │
        └─ Physical Body
            head Yaw/Pitch/Roll
            eyes/eyebrows display
            mouth/torso = unsupported
```

Bodyがunsupported channelを無視することは正常である。
ただしYuraはCapabilityを確認せず「必ず再現された」と仮定してはならない。

Bodyは再現できた結果を `ActualBodyState` として返す。

---

## 8. Canonical coordinate / unit policy

本Issueで次を固定する。

- distance: meter
- angle quantity: radian
- duration: secondまたは整数nanosecond fieldとしてschemaごとに固定
- normalized scalar: 原則`0.0..1.0`
- signed normalized scalar: 原則`-1.0..1.0`
- confidence: `0.0..1.0`
- canonical 3D orientation: normalized quaternion

軸方向、handedness、WORLD/BODY_BASE等のframe tree、quaternion適用規約は#5でFreezeする。

Euler yaw/pitch/rollをwire上のcanonical orientation authorityにはしない。
Physical 3DoF adapterがcanonical quaternionから機構軸へ変換する。

---

## 9. Provenance

Perception/Actual State/Capability/Healthは、必要に応じて以下を追跡可能にする。

- source endpoint
- source frame/sample
- pipeline/module
- algorithm/model version
- calibration revision
- transform revision
- contract version

Yuraが推定結果とraw sourceの関係を検証できることを目的とする。

---

## 10. Contract documents

本境界の詳細正本を次に分割する。

- `CANONICAL_BODY_STATE.md`
- `CANONICAL_OBSERVATION.md`
- `BODY_CAPABILITY_AND_HEALTH.md`
- `CONTRACT_VERSIONING.md`

座標・時刻・通信transportは#5で別途Freezeする。

---

## 11. 禁止事項

共通Boundaryでは次を禁止する。

- servo ID / PWM / motor encoder raw countをCanonical Body Stateへ入れる
- Live2D Parameter IDをCanonical Body Stateへ入れる
- Unity/VRM等のengine固有bone IDをauthorityにする
- `happy`, `angry`, `thinking`等のemotion/behavior labelをBody adapterの独自判断材料として渡す
- Body adapterが自発blink/idle gesture等を人格motionとして生成する
- person trackを永続的人物identityとして扱う
- confidence不明の推定値を確定値として出力する
- unsupported channelを暗黙に別channelへ置換する
- unknown fieldを別の既知意味へ読み替える

---

## 12. 後続Issueとの境界

### #5

- frame tree / handedness / axis convention
- clock model / synchronization
- stream QoS / transport
- stale / reorder / reconnect

### #6

- Physical kinematics
- actual motor/encoder mapping
- safety constraints

### #7

- perception algorithm / track lifecycle詳細
- sensor fusion

### #8

- endpoint discovery
- device protocol
- Edge/MCU/Display implementation partition

### #9

- schema/contract conformance test
- traceability / acceptance
