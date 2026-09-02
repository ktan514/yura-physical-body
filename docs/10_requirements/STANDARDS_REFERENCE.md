# Safety / Regulatory Reference Notes

Status: Informative for Full System Design
Last checked: 2026-09-02

本書は要求仕様の参考情報であり、適合宣言ではない。
Design Freeze時点で最新版、適用範囲、日本国内法規との関係を再確認する。

## ISO 12100

### ISO 12100:2010

- Title: `Safety of machinery — General principles for design — Risk assessment and risk reduction`
- Official: https://www.iso.org/standard/51528.html
- 2022年にreview/confirmされ、2026-09-02時点ではpublished/current版。
- hazard identification、risk estimation/evaluation、inherently safe design、protective measures、残留riskのdocument化に関する基礎方法論として#6/#9で参照する。

### ISO/DIS 12100.3

- Title: `Safety of machinery — General principles for design — Risk assessment and risk reduction`
- Official: https://www.iso.org/standard/88578.html
- ISO 12100:2010の後継として開発中。
- Full System Design Freeze時点で発行状況を再確認する。

## ISO 13482

### ISO 13482:2014

- Title: `Robots and robotic devices — Safety requirements for personal care robots`
- Official: https://www.iso.org/standard/53820.html
- 人との物理接触を含むpersonal care robotのhazard低減、安全設計・protective measuresを扱う。
- 本Physical Bodyへの直接適用可否は#6/#9でrisk assessmentと合わせて判断する。

### ISO/FDIS 13482

- Title: `Robotics — Safety requirements for service robots`
- Official: https://www.iso.org/standard/83498.html
- 2026-09-02確認時点ではFinal Draft International Standard、approval phaseで、ISO 13482:2014を置き換える予定。
- personal/professional service robotと人とのphysical contact、functional safetyを含む安全要求を扱う。
- Full System Design Freeze時点で正式発行状況を再確認する。

### ISO/TR 23482-1:2020

- Title: `Robotics — Application of ISO 13482 — Part 1: Safety-related test methods`
- Official: https://www.iso.org/standard/71564.html
- ISO 13482に関連する安全試験方法の参考資料として利用候補。
- test parameterはrobot design/useのrisk assessmentに基づきmanufacturerが決定する考え方を参考にする。

## IEC 62368-1

### IEC 62368-1:2023

- Title: `Audio/video, information and communication technology equipment — Part 1: Safety requirements`
- Official: https://webstore.iec.ch/en/publication/69308
- Edition 4.0。
- Display、audio、ICT/edge compute、power等を含む構成に対するproduct safety観点の適用可能性を#6/#8/#9で評価する。

## #6での扱い

#6では以下を安全設計原則へ反映する。

- hazardをまず機構・低energy化・配置で除去する
- residual pinch/shear/contact riskをsoftwareだけで成立させない
- power/network loss時のlocal fail-safeを持つ
- contact force/clearance等、robot geometryとrisk assessmentに依存する値を規格名だけから推測して固定しない
- final acceptance parameterは#9で適用規格とrisk assessmentを確認してFreezeする

## 運用ルール

- 参考規格の記載だけで「準拠」「適合」と表現しない。
- 適用対象・除外・試験方法はHardware Requirements / Verificationで明文化する。
- 規格番号だけを固定して将来版の確認を省略しない。
- 市販・配布・無線搭載等の条件が変わった場合、日本国内の法規・認証要求を再評価する。
