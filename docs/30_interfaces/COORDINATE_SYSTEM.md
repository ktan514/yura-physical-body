# Canonical Coordinate System / Transform Model

Status: Draft for Issue #5 Review
Revision: 0.1-draft

## 1. 目的

Yura System、Physical Body Edge、各sensor、Display、MCUが同じ空間を同じ意味で扱えるよう、Canonical coordinate frameとtransform規約を定義する。

本書は機構固有motor angle、camera native optical axis、display pixel coordinateをCanonical authorityとしない。

---

## 2. Canonical 3D coordinate convention

全Canonical 3D frameは次の右手系を使用する。

- `+X`: 前方
- `+Y`: 左方
- `+Z`: 上方

右手系であり、`+X × +Y = +Z` とする。

neutral poseにおけるBodyの正面方向を `+X` とする。

### 2.1 理由

- desk-resident physical robotとして前後・左右・上下が明確
- sensor/world geometryとの対応が容易
- robotics系middleware/algorithmへ写像しやすい
- display/native camera conventionをBody全体へ伝播させずに済む

---

## 3. frame tree

Full Systemの基準frame treeを次とする。

```text
WORLD                       optional / session world frame
└── BODY_BASE                physical body fixed datum
    ├── HEAD_YAW             dynamic
    │   └── HEAD_PITCH       dynamic
    │       └── HEAD_ROLL    dynamic
    │           └── HEAD     canonical virtual head reference
    │               ├── DISPLAY
    │               ├── CAMERA_FRONT
    │               └── CAMERA_*
    ├── MIC_ARRAY
    ├── TOUCH_*
    ├── PROXIMITY_*
    └── SENSOR_*
```

実際のmechanismがこの直列joint構造でない場合も、Physical adapterは同等のCanonical transform treeを公開する。

---

## 4. WORLD

`WORLD`は常に存在するとは限らない。

### 4.1 WORLDがvalidな場合

- external localization
- fixed room calibration
- multi-device spatial calibration
- SLAM等

によりBODY_BASEのworld poseを信頼できる場合に使用する。

### 4.2 WORLDがvalidでない場合

- `WORLD` transformを捏造しない
- `BODY_BASE`をoperational spatial rootとして使用する
- Observationは`BODY_BASE`またはsource frameで提供する

`WORLD`がないことは異常ではない。

---

## 5. BODY_BASE

`BODY_BASE`はPhysical Bodyに固定された不変datum frameである。

基準:

- `+X`: neutral状態のBody正面
- `+Y`: Body左
- `+Z`: 上
- origin: mechanical/calibration datumとして一意に再現可能な位置

originの物理的実装位置は#6で機構と合わせてFreezeする。

候補はyaw軸基準とbase reference planeから再現できるdatumとする。

Bodyを机上で移動した場合、`BODY_BASE` frame自体はBodyと共に移動する。WORLDがvalidなら`T_WORLD_BODY_BASE`が更新される。

---

## 6. HEAD / joint frames

`HEAD_YAW`、`HEAD_PITCH`、`HEAD_ROLL`はPhysical reference implementationの動的joint frameである。

ただしCanonical Body Stateのorientation authorityはQuaternionであり、Yuraがjoint angleを直接指定するものではない。

Physical adapterが:

```text
Canonical Head Pose
      ↓
kinematics / calibration
      ↓
mechanism joint target
```

へ変換する。

`HEAD`は機構形式から独立したvirtual head reference frameとする。

---

## 7. Display frame

`DISPLAY`は表示面中心等のcalibrated referenceから定義する3D frameである。

Canonical 3D axesは他frameと同様に `+X forward / +Y left / +Z up` を維持する。

Display pixel coordinateは別domainとする。

### 7.1 Pixel coordinate

pixel/normalized display coordinateを使用する場合は明示的に:

- `u`: screen right direction
- `v`: screen down direction
- origin: schemaで明示

とし、3D Canonical coordinateと混同しない。

Gazeのauthorityは3D Canonical gaze target/vectorであり、Display adapterがpixelへ射影する。

---

## 8. Camera frame

`CAMERA_*`はCanonical 3D frameとして公開する。

Camera SDK/OpenCV等が提供するnative optical conventionが異なる場合、driver/adapterでCanonical frameへ変換する。

native axis conventionをYura Contractへ露出しない。

Camera intrinsicsはimage plane modelとして保持し、extrinsicsはCanonical transform treeに接続する。

---

## 9. Microphone array / sensor frame

`MIC_ARRAY`および`SENSOR_*`もCanonical 3D frameへcalibrateする。

可動部に搭載されたsensorは、そのmount frameをdynamic parent配下へ置く。

固定base sensorは`BODY_BASE`配下へ置く。

---

## 10. Transform notation

本プロジェクトでは次をauthorityとする。

`T_A_B`:

> frame Bで表現された点・vector・poseをframe Aへ変換するtransform

点について:

```text
p_A = T_A_B * p_B
```

Transformは:

- translation: meter
- rotation: normalized quaternion

で表現する。

Quaternion fieldは名称付き`w/x/y/z`を使用し、array orderへ意味を依存させない。

`q_A_B`はBのvectorをAへrotationする。

---

## 11. Transform composition

```text
T_A_C = T_A_B * T_B_C
```

とする。

逆transform:

```text
T_B_A = inverse(T_A_B)
```

Transform計算でEuler角を中間authorityにしない。

Euler角はdiagnostic/UI表示用に導出してよい。

---

## 12. Static / Dynamic transform

### Static transform

- display mount geometry
- camera extrinsics
- mic array mount
- fixed sensor mount

等。

Calibration artifact revisionへ紐付ける。

### Dynamic transform

- head/joint pose
- BODY_BASE world pose
- movable sensor pose

等。

必ずsample timeを持つ。

---

## 13. Actual poseを使う

Sensor Observationを空間変換するとき、原則としてDesired Body Stateではなく**Actual Body State**を使用する。

例: moving cameraで人物を検出した場合

```text
Camera measurement at t_capture
       ↓
T_HEAD_CAMERA                     static calibration
       ↓
Actual T_BODY_BASE_HEAD(t_capture) dynamic
       ↓
p_BODY_BASE
       ↓ optional
T_WORLD_BODY_BASE(t_capture)
       ↓
p_WORLD
```

Desired poseを用いるとtracking error・motor delayがworld coordinate errorへ混入するため禁止する。

---

## 14. Time-qualified transform

Dynamic transform lookupは次を受け取る。

- target frame
- source frame
- observation sample time
- time synchronization revision

必要な時刻のtransformが直接存在しない場合は、許容範囲内でinterpolationする。

過度なextrapolationを行わない。

interpolation/extrapolationの時間上限は#5のtime modelで定義する。

---

## 15. Transform validity

Transformは少なくとも次を持つ。

- parent frame
- child frame
- pose
- sampled/effective time
- source
- calibration revision
- transform revision
- validity state
- uncertainty when relevant

validity state候補:

- `VALID`
- `DEGRADED`
- `UNAVAILABLE`

`UNAVAILABLE`時にidentity transformで代用してはならない。

---

## 16. Observation coordinate quality

ObservationをCanonical frameへ変換できない場合:

1. source frame上のObservationとして返せる場合は返す
2. target frame変換値を捏造しない
3. `quality.status`を低下させる
4. transform/calibration/time uncertaintyをprovenanceへ残す

---

## 17. Camera motion conformance case

首がYaw中にcameraが人物を観測した場合:

1. Camera frameで3D pointを得る
2. frame capture timestampを保存
3. capture timestampをsession timeへalign
4. 同時刻のActual Head Poseをinterpolate
5. static camera extrinsicと合成
6. BODY_BASEへ変換
7. WORLDがvalidならWORLDへ変換
8. transform revision / uncertaintyをObservationに記録

Headがその後さらに動いても、過去Observationのworld positionを現在head poseで再計算してはならない。

---

## 18. Calibration authority

Calibration artifactは次を持つ。

- `calibration_id`
- revision
- created_at
- device/endpoint identity
- applicable geometry
- static transforms
- validity / expiry where needed
- calibration method/version

Calibrationがinvalidな場合、依存するCanonical transformを正常扱いしない。

---

## 19. 将来拡張

将来:

- torso
- shoulder
- arms
- hands
- body translation
- movable base
- external cameras

を追加しても、同一transform規約へ接続する。

---

## 20. Freeze事項

Issue #5で次をFreezeする。

- Canonical right-handed frame
- `+X forward / +Y left / +Z up`
- `T_A_B` transform direction
- named quaternion component semantics
- Actual Body Stateをdynamic transform authorityに使用する原則
- WORLDはoptionalであり、不明時に捏造しない原則
- source-native coordinateをadapter内部へ封じ込める原則

Physical joint originやkinematic geometry値は#6でFreezeする。
