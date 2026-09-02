# yura-physical-body

AI「ゆら」の Physical Body と、ゆらシステムとの境界仕様を管理するためのリポジトリ。

## 目的

本リポジトリは `ai-liver-yura` から独立し、次を Single Source of Truth として管理する。

- Yura System ↔ Body 間の境界契約
- Canonical Body State
- Canonical Observation
- Physical Body Edge Runtime
- Physical Body の機構・電装・センサー要求
- Perception / Sensor Fusion
- Real-time Motion Control
- Display Endpoint
- 安全・障害時動作
- ハードウェア技術者への制作依頼資料
- 結合・受入試験仕様

## 設計原則

1. Full System を先に設計し、V1 は Full System のサブセットとして後から定義する。
2. Live2D / 3D / Physical Body は同じ Canonical Body State 境界に従う。
3. Yura から Body へは動作プリセット名ではなく、時間連続な身体状態を送る。
4. Physical Body は人格判断を行わず、感覚処理・実機制御・安全制御を担う。
5. ハードウェア能力は Capability として宣言し、Yura の身体モデルを機体能力で制限しない。
6. iPhone は Body 本体ではなく、交換可能な Display/Sensor Endpoint の一実装とする。
7. Full System Design Freeze 後に V1 設計およびハードウェア制作依頼資料を確定する。

## 現在の工程

**Full System Design / Baseline v0.1**

V1 の機能削減・部品選定はまだ行わない。

## 主要文書

- `docs/00_project/PROJECT_CHARTER.md`
- `docs/10_requirements/FULL_SYSTEM_REQUIREMENTS.md`
- `docs/20_architecture/FULL_SYSTEM_ARCHITECTURE.md`
- `docs/30_interfaces/BOUNDARY_CONTRACT.md`
- `docs/40_hardware/HARDWARE_DESIGN_BASIS.md`
- `docs/50_perception/PERCEPTION_ARCHITECTURE.md`
- `docs/60_verification/FULL_SYSTEM_VERIFICATION_STRATEGY.md`
- `docs/70_versions/full-system/DESIGN_BASELINE.md`
