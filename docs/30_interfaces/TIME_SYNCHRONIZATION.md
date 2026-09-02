# Canonical Time / Synchronization Model

Status: Draft for Issue #5 Review
Revision: 0.1-draft

## 1. 目的

Camera、Audio、Display、Body Edge、MCU、Yuraが異なるclock domainで動作しても、Observation・Actual Body State・Desired Body Stateを同じ時間軸へ安全に対応付けられるよう時刻モデルを定義する。

---

## 2. 原則

1. 順序・timeout・latency計測はmonotonic clockをauthorityとする。
2. wall clockは表示・audit用であり、real-time ordering authorityとしない。
3. 異なるsource clockのtimestampを直接比較しない。
4. source clockからsession clockへのmappingにはoffset / drift / uncertaintyを持つ。
5. sync qualityが不十分な場合、精度が必要なcross-modal fusion/transformを正常値として扱わない。

---

## 3. Clock domain

各producerは`source_clock_id`を持つ。

例:

- `yura.monotonic`
- `body-edge.monotonic`
- `mcu.monotonic`
- `iphone.monotonic`
- `camera-front.clock`
- `audio-array.clock`

source timestampは原則integer nanosecondsとする。

clock originはsource起動時等のimplementation-defined epochでよく、他clockと同epochである必要はない。

---

## 4. Session time authority

Yura ↔ Physical Body sessionでは、**Body Edge monotonic clockをsession time authority**とする。

理由:

- Physical sensor / MCU / display endpointのhubである
- Yura network disconnect中もBody側time alignmentを維持できる
- Sensor FusionとActual Body State interpolationをBody側で完結できる

`session_time_ns`はBody Edge monotonic domainに対応する。

Yuraは自身のmonotonic clockをsession timeへmappingする。

---

## 5. Clock mapping model

source clock `t_source` からsession clock `t_session`へのmappingを概念的に:

```text
t_session = scale * t_source + offset
```

で表す。

管理対象:

- offset
- drift/scale
- uncertainty
- sampled_at
- mapping revision
- sync state

実装はlinear drift model以外を使用してよいが、外部へは等価なmapping品質を公開する。

---

## 6. Synchronization exchange

Network-connected endpoint間では、NTP/PTP系のfour-timestamp exchangeまたは同等以上のoffset/round-trip推定を継続実行する。

特定library/protocolの内部実装は#8で選定してよい。

ただし次を満たすこと。

- periodic resynchronization
- RTT outlier rejection
- drift estimation
- uncertainty estimation
- clock step/reset detection

---

## 7. Wall clock

UTC wall clockを保持可能だがoptionalとする。

使用例:

- human-readable log
- audit
- issue reproduction

禁止:

- safety timeoutをwall clockで判定
- wall clock correctionによるsequence reversal
- NTP clock stepをmonotonic duration計測へ使用

---

## 8. Timestamp semantics

共通Envelopeの時刻を次の意味とする。

### `sampled_at`
物理状態・sensor sample・Desired stateがsource上で成立した時刻。

### `generated_at`
message objectを生成したsource時刻。

### `received_at`
transport receiverがlocalで受信した時刻。wire fieldとして必須ではなくlocal telemetryでもよい。

### `session_sampled_at`
`sampled_at`をsession timeへ変換した値。sync mappingがvalidな場合のみ提供する。

### `time_sync_revision`
使用したclock mapping revision。

---

## 9. Sync quality state

各clock mappingは次の状態を持つ。

- `LOCKED`
- `DEGRADED`
- `UNSYNCED`
- `RESET_DETECTED`

### LOCKED
cross-modal fusion / moving-frame transformに通常利用可能。

### DEGRADED
単独modality利用は可能だが、高精度fusion/transformのqualityを低下させる。

### UNSYNCED
source timestampのorderingはsource内でのみ有効。異clock fusionに使用しない。

### RESET_DETECTED
source restart/wrap/reset等を検知。新clock epochとして再同期する。

---

## 10. Full System target

Issue #5の設計targetとして次を採用する。

- `LOCKED`: estimated absolute offset uncertainty <= 2 ms
- `DEGRADED`: > 2 ms and <= 10 ms
- `UNSYNCED`: > 10 ms、mappingなし、またはclock discontinuity中

これは通信RTTそのものではなくclock mapping uncertaintyの判定である。

後続実機で達成不能と判明した場合はParameter Registerを根拠付きで改訂する。

---

## 11. Cross-modal alignment target

Camera / Audio / Actual Body State等を同一eventとしてfusionする場合、Full System design targetとしてcross-modal alignment errorを **10 ms以下** とする。

より厳しいmodalityが必要な場合は#7で追加要求を定義できる。

---

## 12. Dynamic transform interpolation

Sensor sample時刻 `t` に対するActual Body transformは:

1. session timeへalign
2. `t`を挟む2つのActualBodyState sampleを取得
3. translationをlinear interpolation
4. orientationをshortest-path quaternion interpolation（SLERP等）

で求める。

通常transform用途の最大interpolation gap design targetを **50 ms** とする。

50 msを超えるsample gapではqualityをDegraded扱いとし、外挿を標準動作としない。

---

## 13. Extrapolation

未来方向extrapolationは原則禁止する。

Display rendering等、局所的なpresentation smoothingで予測を使用する場合もCanonical authorityを書き換えない。

Sensor Observationのworld transformには実測Actual Stateを優先し、長いextrapolationを使用しない。

---

## 14. Sequenceとtime

`sequence`はstream内ordering authority、timestampはtime semantics authorityである。

- sequenceが小さいmessageはlate/out-of-orderとして扱う
- 同sequenceのduplicateは再適用しない
- clock anomalyがあってもsequence orderingを失わない
- new `stream_id`ではsequence namespaceをreset可能

---

## 15. Latency measurement

latencyは最低限次を分離する。

- source sampling delay
- encode/serialization delay
- network delay
- queueing delay
- processing delay
- actuator/display response delay

一つの総latency値だけで原因を隠さない。

p50 / p95 / p99を取得可能にする。

---

## 16. Clock discontinuity

以下を検知した場合:

- monotonic counter reset
- endpoint reboot
- abnormal jump
- timer wrap
- mapping residual急増

そのclock mappingをinvalidateし、`RESET_DETECTED`へ遷移する。

新しいclock epochを確立するまでcross-device transform/fusionを通常品質扱いしない。

---

## 17. Startup synchronization

Session開始時:

```text
Transport established
   ↓
Contract negotiation
   ↓
Clock synchronization
   ↓
Capability / calibration validation
   ↓
READY
```

clock mappingがLOCKED必須な機能は、LOCKED前に有効化しない。

単独sensor等、sync不要なCapabilityはDegraded stateとして先行利用してもよい。

---

## 18. Reconnect

Reconnectでは以前のclock mappingを無条件再利用しない。

endpoint identity / boot ID / clock epochを確認する。

同一boot epochでmappingが継続validと確認できる場合のみ再利用可能。

---

## 19. Diagnostics

最低限公開する。

- source clock ID
- boot/epoch ID
- sync state
- offset estimate
- drift estimate
- uncertainty
- RTT estimate
- mapping revision
- last synchronization time
- rejected sync sample count

---

## 20. Freeze事項

Issue #5で次をFreezeする。

- Body Edge monotonicをsession time authorityとする
- source timestampはmonotonic ns
- wall clockをreal-time authorityにしない
- offset/drift/uncertainty付きclock mapping
- LOCKED <= 2 ms uncertainty
- DEGRADED <= 10 ms uncertainty
- cross-modal alignment target <= 10 ms
- normal dynamic-transform interpolation gap target <= 50 ms
- clock reset時はmappingをinvalidateする
