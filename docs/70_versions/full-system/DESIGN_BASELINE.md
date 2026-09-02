# Full System Design Baseline v0.1

Date: 2026-09-02
Status: Draft

## Accepted design decisions

### DB-001 Repository Separation
Physical BodyおよびYuraとの境界仕様は `ai-liver-yura` と分離した専用リポジトリで管理する。

### DB-002 Full Design First
V1を先に設計しない。Full System Design Freeze後にV1を切り出す。

### DB-003 Common Body Boundary
Live2D / 3D / Physical Body はCanonical Body Stateを共通境界として扱う。

### DB-004 Continuous Body State
`nod`, `tilt_head` 等のプリセットコマンドを主要境界としない。
Yuraは連続的なDesired Body Stateを生成する。

### DB-005 Physical 3DoF Head
基準Physical HeadはYaw / Pitch / Rollの3回転自由度を採用する。

### DB-006 Physical Face UI
Physical Bodyの主要UI表現はEyes / Eyebrows。
口を必須表示しない。
SpeechはSpeaker。

### DB-007 Replaceable Display Endpoint
iPhoneをReference Display Endpointとするが、専用Display等へ交換可能な抽象境界を持つ。

### DB-008 Edge + MCU
完成形ではBody Edge ComputerとReal-time MCUを分離する。

### DB-009 Full Perception Scope
Full Systemは人物・顔・頭部姿勢・視線・物体・手・ジェスチャー・Depth・音源方向・音源追跡・AEC・Sensor Fusionを設計対象に含む。

### DB-010 Body Has No Personality
Physical Bodyは人格判断を行わない。

### DB-011 Closed-loop Motion
Desired Body StateだけでなくActual Body StateをYuraへ返す。

### DB-012 Coordinate and Time Architecture
座標系・時刻同期を後付けせずFull Systemの基礎要件として設計する。

## Not yet frozen

以下は今後のFull Design工程で決定する。

- exact motion range
- exact torque / payload
- exact acoustic noise target
- exact target latency
- exact stream rates
- exact camera count/spec
- exact depth technology
- exact microphone count/geometry
- exact Edge Computer class
- exact MCU / actuator technology
- power architecture
- thermal architecture
- enclosure dimensions
- iPhone supported size range
- emergency-stop implementation
- communication transport/protocol
