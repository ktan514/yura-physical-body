# リポジトリ固有規約

共通規約は `GITHUB_OPERATION_RULES.md` を正本とし、本書には本リポジトリ固有の追加規約のみ記載する。

## リポジトリの責務

本リポジトリは Physical Body と Yura System の境界仕様、および Physical Body 側の設計・実装・検証を管理する。

`ai-liver-yura` 内部の人格、記憶、感情、欲求、意思決定、会話生成等は本リポジトリの責務外とする。

## 設計順序

1. Full System Requirements
2. Full System Architecture
3. Boundary / Interface Contract
4. Perception / Motion / Safety / Hardware Architecture
5. Verification Architecture
6. Full System Design Freeze
7. V1 Scope Selection
8. V1 Design
9. Hardware Handoff Package
10. Implementation / Fabrication / Integration / Verification

V1 都合で Full System の要求・境界を削除してはならない。

## 正本

- Body 境界契約: `docs/30_interfaces/`
- Full System要求: `docs/10_requirements/`
- Full System構成: `docs/20_architecture/`
- Hardware要求: `docs/40_hardware/`
- Perception: `docs/50_perception/`
- Verification: `docs/60_verification/`

## Body Contract の変更

Body Contract は本リポジトリを正本とする。

境界契約の破壊的変更は Issue で影響範囲を明示し、契約バージョンを更新する。
`ai-liver-yura` 側だけで Physical Body Contract を独自変更してはならない。

## ハードウェアとソフトウェアの分離

システム側は要求性能・境界・安全条件を定義する。
部品型番・機構実現方式・基板実装方式は、要求を満たす範囲でハードウェア技術者の設計裁量とする。

## 保護対象 branch

- `main`

## Full System Design Freeze

Full System Design Freeze 以前に V1 の制約を Full System へ逆流させてはならない。
