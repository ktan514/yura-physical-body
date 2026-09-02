# AI作業指示

このリポジトリで作業するAIは、作業開始前に次を確認すること。

1. `docs/GITHUB_OPERATION_RULES.md`
2. `docs/REPOSITORY_RULES.md`
3. 対象作業のIssue・設計・仕様

特に次を必ず守る。

- 人間向け文章は原則日本語で記述する。
- 一般的な短い技術用語、識別子、`feature`、`fix` などの分類語は使用してよい。
- 上位・保護対象branchへ作業変更を直接commitしない。
- 作業branchを使用し、Pull Request経由で反映する。
- 原則として設計・仕様を確定してから実装する。
- コード変更で仕様・設計が変わる場合、対応する文書も同じ作業で更新する。
- IssueとPull Requestはリポジトリの標準テンプレートに従う。
- Project fieldで管理するStatus、Priority、日付などをIssue本文へ重複管理しない。
- 未確認のtest、CI、reviewをPASS扱いしない。
- `.env`、API key、token、passwordなどの秘密情報を読み上げたり出力したりしない。
