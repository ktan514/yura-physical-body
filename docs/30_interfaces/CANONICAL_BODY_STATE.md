# Canonical Body State

Status: Draft for Issue #4 Review
Revision: 0.1-draft

## 1. 目的

`CanonicalBodyState` は、Yuraが「今この瞬間に望む身体状態」をBody implementationへ渡す共通表現である。

本モデルはPhysical Bodyの3DoFに制限されない。
Live2D / 3D / Physical Bodyを同一の意味論で駆動できることを目的とする。

---

## 2. 基本原則

- commandではなくstate snapshotである。
- emotion labelやbehavior labelを主要制御値として持たない。
- adapter固有parameterを持たない。
- 各channelは連続値を基本とする。
- BodyはCapabilityに応じて再現可能部分だけを利用する。
- personality-visibleな自律motionはYura側で生成する。

---

## 3. Top-level model

論理schema:

```text
CanonicalBodyState
├─ envelope
├─ profile_id
├─ root
├─ head
├─ gaze
├─ face
│  ├─ eyes
│  ├─ eyebrows
│  └─ optional mouth
├─ nodes / joints
├─ speech_sync
└─ extensions
```

`profile_id` はCanonical Body Profileの識別子であり、機体型番ではない。

---

## 4. Pose3

Canonicalな3D姿勢は次で表す。

```text
Pose3
├─ frame_id
├─ position_m
│  ├─ x
│  ├─ y
│  └─ z
└─ orientation
   ├─ x
   ├─ y
   ├─ z
   └─ w
```

### 規則

- `position_m` はmeter。
- `orientation` はnormalized quaternion。
- quaternion normが許容誤差外の場合はinvalid。
- Euler angleはcanonical authorityにしない。
- frame conventionは#5でFreezeする。

---

## 5. Root

`root` はBody全体のcanonical root pose。

Live2D等でroot translationを使用しない実装はunsupportedとしてよい。
Physical Head-only Bodyもroot translationを実装する必要はない。

---

## 6. Head

`head.pose` はheadのcanonical poseを表す。

```text
head
├─ pose: Pose3
└─ stiffness_hint? / motion_quality_hint?  # 将来optional
```

Physical 3DoF Bodyは`head.pose.orientation`をYaw/Pitch/Roll機構へkinematic projectionする。

Yura境界へmotor angleを返さない。

---

## 7. Gaze

Gazeは「誰を見るか」というsemantic commandではなく幾何学的targetとして表す。

```text
gaze
├─ mode
│  ├─ target_point
│  └─ direction
├─ frame_id
├─ target_point_m? : Vec3
├─ direction_unit? : Vec3
├─ convergence_distance_m?
└─ target_ref?      # provenanceのみ。制御authorityではない
```

### `target_ref`

`person-track:42` 等のreferenceを任意で持てるが、Body adapterはこれを解釈して独自にtargetを再探索してはならない。

実際のgaze control authorityはgeometry fieldである。

### EyeとHeadの分離

Gaze targetが変わったときに、

- eyeだけ先に動く
- headが遅れて追従する
- headは動かさずeyeのみ動く

等をYura Motion Coreが自由に生成できるよう、`gaze`と`head.pose`は独立channelとする。

---

## 8. Eyes

左右Eyeを独立して表現する。

```text
eyes.left / eyes.right
├─ openness        [0.0, 1.0]
├─ squint          [0.0, 1.0]
├─ pupil_scale     [0.0, 1.0] optional
├─ iris_visibility [0.0, 1.0] optional
└─ local_offset?   signed normalized optional
```

### Openness

- `0.0`: fully closed
- `1.0`: nominal fully open

BlinkはYuraが`openness`の時間変化として生成する。
Display Endpointが独自のランダムblinkを追加してはならない。

---

## 9. Eyebrows

左右Eyebrowを独立channelとする。

```text
eyebrows.left / eyebrows.right
├─ inner_height    [-1.0, 1.0]
├─ outer_height    [-1.0, 1.0]
├─ compression     [-1.0, 1.0]
└─ depth_or_arch?  [-1.0, 1.0] optional
```

`inner_height` / `outer_height`の組み合わせから、各rendererは眉の見かけ上のangleを生成してよい。

特定Displayのpixel座標やLive2D parameterをcanonical fieldにしない。

---

## 10. Mouth / Articulation

Physical Bodyは通常表示にmouthを持たないが、共通Body ContractはLive2D/3Dの表現能力を制限しない。

そのため`face.mouth`はoptional canonical channelとして予約する。

初期core channel候補:

```text
mouth
├─ jaw_open        [0.0, 1.0]
├─ smile           [-1.0, 1.0]
├─ lip_round       [0.0, 1.0]
├─ lip_press       [0.0, 1.0]
└─ viseme_weights? map<canonical_viseme_id, 0..1>
```

Physical BodyはCapabilityでmouth channelを`unsupported`とする。

mouth channelの存在によってPhysical Displayへ口を描画する要求は発生しない。

---

## 11. Future body nodes / joints

Canonical Body ModelはHead-only設計へ固定しない。

将来拡張のcanonical path namespaceを予約する。

```text
root
head
torso.pelvis
torso.chest
torso.neck
arm.left.shoulder
arm.left.elbow
arm.left.wrist
arm.right.shoulder
arm.right.elbow
arm.right.wrist
hand.left
hand.right
```

wire modelは`nodes`または`joints`のmap/listへ追加可能とする。

Contract v1で未定義の新nodeはoptional extensionとして扱い、既存3DoF Bodyを破壊しない。

Canonical pathを特定3D engineのbone名へ一致させることを要求しない。

---

## 12. Speech synchronization

Body motionと音声再生を同期できるよう、Body Stateは任意の`speech_sync` metadataを持てる。

```text
speech_sync
├─ utterance_id
├─ speaking
├─ media_time_s
├─ amplitude_envelope? [0.0,1.0]
└─ phase? optional
```

audio本体のtransportは別contractで扱う。

Physical Bodyでは口パク用途ではなく、head/eye/browの発話中motionとspeaker playbackの時間整合に利用できる。

---

## 13. Normalized expression value

### unsigned channel

`0.0..1.0`

- 0.0 = minimum
- 1.0 = defined maximum

### signed channel

`-1.0..1.0`

- 0.0 = neutral
- negative/positiveの物理的意味はchannel定義で固定する。

Adapterは値を自身のrender/actuator rangeへmappingする。

---

## 14. Out-of-range behavior

Canonical producerは定義range外の値を生成してはならない。

Consumerはrange外値を受信した場合、無条件clampして正常値として扱わない。

少なくとも次を行う。

1. invalid inputとしてdiagnostic記録
2. safetyに影響しないchannelではpolicyに従いreject/clamp
3. physical motionに影響する場合はlocal safety constraintを優先

詳細fault policyは#5/#6で定義する。

---

## 15. Snapshot completeness

`CanonicalBodyState` v1のframeはsnapshotである。

active core channelについてYuraは毎frame値を生成する。

例:

```json
{
  "head": {"pose": "..."},
  "gaze": {"mode": "target_point", "target_point_m": [0.4, 0.2, 1.2]},
  "face": {
    "eyes": {
      "left": {"openness": 0.92, "squint": 0.05},
      "right": {"openness": 0.91, "squint": 0.05}
    },
    "eyebrows": {
      "left": {"inner_height": 0.12, "outer_height": 0.04, "compression": 0.0},
      "right": {"inner_height": 0.12, "outer_height": 0.04, "compression": 0.0}
    }
  }
}
```

この例はschema conceptを示すもので、serialization formatのFreezeではない。

---

## 16. ActualBodyStateとの関係

`CanonicalBodyState` = Desired

`ActualBodyState` = Bodyが実際に再現したstate

Physical Bodyでは例として、

```text
Desired head orientation
       ↓
Capability projection
       ↓
Kinematics / safety limit
       ↓
Actual encoder pose
       ↓
ActualBodyState
```

となる。

Live2D/3Dでも、rendererが適用したstateをActualBodyStateとして返せる。

---

## 17. Extension field

将来拡張用にnamespaced extensionを許可する。

例:

```text
extensions["org.example.experimental.x"]
```

ただしextensionは次を満たす。

- core fieldの意味を変更しない
- safety-critical requirementをextensionだけに依存させない
- unknown extensionを無視してもcore behaviorが成立する
-正式採用時はcore schemaへ昇格または標準namespace化する
