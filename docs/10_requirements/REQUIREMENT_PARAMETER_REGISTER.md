# Full System Requirement Parameter Register

Status: Draft for Issue #3 Review
Revision: 0.1-draft

## 1. 目的

Full System Requirementsで「数値化が必要」と定義された性能・安全・環境parameterを一元管理する。

本台帳に値が未設定であることは要求欠落を意味しない。`Freeze owner` Issueで設計・調査・実測根拠を確認し、受入試験条件と合わせて値をFreezeする。

## 2. Status

- **FIXED**: 上位要求として既に確定
- **PROPOSED**: 初期設計目標。後続Issueで妥当性確認後にFreeze
- **TBD**: 数値化対象と責務は確定。値は後続Issueで決定

## 3. Motion / Mechanical

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-MOT-001 | Physical Head rotation DoF | FIXED | Yaw / Pitch / Roll = 3 DoF | #6 | Inspection/Test |
| PAR-MOT-002 | Yaw normal usable range | TBD | 人間らしい有限可動域。無限回転は基本要求ではない | #6 | Angle measurement |
| PAR-MOT-003 | Pitch normal usable range | TBD | — | #6 | Angle measurement |
| PAR-MOT-004 | Roll normal usable range | TBD | — | #6 | Angle measurement |
| PAR-MOT-005 | Absolute hard-limit range per axis | TBD | normal rangeより外側に安全marginを持たせる | #6 | Limit test |
| PAR-MOT-006 | Maximum commanded angular velocity | TBD | safetyより決定 | #6 | Motion measurement |
| PAR-MOT-007 | Nominal expressive angular velocity | TBD | 生物的・静音な通常動作用 | #6 | Motion/noise test |
| PAR-MOT-008 | Maximum angular acceleration | TBD | — | #6 | Motion measurement |
| PAR-MOT-009 | Maximum jerk | TBD | 急激な機械感・安全riskを抑える | #6 | Motion measurement |
| PAR-MOT-010 | Steady-state position tracking error | TBD | desired vs actual | #6 | Encoder test |
| PAR-MOT-011 | Dynamic tracking error | TBD | trajectory追従中 | #6 | Encoder/log analysis |
| PAR-MOT-012 | Minimum smooth resolvable motion | TBD | 微小な「生きている」動きの下限 | #6 | Human + instrumentation |
| PAR-MOT-013 | Low-speed jitter | TBD | — | #6 | Encoder/optical measurement |
| PAR-MOT-014 | Mechanical backlash | TBD | — | #6 | Reversal test |
| PAR-MOT-015 | Repeatability | TBD | 同一targetへの再到達 | #6 | Repetition test |
| PAR-MOT-016 | Normal expressive motion acoustic noise | TBD | dBA、測定距離・backgroundを同時定義 | #6 | Sound level test |
| PAR-MOT-017 | Maximum motion acoustic noise | TBD | 高速/最大負荷条件 | #6 | Sound level test |
| PAR-MOT-018 | Nominal display payload mass | TBD | iPhone reference + mountを含む | #6,#8 | Mass measurement |
| PAR-MOT-019 | Maximum supported display payload mass | TBD | 将来端末交換marginを含む | #6,#8 | Load test |
| PAR-MOT-020 | Tip-over stability margin | TBD | 最大dynamic state/cable loadを含む | #6 | Analysis + push/load test |
| PAR-MOT-021 | Contact/pinch allowable force/energy | TBD | hazard analysisから導出 | #6,#9 | Safety test |
| PAR-MOT-022 | Pinch/entrapment clearance requirement | TBD | geometry/riskに応じ設定 | #6,#9 | Inspection/test |

## 4. Stream / Timing / Communication

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-TIM-001 | Yura→Body Canonical Body State nominal rate | PROPOSED | 60 Hzを中心値候補とする | #5,#6 | Stream measurement |
| PAR-TIM-002 | Supported Canonical Body State rate range | PROPOSED | 30–120 Hz設計レンジ | #5,#6,#8 | Contract/load test |
| PAR-TIM-003 | Edge→MCU target update rate | TBD | network streamより高周期 | #6,#8 | Trace measurement |
| PAR-TIM-004 | MCU inner control-loop rate | TBD | actuator/control方式から決定 | #6,#8 | Firmware trace |
| PAR-TIM-005 | Canonical state→physical response latency p50/p95/p99 | TBD | freshness重視 | #5,#6 | Timestamp/high-speed measurement |
| PAR-TIM-006 | Canonical state→display response latency p50/p95/p99 | TBD | — | #5,#8 | Timestamp/display measurement |
| PAR-TIM-007 | Sensor capture→Canonical Observation latency p50/p95/p99 | TBD | modality別に定義 | #5,#7 | Timestamp/log test |
| PAR-TIM-008 | Cross-device clock offset tolerance | TBD | — | #5 | Clock sync test |
| PAR-TIM-009 | Cross-modal alignment error tolerance | TBD | Camera/Audio/Motion等 | #5,#7 | Synchronized stimulus test |
| PAR-TIM-010 | Stale Body State timeout | TBD | timeout後safe behaviorへ移行 | #5,#6 | Fault injection |
| PAR-TIM-011 | Watchdog timeout | TBD | safety controller local | #6,#8 | Fault injection |
| PAR-COM-001 | Tolerable network one-way latency | TBD | local network想定 | #5 | Network impairment test |
| PAR-COM-002 | Tolerable network jitter | TBD | — | #5 | Network impairment test |
| PAR-COM-003 | Tolerable packet loss | TBD | stream種別ごと | #5 | Network impairment test |
| PAR-COM-004 | Reconnect recovery target time | TBD | safety確認完了まで | #5,#8 | Disconnect test |

## 5. Display / Expression

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-DSP-001 | Minimum supported render frame rate | TBD | Reference endpoint能力を踏まえ設定 | #8 | Frame timing test |
| PAR-DSP-002 | Render frame-time jitter | TBD | — | #8 | Frame timing test |
| PAR-DSP-003 | Eye/gaze command resolution | TBD | 微細な視線表現を阻害しない | #4,#8 | Rendering test |
| PAR-DSP-004 | Supported reference display size/mass envelope | TBD | iPhone世代差を考慮 | #6,#8 | Fit/load inspection |
| PAR-DSP-005 | Display brightness operating envelope | TBD | indoor使用範囲 | #8 | Luminance test |

## 6. Vision / Depth

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-VIS-001 | RGB capture frame rate | TBD | tracking latencyとcompute負荷から決定 | #7,#8 | Capture test |
| PAR-VIS-002 | RGB image resolution | TBD | recognition精度とbandwidthから決定 | #7,#8 | Inspection/test |
| PAR-VIS-003 | Horizontal/vertical FOV | TBD | desk interaction envelopeをcoverage | #7 | Optical measurement |
| PAR-VIS-004 | Person detection operating distance | TBD | near/nominal/far rangeを定義 | #7 | Scenario test |
| PAR-VIS-005 | Person detection recall/precision target | TBD | test dataset/scene条件とセット | #7,#9 | Dataset/scenario test |
| PAR-VIS-006 | Person track continuity / ID switch target | TBD | 複数人物・occlusion含む | #7,#9 | Tracking test |
| PAR-VIS-007 | 3D person position error | TBD | range別に定義 | #7 | Ground-truth test |
| PAR-VIS-008 | Head pose angular error | TBD | — | #7 | Ground-truth test |
| PAR-VIS-009 | Gaze direction angular error | TBD | — | #7 | Ground-truth test |
| PAR-VIS-010 | Hand/gesture detection target | TBD | gesture setと同時Freeze | #7 | Scenario test |
| PAR-VIS-011 | Object detection target | TBD | object category setと同時Freeze | #7 | Dataset/scenario test |
| PAR-VIS-012 | Depth range | TBD | desk interaction envelope | #7 | Range test |
| PAR-VIS-013 | Depth error | TBD | distance帯別 | #7 | Ground-truth test |
| PAR-VIS-014 | Minimum ambient illuminance | TBD | indoor low-light条件 | #7 | Lux-controlled test |
| PAR-VIS-015 | Maximum expected ambient illuminance | TBD | indoor bright condition | #7 | Lux-controlled test |

## 7. Audio

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-AUD-001 | Microphone count / geometry | TBD | localization/AEC/beamforming要求から決定 | #7 | Inspection |
| PAR-AUD-002 | Audio sample rate / bit depth | TBD | STT/DSP要求から決定 | #7,#8 | Stream inspection |
| PAR-AUD-003 | Voice capture operating distance | TBD | desk interaction envelope | #7 | Scenario test |
| PAR-AUD-004 | DOA azimuth angular error | TBD | SNR/range条件とセット | #7 | Acoustic ground-truth test |
| PAR-AUD-005 | DOA elevation angular error | TBD | elevation対応構成の場合 | #7 | Acoustic ground-truth test |
| PAR-AUD-006 | Sound-source track update rate | TBD | — | #7 | Log test |
| PAR-AUD-007 | VAD detection latency | TBD | — | #7 | Audio test |
| PAR-AUD-008 | VAD miss/false-positive target | TBD | noise condition別 | #7,#9 | Dataset/scenario test |
| PAR-AUD-009 | AEC performance metric | TBD | ERLE等、実装方式に合わせ定義 | #7 | Acoustic test |
| PAR-AUD-010 | Barge-in success target | TBD | Yura speaker再生中条件 | #7,#9 | Scenario test |
| PAR-AUD-011 | Maximum speaker output SPL | TBD | 音声可聴性と安全の両方から決定 | #6,#8 | SPL test |
| PAR-AUD-012 | Nominal speaker output SPL | TBD | listening distanceとセット | #8 | SPL test |

## 8. Edge Compute / Resource

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-EDG-001 | CPU/GPU/NPU sustained utilization ceiling | TBD | latency維持用headroomを確保 | #7,#8 | Stress test |
| PAR-EDG-002 | Memory headroom | TBD | — | #8 | Stress test |
| PAR-EDG-003 | Thermal throttling onset / acceptable throttling | TBD | control safetyへ影響させない | #8 | Thermal stress test |
| PAR-EDG-004 | Body Runtime startup time | TBD | — | #8 | Boot test |
| PAR-EDG-005 | Endpoint discovery/re-registration time | TBD | — | #8 | Reconnect test |

## 9. Power / Thermal / Environmental

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-PWR-001 | Nominal system power | TBD | — | #6,#8 | Power measurement |
| PAR-PWR-002 | Peak system power | TBD | max motion + display + perception + speaker | #6,#8 | Power measurement |
| PAR-PWR-003 | Idle/standby power | TBD | 常駐用途 | #8 | Power measurement |
| PAR-PWR-004 | Input voltage/current envelope | TBD | final power architectureから決定 | #6,#8 | Electrical test |
| PAR-THM-001 | Accessible surface temperature limit | TBD | applicable safety standard/risk assessmentで決定 | #6,#9 | Thermal test |
| PAR-THM-002 | Actuator warning/stop temperature | TBD | component ratingより導出 | #6 | Thermal test |
| PAR-THM-003 | Edge warning/throttle/stop temperature | TBD | component ratingより導出 | #8 | Thermal test |
| PAR-ENV-001 | Operating ambient temperature | TBD | indoor desk environment | #6,#8 | Environmental test |
| PAR-ENV-002 | Operating relative humidity | TBD | non-condensing | #6,#8 | Environmental test |
| PAR-ENV-003 | Expected user interaction distance envelope | TBD | vision/audio requirementsの基準 | #7 | Scenario definition |
| PAR-ENV-004 | Expected ambient acoustic noise envelope | TBD | audio verification条件 | #7 | Acoustic environment test |

## 10. Safety / Reliability

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-SAF-001 | Emergency stop response time | TBD | hazard analysisから導出 | #6,#9 | Safety test |
| PAR-SAF-002 | Safe-stop motion completion time | TBD | condition別 | #6,#9 | Safety test |
| PAR-SAF-003 | Maximum allowable control fault duration | TBD | watchdogとの整合 | #6,#8 | Fault injection |
| PAR-SAF-004 | Stability safety factor / test load | TBD | tip-over analysisから決定 | #6,#9 | Analysis/test |
| PAR-SAF-005 | Allowed user-contact force/energy | TBD | applicable standard/risk assessment | #6,#9 | Force/energy test |
| PAR-REL-001 | Continuous operation test duration | TBD | 常駐用途を代表するduration | #6,#8,#9 | Endurance test |
| PAR-REL-002 | Motion endurance cycle count | TBD | cable/gear/bearing/actuator評価 | #6,#9 | Endurance test |
| PAR-REL-003 | Maximum acceptable uncontrolled restart count | FIXED | 0 | #8,#9 | Fault test |

## 11. Privacy / Diagnostics

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-SEC-001 | Default raw media retention period | PROPOSED | 永続保存しない。buffer保持量のみ後続で定義 | #8,#9 | Configuration inspection |
| PAR-OBS-001 | Diagnostic log retention / rotation | TBD | storage容量とprivacyから決定 | #8,#9 | Log test |
| PAR-OBS-002 | Performance telemetry sampling rate | TBD | debug負荷を抑えつつ解析可能にする | #8,#9 | Load/test |

## 12. Freezeルール

1. Parameter値だけをIssue/PR本文へ複製して正本化しない。
2. Freeze時は本台帳を更新する。
3. 数値には必ず測定条件・unit・percentile/許容誤差等を付与する。
4. `目安`、`十分速い`、`静か`のような非測定表現だけでFreezeしない。
5. Hardware EngineerへHandoffする時点では、対象V1で必要なparameterに未解決TBDを残さない。
6. Full System Design Freeze時点でFull SystemのTBDを残す場合は、理由・依存・Freeze予定を明示的に承認する。
