# Full System Requirement Parameter Register

Status: Active Full System Parameter Register
Revision: 0.4-draft

## 1. 目的

Full System Requirementsで「数値化が必要」と定義された性能・安全・環境parameterを一元管理する。

本台帳に値が未設定であることは要求欠落を意味しない。`Freeze owner` Issueで設計・調査・実測根拠を確認し、受入試験条件と合わせて値をFreezeする。

## 2. Status

- **FIXED**: 上位要求または担当Issueで確定済み
- **PROPOSED**: 初期設計目標。後続Issueで妥当性確認後にFreeze
- **TBD**: 数値化対象と責務は確定。値は後続Issueで決定

## 3. Motion / Mechanical

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-MOT-001 | Physical Head rotation DoF | FIXED | Yaw / Pitch / Roll = 3 DoF | #6 | Inspection/Test |
| PAR-MOT-002 | Yaw normal usable range | FIXED | 通常使用可能範囲として左右合計180°以上。左右配分はmechanism designで決定し、360°連続回転は必須としない | #6 | Angle measurement |
| PAR-MOT-003 | Pitch normal usable range | FIXED | neutralから上25°以上 / 下30°以上 | #6 | Angle measurement |
| PAR-MOT-004 | Roll normal usable range | FIXED | neutralから左右それぞれ20°以上 | #6 | Angle measurement |
| PAR-MOT-005 | Absolute hard-limit range per axis | TBD | normal usable range外側にencoder/calibration/overshootを吸収するmechanical safety marginを持つ。具体角度はmechanism designで確定 | #6,#9 | Limit test |
| PAR-MOT-006 | Maximum normal commanded angular velocity | FIXED | 120°/s (2.094 rad/s) | #6 | Motion measurement |
| PAR-MOT-007 | Nominal expressive angular velocity | FIXED | 60°/s級を中心に使用 | #6 | Motion/noise test |
| PAR-MOT-008 | Maximum normal angular acceleration | FIXED | 360°/s² (6.283 rad/s²) | #6 | Motion measurement |
| PAR-MOT-009 | Maximum normal angular jerk | FIXED | 2000°/s³ (34.91 rad/s³) | #6 | Motion measurement |
| PAR-MOT-010 | Steady-state position tracking error | FIXED | 各軸 ±0.5°以内、nominal payload / 25±5°C | #6 | Encoder + optical test |
| PAR-MOT-011 | Dynamic tracking error | FIXED | nominal expressive motionでp95 <=2.0° | #6 | Encoder/log analysis |
| PAR-MOT-012 | Minimum smooth resolvable motion | FIXED | 0.25° target stepをstick-slip/方向反転なしで追従 | #6 | Human + optical instrumentation |
| PAR-MOT-013 | Low-speed jitter | FIXED | holdまたは<=5°/sでuncommanded peak-to-peak <=0.30° | #6 | Encoder/optical measurement |
| PAR-MOT-014 | Mechanical backlash | FIXED | output equivalent <=0.50° | #6 | Reversal test |
| PAR-MOT-015 | Repeatability | FIXED | repeated target ±0.5°以内 | #6 | Repetition test |
| PAR-MOT-016 | Normal expressive motion acoustic noise | FIXED | 0.5m、background LAeq<=25dBAでmotion LAeq<=32dBA | #6 | Sound level test |
| PAR-MOT-017 | Maximum normal motion acoustic noise | FIXED | 0.5mでLAFmax<=40dBA。service/calibration mode除外 | #6 | Sound level test |
| PAR-MOT-018 | Nominal removable display payload mass | FIXED | <=350 g、reference phone/case/adapter等を含む | #6,#8 | Mass measurement |
| PAR-MOT-019 | Maximum supported removable display payload mass | FIXED | <=500 g。Capability/profileによりperformance derating可 | #6,#8 | Load test |
| PAR-MOT-020 | Tip-over stability margin | FIXED | static overturning moment safety factor>=1.5。worst normal pose/max payloadでdisplay center相当へ10Nを2秒加えてもtip-overしない | #6,#9 | Analysis + push/load test |
| PAR-MOT-021 | Contact/pinch allowable force/energy | TBD | universal値を仮定しない。hazard analysisと適用規格から#9でFreeze | #6,#9 | Safety test |
| PAR-MOT-022 | Pinch/entrapment clearance requirement | TBD | guard/eliminationを優先。residual geometryに対するprobe/clearanceを#9でFreeze | #6,#9 | Inspection/test |
| PAR-MOT-023 | Static holding torque ratio | FIXED | worst normal poseでcontinuous actuator torque比: nominal payload<=35%、maximum payload<=50%をdesign target | #6 | Torque/thermal analysis |
| PAR-MOT-024 | Output pose sensing resolution | FIXED | <=0.1° equivalent | #6 | Encoder/measurement inspection |

## 4. Stream / Timing / Communication

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-TIM-001 | Yura→Body Canonical Body State nominal rate | FIXED | 60 Hz | #5,#6 | Stream measurement |
| PAR-TIM-002 | Supported Canonical Body State rate range | FIXED | 30–120 Hz negotiated design range | #5,#6,#8 | Contract/load test |
| PAR-TIM-003 | Edge→MCU target update rate | FIXED | >=200 Hz | #6,#8 | Trace measurement |
| PAR-TIM-004 | MCU inner control-loop rate | FIXED | >=500 Hz。1 kHz級をreference target | #6,#8 | Firmware/servo trace |
| PAR-TIM-005 | Canonical state→physical response latency p50/p95/p99 | FIXED | reference local network/nominal workload: p50<=35ms、p95<=60ms、p99<=100ms | #6 | Timestamp/high-speed measurement |
| PAR-TIM-006 | Canonical state→display response latency p50/p95/p99 | TBD | transport budgetは#5で分離済み。display responseは#8でFreeze | #8 | Timestamp/display measurement |
| PAR-TIM-007 | Sensor capture→Canonical Observation latency p50/p95/p99 | TBD | modality別に#7でFreeze | #7 | Timestamp/log test |
| PAR-TIM-008 | Cross-device clock offset uncertainty | FIXED | LOCKED <=2ms、DEGRADED >2ms and <=10ms、UNSYNCED >10msまたはmapping invalid | #5 | Clock sync test |
| PAR-TIM-009 | Cross-modal alignment error tolerance | FIXED | Full System target <=10ms | #5,#7 | Synchronized stimulus test |
| PAR-TIM-010 | Canonical Body State freshness thresholds | FIXED | FRESH <=100ms、STALE >100–250ms、LOST >250ms→SAFE_HOLD、session/liveness loss 1s→Safe Stop系 | #5,#6 | Fault injection |
| PAR-TIM-011 | Local motion watchdog timeout | FIXED | <=100ms。network/Yuraに依存しないlocal watchdog | #6,#8 | Fault injection |
| PAR-TIM-012 | Dynamic transform normal interpolation gap | FIXED | <=50ms。超過時はDegraded、長時間extrapolation禁止 | #5 | Timestamp/transform test |
| PAR-COM-001 | Normal network one-way latency | FIXED | p95 <=20ms on reference local network | #5 | Network impairment test |
| PAR-COM-002 | Normal network jitter | FIXED | p95 <=10ms | #5 | Network impairment test |
| PAR-COM-003 | Packet loss envelope | FIXED | normal <=1%。5% random loss fault testでもunsafe motion禁止 | #5 | Network impairment test |
| PAR-COM-004 | Reconnect recovery target time | FIXED | transport再確立後<=3sでREADYまたは明示的DEGRADED。motion enableにはfresh-state gate必須 | #5,#8 | Disconnect test |

## 5. Display / Expression

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-DSP-001 | Minimum supported render frame rate | TBD | Reference endpoint能力を踏まえ設定 | #8 | Frame timing test |
| PAR-DSP-002 | Render frame-time jitter | TBD | — | #8 | Frame timing test |
| PAR-DSP-003 | Eye/gaze command resolution | TBD | 微細な視線表現を阻害しない | #4,#8 | Rendering test |
| PAR-DSP-004 | Supported reference display size/mass envelope | TBD | massはPAR-MOT-018/019でFreeze済み。外形寸法・mount geometryは#8でFreeze | #6,#8 | Fit/load inspection |
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
| PAR-THM-002 | Actuator warning/stop temperature | TBD | 選定component ratingとthermal modelから導出 | #6 | Thermal test |
| PAR-THM-003 | Edge warning/throttle/stop temperature | TBD | component ratingより導出 | #8 | Thermal test |
| PAR-ENV-001 | Operating ambient temperature | TBD | indoor desk environment | #6,#8 | Environmental test |
| PAR-ENV-002 | Operating relative humidity | TBD | non-condensing | #6,#8 | Environmental test |
| PAR-ENV-003 | Expected user interaction distance envelope | TBD | vision/audio requirementsの基準 | #7 | Scenario definition |
| PAR-ENV-004 | Expected ambient acoustic noise envelope | TBD | audio verification条件 | #7 | Acoustic environment test |

## 10. Safety / Reliability

| Parameter ID | Parameter | Status | Current value / guidance | Freeze owner | Verification |
|---|---|---|---|---|---|
| PAR-SAF-001 | Emergency stop reaction time | FIXED | local safety input成立からstop reaction開始 <=50ms | #6,#9 | Safety test |
| PAR-SAF-002 | Emergency/safe-stop motion completion | FIXED | maximum normal speed / maximum payloadでmotion cessation <=300ms、reaction開始後追加angular travel <=15° | #6,#9 | Safety test |
| PAR-SAF-003 | Maximum allowable local control fault duration | FIXED | <=100msでlocal watchdog reaction開始 | #6,#8 | Fault injection |
| PAR-SAF-004 | Stability safety factor / test load | FIXED | static factor>=1.5、worst normal pose/max payloadで10N horizontal 2s test | #6,#9 | Analysis/test |
| PAR-SAF-005 | Allowed user-contact force/energy | TBD | 意図的powered contactを基本用途に含めない。residual contact hazardはrisk assessment/適用規格から#9でFreeze | #6,#9 | Force/energy test |
| PAR-REL-001 | Continuous operation test duration | TBD | 常駐用途を代表するduration | #6,#8,#9 | Endurance test |
| PAR-REL-002 | Motion endurance cycle count | FIXED | representative expressive motionで1,000,000 cycles design life target | #6,#9 | Endurance test |
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
