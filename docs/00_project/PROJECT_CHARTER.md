# Project Charter — Yura Physical Body

Status: Draft Baseline v0.1

## 1. プロジェクト目的

デスク上に常駐し、AI「ゆら」の身体として機能する Physical Body を設計・製作する。

Physical Body は単独人格を持つロボットではない。
ゆらシステムから時間連続な身体状態を受け取り物理世界へ表現し、物理世界から得た感覚を構造化してゆらシステムへ返す Body Device である。

## 2. 開発体制

### System Owner
- Yura System 側設計
- Body Boundary Contract
- Edge Runtime
- 結合設計
- システム受入

### Hardware Engineer
- 機構設計
- 駆動系
- 筐体
- 電源・電装
- センサー実装
- MCU/基板
- 製作・実機評価

### ChatGPT
- Full System設計支援
- 要求・仕様の構造化
- 境界仕様作成
- Hardware Handoff文書作成
- 設計レビュー・Issue整理・検証設計支援

## 3. リポジトリ分離

Yura Core は開発中であるため、Physical Body を `ai-liver-yura` に混在させない。

本リポジトリは以下を管理する。

- Physical Body 実装
- Physical Body Edge Runtime
- Display Endpoint
- MCU Firmware
- Hardware設計資料
- Body Boundary Contract
- Calibration / Verification
- Hardware Handoff Package

## 4. 体験要求

- デスク上に「機械が置かれている」より「ゆらがそこにいる」と感じられること。
- 画面UIは目・眉を中心とし、口を持たない。
- 発声はスピーカーで行う。
- 目・眉・視線・物理的な首の3次元運動を統合して感情・注意・反応を表現する。
- モーションプリセット主体ではなく、連続した身体状態追従により生物的な細かなニュアンスを維持する。
- 周囲の人・物・音・接触を感覚として扱えること。

## 5. 基本機構

基準となる頭部機構は以下の3回転自由度とする。

- Yaw
- Pitch
- Roll

各軸は独立かつ同時に連続制御可能であること。

Canonical Body Model は将来の並進自由度・追加関節も表現可能とし、現行機体の3DoFに制約しない。

## 6. Full Design First

本プロジェクトでは Prototype/V1 の作りやすさを理由に Full System の責務や境界を省略しない。

Full System Design Freeze の後に V1 Scope を別途定義する。
