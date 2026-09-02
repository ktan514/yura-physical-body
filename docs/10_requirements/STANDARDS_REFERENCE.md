# Safety / Regulatory Reference Notes

Status: Informative for Issue #3
Last checked: 2026-09-02

本書は要求仕様の参考情報であり、適合宣言ではない。
Design Freeze時点で最新版、適用範囲、日本国内法規との関係を再確認する。

## ISO 13482

### ISO 13482:2014

- Title: `Robots and robotic devices — Safety requirements for personal care robots`
- Official: https://www.iso.org/standard/53820.html
- 人との物理接触を含むpersonal care robotのhazard低減、安全設計・protective measuresを扱う。
- 本Physical Bodyへの直接適用可否は#6/#9でrisk assessmentと合わせて判断する。

### ISO/FDIS 13482

- Title: `Robotics — Safety requirements for service robots`
- Official: https://www.iso.org/standard/83498.html
- 2026-09-02確認時点ではFinal Draft International Standardで、ISO 13482:2014を置き換える予定。
- Full System Design Freeze時点で正式発行状況を再確認する。

### ISO/TR 23482-1:2020

- Title: `Robotics — Application of ISO 13482 — Part 1: Safety-related test methods`
- Official: https://www.iso.org/standard/71564.html
- ISO 13482に関連する安全試験方法の参考資料として利用候補。

## IEC 62368-1

### IEC 62368-1:2023

- Title: `Audio/video, information and communication technology equipment — Part 1: Safety requirements`
- Official: https://webstore.iec.ch/en/publication/69308
- Edition 4.0。2025-08 corrected versionが公開されている。
- Display、audio、ICT/edge compute、power等を含む構成に対するproduct safety観点の適用可能性を#6/#8/#9で評価する。

## 運用ルール

- 参考規格の記載だけで「準拠」「適合」と表現しない。
- 適用対象・除外・試験方法はHardware Requirements / Verificationで明文化する。
- 規格番号だけを固定して将来版の確認を省略しない。
- 市販・配布・無線搭載等の条件が変わった場合、日本国内の法規・認証要求を再評価する。
