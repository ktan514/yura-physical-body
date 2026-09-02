# GitHub共通運用規約

## 1. 適用範囲

本規約は、この雛形から作成されたリポジトリで人間またはAIがGitHub上の情報、設計文書、ソースコード、設定、Issue、Pull Request、レビュー、コミットを作成・編集するときの共通ルールとする。

リポジトリ固有規約は本規約を具体化・強化できる。本規約を緩和する例外は、人間による明示的な承認を必要とする。

## 2. 使用言語

人間が読むことを目的とする文章は原則として日本語を使用する。

対象:

- コミットメッセージ
- Issueタイトル・本文・コメント
- Pull Requestタイトル・本文・コメント
- レビューコメント
- README、設計書、運用書
- コードコメント、docstring
- 人間向けlog、warning、error説明

次は使用してよい。

- API、CI、PR、URL、JSONなど一般的な短い技術用語
- feature、fix、docs、refactor、test、choreなど識別・分類目的の語
- コード識別子、コマンド、パス、branch名、SHA、protocol値、外部仕様の固定値
- 日本語文章中で意味が明確な中学生程度の一般的な英単語

英語だけで成立する説明文章を新規作成しない。

## 3. 設計を先に行う

原則として次の順序で進める。

1. 目的・要求を確認する
2. 設計・仕様を作成または更新する
3. 必要な承認を得る
4. 実装する
5. 検証する
6. レビューする
7. 必要ならHuman Verificationを行う
8. Pull Requestをマージする

コード変更によって仕様・設計が変わる場合、対応する設計・仕様文書も同じ作業で更新する。

直前の作業ですでに設計が確定しており、その設計に従うだけの場合は設計を作り直さない。

## 4. branch運用

`main`、`develop`、release系など、リポジトリで上位・保護対象として扱うbranchへ作業変更を直接commitしない。

変更は作業branchで行い、Pull Requestを経由して上位branchへ反映する。

branch名は原則として次の形式を使用する。

- `feature/<name>`
- `fix/<name>`
- `docs/<name>`
- `refactor/<name>`
- `test/<name>`
- `chore/<name>`

マージ済み作業branchへ新しい作業commitを追加しない。追加作業はマージ先の最新状態から新しいbranchを作成する。

force push、公開済み履歴の不用意な書き換え、CI起動だけを目的とするempty commitや一時変更は原則禁止する。

## 5. コミット

コミットメッセージの説明部分は日本語にする。

推奨形式:

`種別: 日本語による変更概要`

例:

- `feature: 検索条件の保存機能を追加`
- `fix: 起動時に設定が反映されない問題を修正`
- `docs: API利用方針を更新`

1コミットには論理的に関連する変更をまとめ、無関係な変更を混在させない。

commit前に現在branch、変更ファイル、diff、意図しない変更の有無を確認する。

## 6. Issue

Issue本文は `.github/ISSUE_TEMPLATE/` の標準書式に従う。

表記揺れを避けるため、共通見出し名を独自表現へ変更しない。

Projectフィールドで管理する情報はIssue本文へ重複記載しない。

原則としてIssue本文に重複記載しない情報:

- Status
- Priority
- 作業種別
- 領域
- 工程
- Iteration
- Quarter
- Start date
- Target date
- Assignees

Issue本文では、目的、背景、関連Issue、正本、スコープ、対象外、完了条件、検証など、作業内容そのものを記録する。

## 7. Pull Request

変更は原則としてPull Requestを経由する。

Pull Request本文は `.github/pull_request_template.md` の書式に従う。

作業途中はDraft Pull Requestを使用してよい。

PR作成・更新時は、base branch、head branch、対象Issue、設計との一致、変更内容、検証結果を確認する。

レビューやCIの結果は対象となったHEAD SHAに対して成立する。HEAD変更後は、必要なCI・レビューを新しいHEADで再確認する。

## 8. レビュー

実装者自身の確認だけを最終レビューとして扱わない。

レビュー指摘がある場合は、指摘内容を確認して同じ作業lineage上で修正し、新しいHEADに対して必要な検証と再レビューを行う。

AIは未確認のCI・テスト・レビューを成功扱いしてはならない。

## 9. 検証

実装したことだけを完了条件にしない。

リポジトリで定めるtest、lint、type check、build、CIなど必要な検証を実施する。

GUI、実機、音声、映像、外部サービス接続、操作感など自動検証だけで判断できない変更はHuman Verificationを行う。

Human Verificationが必要な作業は、確認前にDoneとして扱わない。

## 10. GitHub Project

Projectを使用する場合、Project fieldのlive stateを現在状態の正本とする。

日程、Priority、StatusなどをIssue本文とProject fieldの両方で重複管理しない。

Project fieldのIDやoption IDを固定値として推測せず、操作時に現在のProjectから取得する。

## 11. 秘密情報

秘密情報を不用意に読み取ったり、表示・commit・Issue・PR・logへ出力したりしない。

対象例:

- `.env`
- API key
- password
- access token
- secret
- private credential

認証状態やアカウントを独断で変更しない。

## 12. 作業範囲

依頼された作業と無関係な変更を混在させない。

別問題を発見した場合、現在作業と分離可能なら別Issue・別作業として扱う。

AIは仕様上の重要な判断、破壊的変更、権限変更、認証変更を独断で決定しない。

## 13. 規約の優先順位

適用順序は次とする。

1. 本GitHub共通運用規約
2. `docs/REPOSITORY_RULES.md` のリポジトリ固有規約
3. 対象ディレクトリ固有規約
4. Issue・設計書など対象作業固有の仕様
5. 今回、人間から明示された指示

より具体的な指示を適用する場合も、上位規約を無断で緩和しない。矛盾が解消できない場合は人間の判断を求める。
