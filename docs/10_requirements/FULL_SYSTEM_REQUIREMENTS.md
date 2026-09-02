# Full System Requirements

Status: Draft for Issue #3 Review
Revision: 0.2-draft

## 1. 目的

本書は、Yura Physical Body の完成形（Full System）が満たす機能要求・非機能要求の正本である。

V1 の実装範囲、部品型番、コスト都合を理由として、本書の Full System 要求を削除しない。V1 は本書の要求から `implemented / stubbed / deferred` を別途選択する。

## 2. 要求記述規則

### 2.1 Criticality

- **C0**: 安全・契約境界・システム成立性に関する基礎要求。満たさない構成を Full System とみなさない。
- **C1**: Full System で提供する必須機能・品質要求。
- **C2**: 品質、保守性、交換性を高める要求。原則満たすが、Design Freeze 時に理由付きで例外化できる。

Criticality は V1 の実装順序や Project Priority を意味しない。

### 2.2 Verification

- **I**: Inspection — 文書・構成・設定・実装の確認
- **T**: Test — 自動試験または実機測定
- **A**: Analysis — ログ・計算・安全分析・性能分析
- **D**: Demonstration — 実環境での動作確認

### 2.3 数値要求

数値を後続設計で確定する要求は `PAR-*` を参照する。
`TBD` は要求の欠落ではなく「測定対象・Freeze責務は確定しているが値は後続Issueで確定する」ことを表す。

数値パラメータの正本は `REQUIREMENT_PARAMETER_REGISTER.md` とする。

---

## 3. 利用形態・運用環境

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-ENV-001 | Physical Body はデスク上に常設する屋内据置型 Body Device として設計する。 | C0 | I,D | #6,#8 |
| FSR-ENV-002 | 通常運用ではユーザーが継続的に同室・近距離に存在し得ることを前提とし、人の近傍で安全に動作しなければならない。 | C0 | A,T,D | #6 |
| FSR-ENV-003 | 常駐用途のため、通常使用条件で定期的な手動冷却・手動再起動を前提とせず連続運転可能でなければならない。 | C1 | T,A | #6,#8 |
| FSR-ENV-004 | 動作保証温湿度、照度、音響環境、人物認識距離等の運用包絡を `PAR-ENV-*` として定義しなければならない。 | C1 | I,T | #6,#7 |
| FSR-ENV-005 | 屋外、防水、防塵、移動ロボット用途は、別途Capabilityとして追加されない限りFull Systemの基本運用範囲に含めない。 | C1 | I | #6 |

## 4. System Boundary / Responsibility

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-SYS-001 | Physical Body は Yura System から独立した subsystem として接続・切断・交換可能でなければならない。 | C0 | I,T | #4,#8 |
| FSR-SYS-002 | Live2D / 3D / Physical Body は同一の Canonical Body State を入力境界として利用可能でなければならない。 | C0 | I,T | #4 |
| FSR-SYS-003 | Physical Body は Canonical Observation、Actual Body State、Body Capability、Body Health を Yura System へ提供できなければならない。 | C0 | I,T | #4 |
| FSR-SYS-004 | Physical Body は人格、感情、欲求、会話方針、注意対象、社会的意味を独自決定してはならない。 | C0 | I,T | #4,#7 |
| FSR-SYS-005 | Physical Body は、Yura不在・通信断中でも安全制御、故障検知、停止処理を自律的に実行できなければならない。 | C0 | T,A | #5,#6,#8 |
| FSR-SYS-006 | Yura側が必要とする場合、BodyはCanonical Observationに加えて、権限制御されたraw/encoded camera/audio等のsensor streamを提供可能でなければならない。 | C1 | T | #4,#7,#8 |
| FSR-SYS-007 | Body Edge上の認識処理は知覚前処理として扱い、個人の意味的同定・記憶との紐付けはYura側責務とする。 | C0 | I,T | #4,#7 |
| FSR-SYS-008 | Hardware CapabilityをYuraコードへ固定的に埋め込まず、接続時Capabilityから利用可能機能を決定できなければならない。 | C0 | T | #4,#8 |
| FSR-SYS-009 | Camera、Display、Audio、Sensor、MCU等は複数Endpointを登録可能なDevice Modelを持たなければならない。 | C1 | I,T | #8 |

## 5. Canonical Body / Motion

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-BDY-001 | Canonical Body Model は現行Physical機体の自由度に制限されず、少なくともroot/headの3D positionおよびorientationを表現可能でなければならない。 | C0 | I,T | #4 |
| FSR-BDY-002 | Canonical Body Model は将来のtorso、shoulder、arm、hand等の追加自由度を後方互換に拡張可能でなければならない。 | C1 | I,T | #4 |
| FSR-MOT-001 | 基準Physical HeadはYaw / Pitch / Rollの3回転自由度を持たなければならない。 | C0 | I,T | #6 |
| FSR-MOT-002 | Yaw / Pitch / Rollは独立かつ同時に連続制御可能でなければならない。 | C0 | T,D | #6 |
| FSR-MOT-003 | Yura→Body境界の主要制御は`nod`、`tilt_head`等の動作名ではなく、時間連続なDesired Body State streamでなければならない。 | C0 | I,T | #4,#5 |
| FSR-MOT-004 | Bodyは各実装自由度についてDesired StateとActual Stateを区別し、Actual StateをYuraへfeedbackできなければならない。 | C0 | T | #4,#6 |
| FSR-MOT-005 | Motion Controllerは通信周期より高い内部周期で補間・trajectory execution・feedback controlを行える構成でなければならない。 | C0 | I,T | #6,#8 |
| FSR-MOT-006 | Adapter/Controllerが行う通常補間はYuraの意味表現を変更してはならず、短時間補間・制約射影・安全制限に限定しなければならない。 | C0 | I,T | #4,#6 |
| FSR-MOT-007 | Semantic motion、感情表現、注意対象変更に由来する運動はYura側Body Motion/Expression Coreを起点としなければならない。 | C0 | I,T | #4 |
| FSR-MOT-008 | 低速域・微小変位域でjitter、stick-slip、backlash等が存在感を損なわない品質で追従可能でなければならない。 | C1 | T,D | #6 |
| FSR-MOT-009 | 各軸の可動域、速度、加速度、jerk、追従誤差、repeatability、backlash、jitter、騒音を測定可能なパラメータとして定義しなければならない。 | C1 | I,T | #6 |
| FSR-MOT-010 | 首のzero/home、機構geometry、encoder offset等を校正可能でなければならない。 | C0 | T | #5,#6 |
| FSR-MOT-011 | Bodyは長時間の微小姿勢変化を含む継続Body Stateを受けても、発熱・制御飽和・ドリフトにより破綻してはならない。 | C1 | T,A | #6,#8 |
| FSR-MOT-012 | staleなDesired Stateを無期限保持してはならず、定義されたtimeout後に安全なbehaviorへ遷移しなければならない。 | C0 | T | #5,#6 |
| FSR-MOT-013 | 通信jitterが許容範囲内である限り、運動品質はEdge/MCU側buffering/interpolationで維持されなければならない。 | C1 | T | #5,#6,#8 |
| FSR-MOT-014 | Hardwareの機構座標からCanonical Head Poseへの変換はcalibration可能で、Yuraへ機構固有motor angleを露出しない。 | C0 | I,T | #4,#5,#6 |

## 6. Display / Expression / Speech

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-DSP-001 | 通常人格表示の主要UIはEyes / Eyebrowsで構成する。 | C0 | I,D | #8 |
| FSR-DSP-002 | 通常人格表示に口を必須要素として設けない。 | C0 | I,D | #8 |
| FSR-DSP-003 | SpeechはPhysical BodyのSpeakerから再生可能でなければならない。 | C0 | T,D | #8 |
| FSR-DSP-004 | Display Endpointは交換可能なdeviceとして抽象化し、特定端末への固定依存をYura境界へ持ち込まない。 | C0 | I,T | #4,#8 |
| FSR-DSP-005 | iPhoneをReference Display/Sensor Endpointとして利用可能でなければならない。 | C1 | D | #8 |
| FSR-DSP-006 | 左右のEye openness、gaze、Eyebrow shape/height/angle等を独立かつ連続値で表現できなければならない。 | C1 | T,D | #4,#8 |
| FSR-DSP-007 | Gazeはscreen-local coordinateだけでなくCanonical gaze target/vectorから射影可能でなければならない。 | C1 | T | #4,#5,#8 |
| FSR-DSP-008 | DisplayはBody Stateのtimestampに基づき、Head motion・speech等と時間整合して描画できなければならない。 | C1 | T | #5,#8 |
| FSR-DSP-009 | Display Endpointは描画refresh、入力latency、接続状態等をCapability/Healthとして公開しなければならない。 | C1 | T | #4,#8 |
| FSR-DSP-010 | 通常表情生成でDisplay Endpointが独自の意味的表情を追加してはならない。ローカル補間・anti-aliasing等の表示品質処理は許可する。 | C0 | I,T | #4,#8 |
| FSR-DSP-011 | 保守・故障診断用UIは通常人格表示と明確に分離し、必要であればEyes/Eyebrows以外のdiagnostic表示を使用可能とする。 | C2 | I,D | #8 |

## 7. Vision / Depth Perception

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-VIS-001 | Bodyは少なくともRGB camera入力を扱えること。 | C1 | T | #7,#8 |
| FSR-VIS-002 | Camera Endpointは複数cameraへ拡張可能でなければならない。 | C2 | I,T | #7,#8 |
| FSR-VIS-003 | Full Systemはdepth sensingまたは同等の3D距離推定経路を持たなければならない。 | C1 | T | #7 |
| FSR-VIS-004 | Person detectionを行い、検出結果をObservationとして出力できなければならない。 | C1 | T | #7 |
| FSR-VIS-005 | 人物をframe単位の検出ではなく継続trackとして扱い、安定したtrack_idを提供できなければならない。 | C1 | T | #7 |
| FSR-VIS-006 | Face detectionおよびface landmarkを取得可能でなければならない。 | C1 | T | #7 |
| FSR-VIS-007 | Head poseおよびgaze directionの推定を提供可能でなければならない。 | C1 | T | #7 |
| FSR-VIS-008 | Body poseを取得可能でなければならない。 | C1 | T | #7 |
| FSR-VIS-009 | Hand detection、hand pose、gesture candidateを取得可能でなければならない。 | C1 | T | #7 |
| FSR-VIS-010 | Object detectionおよびobject trackingを行い、category・position・confidence等をObservationとして出力可能でなければならない。 | C1 | T | #7 |
| FSR-VIS-011 | Person/Object/Hand等の位置を可能な範囲で3D Canonical coordinateへ変換できなければならない。 | C1 | T | #5,#7 |
| FSR-VIS-012 | Observationはconfidence、visibility/occlusion、source/provenanceを保持可能でなければならない。 | C1 | I,T | #4,#7 |
| FSR-VIS-013 | Camera intrinsics/extrinsics、frame timestamp、必要なcapture metadataを保持し、座標変換と時系列再構成に利用可能でなければならない。 | C0 | I,T | #5,#7 |
| FSR-VIS-014 | 首と共にcameraが動く構成でも、encoder/poseとcamera timestampを用いてworld/body-base座標へ補正可能でなければならない。 | C0 | T | #5,#7 |
| FSR-VIS-015 | Yuraが高度なsemantic visionを必要とする場合に備え、設定・権限に従ってcamera frame/streamをYuraへ提供可能でなければならない。 | C1 | T | #7,#8 |
| FSR-VIS-016 | Body perceptionは人物trackと意味的人物identityを同一視してはならない。個人識別・記憶への紐付けはYura側で行う。 | C0 | I,T | #4,#7 |

## 8. Audio Perception / Output

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-AUD-001 | Full Systemはsound-source localizationに利用可能な既知geometryのmicrophone arrayを扱えること。 | C1 | I,T | #7 |
| FSR-AUD-002 | 会話/STT等で利用するaudio streamをYuraへ提供可能でなければならない。 | C1 | T | #4,#7,#8 |
| FSR-AUD-003 | Yura自身のspeaker出力をreferenceとしてAcoustic Echo Cancellationを行える構成でなければならない。 | C0 | T | #7,#8 |
| FSR-AUD-004 | Noise reductionを実行可能でなければならない。 | C1 | T | #7 |
| FSR-AUD-005 | Voice Activity Detectionを実行可能でなければならない。 | C1 | T | #7 |
| FSR-AUD-006 | Beamformingを実行可能でなければならない。 | C1 | T | #7 |
| FSR-AUD-007 | Sound-source directionを少なくともazimuthとして推定可能で、構成が対応する場合はelevation/3D位置まで拡張できなければならない。 | C1 | T | #7 |
| FSR-AUD-008 | 音源を単発角度ではなく継続trackとして扱い、track_id・方向・energy・voice probability・confidenceを保持可能でなければならない。 | C1 | T | #4,#7 |
| FSR-AUD-009 | Visual person trackとsound-source trackを候補関係としてassociation可能でなければならない。 | C1 | T | #7 |
| FSR-AUD-010 | Yura発話中でもユーザー発話を検知可能なbarge-in構成を設計しなければならない。 | C1 | T,D | #7,#8 |
| FSR-AUD-011 | Audio capture、speaker reference、DOA等は共通時刻へ対応付け可能なtimestampを保持しなければならない。 | C0 | T | #5,#7 |
| FSR-AUD-012 | Microphone geometryが可動部にある場合、その姿勢を考慮してBODY_BASE/WORLDへ変換可能でなければならない。 | C0 | I,T | #5,#7 |
| FSR-AUD-013 | 複数音源が存在する場合、単一音源前提で全状態を上書きせず複数trackを表現可能でなければならない。 | C1 | T | #7 |

## 9. Physical Sensors / Hardware Telemetry

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-SNS-001 | Touch sensingを複数surface/zoneへ拡張可能でなければならない。 | C1 | T | #7,#8 |
| FSR-SNS-002 | Proximity/ToF等の近接sensorを統合可能でなければならない。 | C1 | T | #7,#8 |
| FSR-SNS-003 | IMUを統合可能で、姿勢・振動・転倒/移動検知等へ利用可能でなければならない。 | C1 | T | #6,#7 |
| FSR-SNS-004 | 各actuatorの実位置を取得可能なencoder/position feedbackを持たなければならない。 | C0 | T | #6 |
| FSR-SNS-005 | Current / voltage / temperature等、安全・診断に必要なhardware telemetryを取得可能でなければならない。 | C0 | T | #6,#8 |
| FSR-SNS-006 | Hardware fault signalをBody Healthへ統合可能でなければならない。 | C0 | T | #4,#6,#8 |
| FSR-SNS-007 | Sensor EndpointはDevice Registryへ追加可能で、未知sensor追加時に既存Contractを破壊しない。 | C1 | I,T | #4,#8 |
| FSR-SNS-008 | Sensor Observationはtimestamp、quality/confidence、source、calibration provenanceを保持可能でなければならない。 | C1 | I,T | #4,#5,#7 |

## 10. Body Edge Compute / MCU / Device Management

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-EDG-001 | Full SystemではBody Edge ComputerとReal-time MCUの責務を分離しなければならない。 | C0 | I | #8 |
| FSR-EDG-002 | iPhone等のDisplay EndpointをBody Edge Computer/MCUの代替として必須視してはならない。 | C0 | I | #8 |
| FSR-EDG-003 | Body EdgeはDevice Registry、Capability管理、stream routing、coordinate transform、time alignment、health aggregationを担わなければならない。 | C0 | I,T | #8 |
| FSR-EDG-004 | Body EdgeはPerception/Sensor Fusionを実行可能な計算資源を持たなければならない。 | C1 | T,A | #7,#8 |
| FSR-EDG-005 | MCUはnetwork/Yuraの応答周期に依存せずreal-time actuator controlとsafety enforcementを継続できなければならない。 | C0 | T | #6,#8 |
| FSR-EDG-006 | Endpointのhot-plug/reconnectまたはrestartを検出し、安全なrecovery sequenceを実行できなければならない。 | C1 | T | #5,#8 |
| FSR-EDG-007 | 一部sensor/displayが失われても、安全性が維持できる範囲ではdegraded modeとして利用可能Capabilityを継続提供できなければならない。 | C1 | T | #5,#8 |
| FSR-EDG-008 | Device firmware/software/configurationのversionをBody Healthまたはdiagnosticsとして取得可能でなければならない。 | C1 | I,T | #8 |
| FSR-EDG-009 | Update失敗が安全制御不能状態を作らないupdate/rollback方針を持たなければならない。 | C1 | I,T | #8 |
| FSR-EDG-010 | Nominal workload時にperception/controlのlatencyを維持する計算resource headroomを定義しなければならない。 | C1 | T,A | #7,#8 |

## 11. Coordinate / Calibration

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-COORD-001 | WORLD / BODY_BASE / HEAD_YAW / HEAD_PITCH / HEAD_ROLL / DISPLAY / CAMERA_* / MIC_ARRAY / SENSOR_* 等のframe treeを定義しなければならない。 | C0 | I | #5 |
| FSR-COORD-002 | 各frame間transformは明示的に表現し、暗黙の軸向き・原点・単位を許可しない。 | C0 | I,T | #5 |
| FSR-COORD-003 | Contract上のangle、distance、time等のunitを固定し、adapter内でのみdevice固有unitへ変換しなければならない。 | C0 | I,T | #4,#5 |
| FSR-COORD-004 | Calibration dataはversion、timestamp、対象device、validityを持たなければならない。 | C0 | I,T | #5 |
| FSR-COORD-005 | 位置・方向推定に不確実性がある場合、そのconfidence/uncertaintyをObservationへ保持可能でなければならない。 | C1 | I,T | #4,#7 |
| FSR-COORD-006 | Calibration不成立時に不正な3D値を正常値として出力してはならない。 | C0 | T | #5,#7 |

## 12. Time / Synchronization / Latency

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-TIM-001 | 全時系列message/frame/sample/stateはtimestamp、sequence、source identifierを持たなければならない。 | C0 | I,T | #4,#5 |
| FSR-TIM-002 | 期間計測・順序判定にはmonotonic clockを使用可能でなければならない。 | C0 | I,T | #5 |
| FSR-TIM-003 | 複数device clock間のoffset/uncertaintyを把握し、cross-modal alignment可能な時刻同期方式を持たなければならない。 | C0 | T,A | #5 |
| FSR-TIM-004 | Capture time、processing/receive timeを必要に応じ区別し、latency分析可能でなければならない。 | C1 | I,T | #4,#5 |
| FSR-TIM-005 | stale、duplicate、out-of-order、clock discontinuityを検出可能でなければならない。 | C0 | T | #5 |
| FSR-TIM-006 | Motion、Display、Vision、Audioのend-to-end latencyとtime-alignment誤差を測定可能なパラメータとして定義しなければならない。 | C1 | T | #5,#6,#7,#8 |
| FSR-TIM-007 | clock resync時に時間逆行を正常streamとして扱ってはならず、再同期状態をHealthへ反映しなければならない。 | C0 | T | #5,#8 |

## 13. Communication / Stream Semantics

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-COM-001 | Yura↔Body通信はContract version negotiationを持たなければならない。 | C0 | T | #4,#5 |
| FSR-COM-002 | Control/state、observation、raw mediaはそれぞれのlatency/ordering要件に応じてQoSを分離可能でなければならない。 | C1 | I,T | #5,#8 |
| FSR-COM-003 | Desired Body Stateの連続streamでは古い状態の完全再送よりfreshnessを優先でき、latest-state-winsを表現可能でなければならない。 | C0 | T | #5 |
| FSR-COM-004 | Configuration、Capability、Safety state等のcontrol-plane messageは必要に応じ可靠なdelivery/acknowledgementを持たなければならない。 | C0 | T | #5 |
| FSR-COM-005 | Backpressure時に無制限queue growthを起こさず、drop/coalesce policyをstream種別ごとに定義しなければならない。 | C0 | T | #5,#8 |
| FSR-COM-006 | Disconnect/reconnectは明示的state machineとして定義し、再接続後にstale commandを再生してはならない。 | C0 | T | #5 |
| FSR-COM-007 | Network latency、jitter、loss、reorder toleranceを測定可能なパラメータとして定義しなければならない。 | C1 | T | #5 |

## 14. Safety

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-SAF-001 | Physical Bodyについてhazard analysis/risk assessmentを実施し、mechanical/electrical/thermal/software hazardsを追跡しなければならない。 | C0 | A,I | #6,#9 |
| FSR-SAF-002 | YuraまたはEdgeからの不正・異常指令によって、MCU側のabsolute safety limitを超過できてはならない。 | C0 | T | #6,#8 |
| FSR-SAF-003 | Hard limit、soft limit、velocity、acceleration、必要に応じforce/torque/current limitをlocal safety layerで強制しなければならない。 | C0 | T | #6 |
| FSR-SAF-004 | 通信断、watchdog timeout、actuator fault、sensor critical fault時のsafe behaviorを定義しなければならない。 | C0 | T,D | #5,#6 |
| FSR-SAF-005 | 可動機構によるpinch/entrapment/contact hazardを評価し、許容clearance/force/energyを数値化しなければならない。 | C0 | A,T | #6 |
| FSR-SAF-006 | 全可動域・最大dynamic condition・想定cable loadで転倒しないstability requirementを定義しなければならない。 | C0 | A,T | #6 |
| FSR-SAF-007 | Emergency stopまたは同等の即時安全化手段を提供しなければならない。 | C0 | T,D | #6,#8 |
| FSR-SAF-008 | Startup時にactuator/sensor/calibration/critical healthをself-checkし、安全確認前に通常運動へ移行してはならない。 | C0 | T | #6,#8 |
| FSR-SAF-009 | Safety-critical fault後は、原因が未解消のまま自動的に通常運動を再開してはならない。 | C0 | T | #5,#6,#8 |
| FSR-SAF-010 | Calibration invalid時は関連する制御・座標推定をfail-closedまたは明示的degradedへ遷移させなければならない。 | C0 | T | #5,#6,#7 |
| FSR-SAF-011 | Accessible surface、power、temperature等について安全上の上限を定義しなければならない。 | C0 | A,T | #6,#8 |
| FSR-SAF-012 | Safety機能はYuraの人格判断やLLM応答を必要とせず決定論的に作動しなければならない。 | C0 | I,T | #6,#8 |

## 15. Fault Tolerance / Degradation

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-FLT-001 | Body Runtimeは少なくともNormal / Degraded / Safe Stop / Faultの状態を区別できなければならない。 | C0 | I,T | #5,#8 |
| FSR-FLT-002 | Yura disconnect時に安全を維持し、再接続まで人格的自律行動を新規生成してはならない。 | C0 | T | #5,#8 |
| FSR-FLT-003 | Display disconnect時、運動・音声を継続可能か停止すべきかをCapability/Safety policyに基づき決定できなければならない。 | C1 | T | #5,#8 |
| FSR-FLT-004 | Non-critical sensor lossは利用可能Capabilityを再通知しdegraded operationへ移行可能でなければならない。 | C1 | T | #5,#7,#8 |
| FSR-FLT-005 | MCU disconnectまたはmotion feedback lossは安全上critical faultとして扱わなければならない。 | C0 | T | #5,#6,#8 |
| FSR-FLT-006 | Edge restart後、device state・calibration・contract versionを再確認してからNormalへ復帰しなければならない。 | C0 | T | #5,#8 |
| FSR-FLT-007 | Fault/degradation reasonをBody Healthおよびdiagnostic logへ記録しなければならない。 | C1 | T | #8,#9 |

## 16. Security / Privacy

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-SEC-001 | Control linkは認可されたYura/Body componentのみが操作可能なauthentication/authorization境界を持たなければならない。 | C0 | I,T | #5,#8 |
| FSR-SEC-002 | 信頼できないnetwork segmentを通過する場合、control/media通信を暗号化可能でなければならない。 | C0 | I,T | #5,#8 |
| FSR-SEC-003 | Camera/Microphone raw streamの転送先・有効化状態をpolicyとして制御可能でなければならない。 | C1 | I,T | #7,#8 |
| FSR-SEC-004 | Raw camera/audioの永続保存をFull Systemの前提としてはならず、保存する場合は明示的policyを必要とする。 | C1 | I,T | #8,#9 |
| FSR-SEC-005 | Diagnostic logは原則として不要なraw personal mediaを含めず、必要な場合は明示的debug modeとする。 | C1 | I,T | #8,#9 |
| FSR-SEC-006 | Credential/secretを平文設定・通常logへ露出してはならない。 | C0 | I,T | #8 |
| FSR-SEC-007 | Firmware/software updateは不正imageの適用を防止できる仕組みを持つことを設計目標とする。 | C2 | I,T | #8 |

## 17. Power / Thermal / Physical Integration

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-PWR-001 | Peak motion、Display、Perception、Speaker同時利用時にも必要電力を安定供給可能でなければならない。 | C0 | A,T | #6,#8 |
| FSR-PWR-002 | Power loss/brownout時に制御不能運動を発生させず、安全側へ遷移しなければならない。 | C0 | T | #6,#8 |
| FSR-PWR-003 | Body Edge/MCU/Display Endpointについてorderly shutdown/restart方針を定義しなければならない。 | C1 | I,T | #8 |
| FSR-PWR-004 | iPhoneをmounted reference endpointとして使用する場合、可動・配線・熱設計を阻害しない給電/充電手段を提供可能でなければならない。 | C1 | T,D | #6,#8 |
| FSR-THM-001 | Nominal continuous operationで手動cool-downを要求しないthermal designを持たなければならない。 | C1 | T,A | #6,#8 |
| FSR-THM-002 | Critical component温度を監視し、warning/throttle/safe stopへ段階的に遷移可能でなければならない。 | C0 | T | #6,#8 |
| FSR-THM-003 | Thermal throttlingがreal-time safety loopを無効化してはならない。 | C0 | A,T | #6,#8 |

## 18. Maintainability / Calibration / Diagnostics

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-OPS-001 | Display Endpointは交換可能で、交換後に必要なgeometry/calibrationを再適用できなければならない。 | C1 | T,D | #5,#8 |
| FSR-OPS-002 | Actuator、sensor、audio、camera等の主要componentは故障箇所をdiagnosticsから特定可能でなければならない。 | C1 | T | #8,#9 |
| FSR-OPS-003 | Calibration procedureは再現可能で、結果をversioned artifactとして保存可能でなければならない。 | C1 | I,T | #5,#9 |
| FSR-OPS-004 | Startup self-testおよびmanual diagnostic testを提供可能でなければならない。 | C1 | T | #8,#9 |
| FSR-OPS-005 | Hardware/firmware/software/contract/calibration versionを一括取得可能でなければならない。 | C1 | T | #8,#9 |
| FSR-OPS-006 | Yura本体を起動しなくてもPhysical Body単体のhardware diagnosticsを実行可能でなければならない。 | C1 | D | #8,#9 |
| FSR-OPS-007 | 可動部、Display mount、主要配線は保守交換を考慮し、永久封止を前提としない。 | C2 | I,D | #6 |

## 19. Observability / Performance Measurement

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-OBS-001 | Motion stream rate、tracking error、latency、packet drop、reorder等を計測可能でなければならない。 | C1 | T | #5,#6,#8 |
| FSR-OBS-002 | Vision/Audio pipelineのcapture→observation latency、processing load、drop rateを計測可能でなければならない。 | C1 | T | #7,#8 |
| FSR-OBS-003 | Clock offset/uncertainty/synchronization状態をdiagnosticsとして取得可能でなければならない。 | C1 | T | #5,#8 |
| FSR-OBS-004 | Safety event、fault transition、watchdog、thermal/current limit発動をevent logへ記録しなければならない。 | C0 | T | #6,#8,#9 |
| FSR-OBS-005 | 性能評価用telemetryは人格挙動の意味と実機性能を切り分けて解析できる粒度を持たなければならない。 | C1 | A | #9 |

## 20. Extensibility / Compatibility

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-EXT-001 | Body Contractは独立versionを持ち、compatible/incompatibleを判定可能でなければならない。 | C0 | T | #4 |
| FSR-EXT-002 | Unknown optional field/capabilityを受信しても既知機能を破壊しないforward-compatibility方針を持たなければならない。 | C1 | T | #4 |
| FSR-EXT-003 | Head translation、torso、arms等の将来自由度を追加しても既存3DoF Bodyが動作可能でなければならない。 | C1 | T | #4 |
| FSR-EXT-004 | 新しいcamera/audio/sensor/perception moduleをDevice Registry/Capabilityで追加可能でなければならない。 | C1 | T | #4,#8 |
| FSR-EXT-005 | iPhoneから専用Display/他端末へ変更してもYura System側の人格・Body Motion生成ロジックを変更不要とする。 | C0 | I,T | #4,#8 |
| FSR-EXT-006 | Body Edge ComputerやMCUの製品世代変更をContract境界内へ封じ込めなければならない。 | C1 | I,T | #8 |

## 21. Regulatory / Safety Standard Readiness

本節は現時点で適合宣言を行うものではない。Hardware Design / Design Freeze時点の最新版・適用範囲を再確認する。

| ID | 要求 | Criticality | Verification | 後続 |
|---|---|---:|---|---|
| FSR-REG-001 | Full System Design Freeze前に、用途・販売形態・電源・無線・人との接触を踏まえ適用法規/標準を評価しなければならない。 | C0 | I,A | #6,#9 |
| FSR-REG-002 | 人の近傍で動作するservice/personal-care robot安全の参考としてISO 13482系および後継規格の適用可能性を評価しなければならない。 | C1 | I,A | #6,#9 |
| FSR-REG-003 | 電気・電子・A/V・ICT機器安全の参考としてIEC 62368-1系の適用可能性を評価しなければならない。 | C1 | I,A | #6,#8,#9 |
| FSR-REG-004 | 日本国内で無線・電源等の規制対象となる構成を採用する場合、認証済みmodule利用または必要認証をHardware Requirementsへ反映しなければならない。 | C0 | I,A | #8,#9 |

参考情報（2026-09-02確認時点）:

- ISO 13482:2014 — Robots and robotic devices — Safety requirements for personal care robots
- ISO/FDIS 13482 — Robotics — Safety requirements for service robots（ISO 13482:2014の後継として開発中）
- ISO/TR 23482-1:2020 — ISO 13482に関する安全試験方法
- IEC 62368-1:2023 — Audio/video, information and communication technology equipment — Safety requirements

## 22. Requirement Traceability Owner

後続設計で各要求を詳細化する主担当Issueを以下とする。

| Domain | 主担当Issue |
|---|---|
| Canonical Body State / Observation / Capability / Version | #4 |
| Coordinate / Time / Communication / Fault state | #5 |
| Motion / Mechanical / Actuation / Safety | #6 |
| Vision / Audio / Sensor Fusion / Perception | #7 |
| Display Endpoint / Edge Compute / MCU / Device Management | #8 |
| Verification / RTM / Hardware Handoff | #9 |
| Full System Design Review / Freeze | #10 |

要求は複数Issueへまたがってもよいが、正本Requirement IDを複製して別意味へ変更してはならない。

## 23. #3でFreezeするもの / 後続でFreezeするもの

### #3でFreeze対象

- Full Systemで必要となる機能domain
- YuraとPhysical Bodyの責務境界
- 各Requirement IDと要求の意味
- 数値化すべきparameterの存在
- parameterをFreezeする後続Issue
- Full SystemからV1都合で要求を削除しない原則

### 後続IssueでFreeze対象

- 可動域、速度、加速度、jerk
- motion tracking error / jitter / backlash / acoustic noise
- stream rate / latency / clock alignment tolerance
- person/object/gaze/depth/DOA等の認識性能
- audio AEC / VAD / barge-in性能
- network tolerance
- electrical / thermal / power値
- safety force/energy/clearance/stability値
- environmental operating envelope
- compute resource headroom

これらは `REQUIREMENT_PARAMETER_REGISTER.md` で一元管理する。
