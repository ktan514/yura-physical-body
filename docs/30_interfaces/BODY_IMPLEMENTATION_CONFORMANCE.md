# Body Implementation Conformance

Status: Draft for Issue #4 Review
Revision: 0.1-draft

## 1. 目的

Canonical Body ContractがLive2D / 3D / Physical Bodyの3実装で共通利用できることを設計上確認する。

---

## 2. Conformance principle

Body implementationはCanonical Body Stateをそのまま完全再現することを要求されない。

要求するのは次である。

1. Capabilityを正しく宣言する
2. supported channelの意味を変えずに再現する
3. unsupported channelを別意味へ変換しない
4. ActualBodyStateで再現結果を返せる
5. 独自personality motionを追加しない

---

## 3. Channel mapping matrix

| Canonical channel | Live2D | 3D | Physical Reference Body |
|---|---|---|---|
| root.position | optional mapping | world/root transform | unsupported |
| root.orientation | optional mapping | root transform | unsupported |
| head.position | 2D/parameter projection | head/root transform | unsupported in 3DoF reference |
| head.orientation | angle parameter projection | head quaternion/bones | Yaw/Pitch/Roll kinematic projection |
| gaze target/direction | pupil/eye parameter projection | eye bones/eye aim | display pupil position |
| eye openness L/R | Live2D eye params | eyelid blendshape/bones | display eye shape |
| eyebrow L/R | Live2D brow params | brow blendshape/bones | display eyebrow geometry |
| mouth | supported when model has params | supported when rig has mouth | unsupported |
| torso | model dependent | skeleton | unsupported |
| arms/hands | model dependent | skeleton | unsupported |
| speech_sync | lip/acting sync | viseme/acting sync | speaker/head/eye/brow sync |

---

## 4. Live2D adapter

Live2D adapterはCanonical fieldをCubism parameterへmappingする。

例:

```text
head.orientation
   ↓
canonical→2D projection
   ↓
ParamAngleX/Y/Z等
```

ただしCubism parameter名をCanonical Contractへ逆流させない。

Model固有parameter差はLive2D adapter/model profile内で吸収する。

---

## 5. 3D adapter

3D adapterはCanonical Pose3 / joint channelを3D skeleton/rigへmappingする。

- quaternionをengine conventionへ変換
- canonical joint pathをrig boneへmapping
- face channelをblendshape/boneへmapping

Unity/Unreal/VRM等の固有IDをCanonical Contractのauthorityにしない。

---

## 6. Physical Body adapter

Reference Physical Body capability:

```text
Head rotation: Yaw/Pitch/Roll supported
Head translation: unsupported
Eyes: supported on Display Endpoint
Eyebrows: supported on Display Endpoint
Mouth: unsupported
Torso/arms/hands: unsupported
Actual pose feedback: supported
```

Canonical head quaternionを3DoF mechanismへprojectし、motor/encoder unitへ変換する。

Yuraからmotor angleを直接受けない。

---

## 7. Example: thinking-like pose

Yuraが次の時間変化を生成したとする。

```text
t0:
  gaze = upper-left target
  eyes openness = 0.92
  eyebrows inner_height = +0.08
  head orientation = neutral

t1:
  gaze remains upper-left
  head orientation begins roll + pitch

t2:
  head holds slight roll
  eyes move subtly
```

各Bodyは同じstate sequenceを受け取る。

- Live2D: 顔parameterへ投影
- 3D: head/eye rigへ投影
- Physical: display eyes/brows + 3DoF headへ投影

「thinking」というcommandをBodyへ送らないため、左右・角度・保持時間・目と首のタイミング差が失われない。

---

## 8. Example: blink

Yura:

```text
1.00 → 0.65 → 0.10 → 0.00 → 0.25 → 0.80 → 1.00
```

をeye opennessとして時間連続生成する。

Live2D/3D/Physicalはそれぞれ同じopenness curveへ追従する。

Body adapterが別周期のrandom blinkを重ねない。

---

## 9. Unsupported example

Yura stateにmouth movementが含まれている場合:

- Live2D: Capabilityがsupportedなら再現
- 3D: Capabilityがsupportedなら再現
- Physical Reference: unsupportedとして無視

Physical adapterがmouth movementを眉や首motionへ勝手に置換してはならない。

---

## 10. Constraint example

Yura Desired head orientationがPhysical Bodyの可動域を超える場合:

```text
Desired Canonical orientation
        ↓
Physical capability / safety projection
        ↓
reachable orientation
        ↓
ActualBodyState + applied constraint
```

Live2D/3Dがより広いrangeを表現できる場合は、そのBodyではより忠実に再現してよい。

Canonical state自体をPhysical機体のrangeへ制限しない。

---

## 11. Observation side

Canonical ObservationはPhysical Body特有の出力であるが、Yura SystemはBody Contract上のObservationとして受け取る。

Live2D/3DのみのBody implementationがObservation capabilityを持たない場合は`unsupported`でよい。

将来virtual camera/game environment sensor等を持つ3D Bodyが同じObservation typeを提供することも可能とする。

---

## 12. Conformance checklist

### Live2D

- [ ] Canonical fieldをModel固有parameterへadapter内でmapping可能
- [ ] Canonical field意味をModel都合で変更しない
- [ ] unsupported parameterをCapabilityで表現可能
- [ ] independent blink/idle personality motionを無効化可能

### 3D

- [ ] Pose3/quaternionをengine skeletonへmapping可能
- [ ] canonical joint namespaceをrigへmapping可能
- [ ] unsupported joint/face channelをCapabilityで表現可能
- [ ] engine固有animationをpersonality authorityにしない

### Physical

- [ ] head orientationを3DoFへprojection可能
- [ ] Eyes/EyebrowsをDisplayへprojection可能
- [ ] mouth/torso等をunsupportedとして扱える
- [ ] DesiredとActualを区別可能
- [ ] safety constraint適用結果をActualBodyStateへ返せる

---

## 13. #4 acceptance conclusion

本mappingにより、Canonical Body Contractは「最小共通機能だけに縮退したinterface」ではなく、豊かなCanonical Body Stateを定義し、各BodyがCapabilityに応じて部分実装する構造とする。

そのためPhysical Bodyの現在の3DoF/目/眉という制約が、Live2D・3D・将来Bodyの表現力を制限しない。
