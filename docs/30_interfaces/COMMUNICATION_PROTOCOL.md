# Yura ↔ Body Communication Protocol

Status: Draft for Issue #5 Review
Revision: 0.1-draft

## 1. 目的

Yura SystemとBody Edge間で、Canonical Body State、Actual Body State、Observation、Capability、Health、controlを低遅延かつ安全に交換する通信設計を定義する。

本書はYura↔Body EdgeのFull System reference profileを対象とする。Edge↔MCUのreal-time field protocolは#6/#8で確定する。

---

## 2. Communication plane

通信を次のlogical planeへ分離する。

1. **Control Plane**
   - session lifecycle
   - version/capability negotiation
   - calibration/config control
   - safety/fault acknowledgement
2. **State Plane**
   - CanonicalBodyState
   - ActualBodyState
3. **Observation Plane**
   - CanonicalObservationBatch
   - track update
4. **Health Plane**
   - BodyCapabilitySnapshot
   - BodyHealthSnapshot
   - critical event
5. **Media Plane**
   - raw/encoded camera/audio等

異なるQoSを同一queueへ混載しない。

---

## 3. Reference transport profile

Full SystemのYura↔Body Edge reference transportとして以下を採用する。

- transport: **QUIC**
- security: **TLS 1.3**
- structured message encoding: **Protocol Buffers**
- reliable/ordered data: QUIC bidirectional/unidirectional streams
- freshness-dominant high-rate state: QUIC DATAGRAMを第一候補
- media: WebRTC/SRTP等のmedia-specific channelを使用可能。最終Media Endpoint分割は#7/#8で確定

理由:

- stream multiplexing
- connection migration/recovery flexibility
- TLS 1.3 built-in security
- state系でhead-of-line blockingを避けるdatagram option
- reliable controlとfreshness-priority stateを同一session内で分離可能

---

## 4. Transport independence

Canonical Contract自体はQUIC/Protobufへ依存しない。

将来transportを変更しても:

- message semantics
- units
- capability semantics
- ordering semantics
- safety semantics

を変更しない。

別transport implementationは本書と等価なQoS/ordering/securityを満たす必要がある。

---

## 5. Wire format

Reference binary encodingはProtocol Buffersとする。

規則:

- field numberを一度公開後に再利用しない
- removed field number/nameをreserved扱いにする
- unknown optional fieldを安全に無視可能にする
- enum unknown valueをfatal parse errorにしない
- units/semanticsは#4 Contract文書をauthorityとする
- transport implementation固有fieldをCanonical modelへ混入させない

Concrete `.proto` fileは実装開始時に本仕様から生成し、同じContract version管理下に置く。

---

## 6. Session identity

各接続sessionは次を持つ。

- `session_id`
- local/remote endpoint identity
- negotiated contract version
- transport profile version
- established_at
- peer boot/epoch ID

Reconnect後は同じTCP的connectionの延長と仮定せず、新sessionとして扱えること。

---

## 7. Stream identity

各logical streamは:

- `stream_id`
- producer `source_id`
- `sequence`
- stream type
- quality class

を持つ。

`sequence`はstream内で単調増加する。

新stream_idではsequence namespaceを新規開始できる。

---

## 8. QoS class

### Q0 — Safety Critical Reliable

対象:

- emergency/safe-stop related control
- critical fault
- session termination

性質:

- reliable
- ordered where meaningful
- acknowledged
- duplicate-safe/idempotent

### Q1 — Control Reliable

対象:

- negotiation
- capability
- calibration/config
- lifecycle

性質:

- reliable ordered stream
- retry可能
- idempotency keyを利用可能

### Q2 — Fresh State

対象:

- CanonicalBodyState
- high-rate ActualBodyState

性質:

- latest value優先
- stale frame再送を要求しない
- receiver queueは原則latest-only
- QUIC DATAGRAM優先

### Q3 — Observation Update

対象:

- person/object/sound track update等

性質:

- observation typeごとにreliable/freshnessをCapabilityで指定可能
- high-rate trackはlatest-wins可能
- discrete touch/fault-like eventはreliable classへ昇格

### Q4 — Media

- audio/video stream
- dedicated media transport/QoS

---

## 9. CanonicalBodyState delivery

Full System reference:

- nominal source rate: **60 Hz**
- negotiable design range: **30–120 Hz**

ReceiverはCanonicalBodyStateをFIFO backlogとして全件再生してはならない。

### latest-wins rule

新しいvalid sequenceを受信した場合、まだ実行していない古いstateは破棄可能。

目的は「過去の身体姿勢を忠実に再生する」ことではなく「現在のYura身体状態へ追従する」ことである。

---

## 10. Datagram unavailable fallback

QUIC DATAGRAMが利用できないtransport implementationではreliable streamを使用してよい。

ただし:

- application queue depthを原則1 latest sample相当へ制限
- obsolete frameをdecode/apply前後でdrop
- retransmission backlogをmotion timelineとして再生しない

ことを必須とする。

---

## 11. Reliable event duplicate handling

Control/event系messageは`message_id`またはidempotency keyでduplicate applyを防ぐ。

例:

- calibration apply
- reset
- mode transition
- safety acknowledgement

同じmessageをtransport retryで複数受信してもside effectを重複実行しない。

---

## 12. Authentication / authorization

Yura↔Body Edge control linkは相互peer authenticationを行う。

reference profileでは:

- TLS 1.3
- certificateまたは同等のdevice enrollment credential
- authorized Yura identityのみBody control可能

を要求する。

秘密情報の配布・rotation詳細は#8で定義する。

---

## 13. Encryption

Control/State/Observation/Health planeはtransport encryptionを必須とする。

Raw mediaもnetworkを通過する場合は暗号化する。

local trusted segmentであってもcontrol plane平文をFull System標準としない。

---

## 14. QUIC 0-RTT

Replay可能性があるため、side-effectful control、motion enable、calibration変更、安全状態変更に0-RTT dataを使用してはならない。

read-only capability query等へ使用する場合も明示的にsafeと分類する。

---

## 15. Keepalive / liveness

Transport-level connection状態だけでBodyの安全状態を判断しない。

Application-level heartbeat/health freshnessを持つ。

Heartbeatは:

- session liveness
- peer application responsiveness
- clock mapping freshness

を確認する。

具体heartbeat周期はimplementationでstream rateと整合させるが、stale timeoutより十分短くする。

---

## 16. Network design envelope

Full Systemのlocal-network normal targetを次とする。

- one-way network latency p95: **20 ms以下**
- network jitter p95: **10 ms以下**
- normal packet loss: **1%以下**

Fault-tolerance verificationではrandom packet loss **5%** 条件でもunsafe motionを発生しないことを要求する。

5% loss条件で通常表現品質を保証するものではない。

---

## 17. Congestion / backpressure

優先順位:

```text
Safety > Control/Health > Body State > Observation > Debug/Telemetry > Raw Media quality
```

帯域不足時にSafety/Controlをraw mediaが圧迫してはならない。

Backpressure時:

- old stateをdrop
- observation samplingをdegrade可能
- media bitrate/frame rateをdegrade可能
- safety/controlを優先

---

## 18. Reconnect target

Transport再確立後、正常なnetwork・device状態で **3秒以内を目標**にREADYまたは明示的DEGRADEDへ到達する。

ただしMotion enableはhandshake完了条件を満たすまで行わない。

---

## 19. Reconnect handshake

Reconnect時:

1. peer authentication
2. new session ID確立
3. Contract version negotiation
4. peer boot/clock epoch確認
5. clock synchronization
6. Capability snapshot取得
7. calibration revision確認
8. Health確認
9. fresh CanonicalBodyState stream開始
10. motion enable

以前のlast commandを自動再実行しない。

---

## 20. Capability negotiation

Negotiationは最低限:

- Contract version range
- transport profile
- datagram support
- stream rate range
- Body channels
- observation types
- media capability
- max message size
- compression support where applicable

を交換する。

両者にcompatible contract versionが存在しない場合、Normalへ遷移しない。

---

## 21. Message size / fragmentation

Canonical state/control messageへ巨大raw media payloadを直接埋め込まない。

Large media/blobは別channel/object referenceを使用する。

これによりcontrol/state latencyをmedia sizeから分離する。

---

## 22. Compression

高頻度小型CanonicalBodyStateを無条件圧縮しない。

圧縮コストがpayload削減を上回る可能性があるため、message classごとにnegotiationする。

Mediaはcodec固有compressionを使用する。

---

## 23. Observability

通信telemetryとして最低限:

- sent/received rate
- bytes/sec
- sequence gap
- duplicate
- reorder
- drop
- queue depth
- one-way latency estimate where clock quality permits
- RTT
- reconnect count
- session duration
- transport error

を取得可能とする。

---

## 24. Security failure

Authentication failure、certificate/credential invalid、protocol downgrade不成立時:

- motion controlを有効化しない
- raw mediaを送出しない
- failure reasonをdiagnosticへ残す
- repeated unauthenticated commandを適用しない

---

## 25. Freeze事項

Issue #5で次をFull System reference profileとしてFreezeする。

- QUIC + TLS 1.3
- Protocol Buffers
- reliable control planeとfreshness state planeの分離
- CanonicalBodyState nominal 60 Hz
- negotiated design range 30–120 Hz
- state latest-wins semantics
- control/event idempotency
- one-way network latency p95 <= 20 ms normal target
- network jitter p95 <= 10 ms normal target
- normal packet loss <= 1%
- 5% random packet loss fault testでもunsafe motionを起こさない
- reconnect to READY/DEGRADED target <= 3 s

Media protocol詳細、credential lifecycle、Edge↔MCU protocolは#7/#8でFreezeする。
