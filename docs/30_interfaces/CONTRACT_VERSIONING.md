# Body Contract Versioning / Compatibility

Status: Draft for Issue #4 Review
Revision: 0.1-draft

## 1. 目的

Yura SystemとBody implementationを独立開発できるよう、Contract変更時の互換性・negotiation・deprecation規則を定義する。

---

## 2. Version format

Contract versionはSemantic Versioning形式を使用する。

```text
MAJOR.MINOR.PATCH
```

### MAJOR

既存consumerが同じ意味で処理できないbreaking change。

例:

- field意味の変更
- unit変更
- required field削除
- enum意味の再定義
- snapshot semantics変更

### MINOR

後方互換な追加。

例:

- optional field追加
- optional observation type追加
- optional capability追加
- optional extension namespace追加

### PATCH

wire meaningを変えない修正。

例:

- 文書clarification
- typo修正
- validation説明追加

---

## 3. Negotiation

Session開始時に双方はsupportするContract version/rangeを提示する。

概念例:

```text
Yura supports: 1.2.x - 1.5.x
Body supports: 1.3.x - 1.4.x
Negotiated: 1.4.x
```

version選択algorithmのtransport詳細は#5で定義する。

---

## 4. Required core capability

Versionがcompatibleでも、session成立に必要なcore capabilityが不足する場合がある。

そのためnegotiationは少なくとも次を別々に確認する。

1. Contract compatibility
2. Required capability satisfaction
3. Health/safety readiness

---

## 5. Unknown fields

同一MAJOR内のunknown optional fieldは無視可能でなければならない。

ただし、

- unknown fieldを既知fieldへ読み替えない
- unknown fieldの存在で既知field意味を変更しない
- safety-critical意味をunknown optional fieldだけに依存させない

---

## 6. Required vs Optional

schema elementはrequired/optionalを明示する。

Minor versionで既存optional fieldをrequiredへ昇格させてはならない。

required化が必要な場合、原則MAJOR changeとする。

---

## 7. Enum evolution

Enumに新値を追加する場合、consumerがunknown valueを受けた際のfallbackを定義する。

安全状態・fault severity等、unknownを安全に扱えないenumでは、unknown valueを正常状態へfallbackしてはならない。

例:

```text
unknown safety state → treat as non-normal / fail-safe
```

---

## 8. Field meaning immutability

一度公開したfieldの意味・unit・rangeを別用途へ再利用しない。

不要になったfieldはdeprecateし、新fieldを追加する。

---

## 9. Deprecation

Deprecated field/typeは次を持つ。

- deprecated since version
- replacement field/type
- removal earliest major version
- migration note

同一MAJOR内で即時削除しない。

---

## 10. Extensions

Namespaced extensionを許可する。

```text
extensions["vendor-or-project.namespace.feature"]
```

Extensionはcore compatibilityを破壊してはならない。

複数implementationで安定利用されるextensionはcore schemaへの昇格を検討する。

---

## 11. Profile versioning

`Canonical Body Profile`とContract versionを区別する。

Contract version:

- message/schema/meaningの互換性

Profile:

- 使用するcanonical channel集合
- profile固有のrequired channel

同じContract version上に複数Profileを定義可能とする。

---

## 12. Capability revision

Capability変更はContract version変更ではない。

例:

```text
Depth camera故障
→ contract version = 1.4.0 のまま
→ capability_revision 23 → 24
→ depth = temporarily_unavailable
```

---

## 13. Calibration / Device version

次もContract versionとは独立して管理する。

- hardware revision
- firmware version
- software version
- perception model version
- calibration revision
- transform revision

これらはprovenance/healthで追跡する。

---

## 14. Breaking change examples

以下はMAJOR change候補である。

- orientationをquaternionから別representationへ置換
- meterをmillimeterへ変更
- confidence rangeを0..1から0..100へ変更
- person `track_id`を永続identityへ意味変更
- absent fieldの意味をsnapshotからhold-lastへ変更

---

## 15. Non-breaking change examples

以下はMINOR change候補である。

- optional eyebrow channel追加
- new optional environment observation追加
- additional provenance field追加
- optional actuator health telemetry追加

---

## 16. Conformance

Contract implementationは将来#9で次を検証可能にする。

- schema conformance
- required field presence
- range/unit validation
- unknown optional field tolerance
- version negotiation
- capability negotiation
- deprecated field migration
- incompatible MAJOR rejection
- unknown safety enum fail-safe behavior

---

## 17. Authority

Body Contractの正本は本`yura-physical-body` repositoryとする。

`ai-liver-yura`、Live2D adapter、3D adapter、Physical Body implementationが個別に同名fieldの意味を変更してはならない。
