#!/usr/bin/env bash
set -euo pipefail

command -v gh >/dev/null 2>&1 || { echo "gh コマンドが必要です。" >&2; exit 1; }
gh auth status >/dev/null

REPO="${1:-}"
if [[ -z "$REPO" ]]; then
  REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
fi

DEFAULT_BRANCH="$(gh repo view "$REPO" --json defaultBranchRef --jq .defaultBranchRef.name)"

echo "対象: $REPO"
echo "既定branch: $DEFAULT_BRANCH"

# GitHubのプラン・権限によってbranch protectionを利用できない場合があるため、
# 失敗時は理由を表示して終了する。規約自体はAGENTS.mdとdocsで常に有効。
if gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/branches/$DEFAULT_BRANCH/protection" \
  --input - <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": false
}
JSON
then
  echo "上位branchのPull Request経由ルールを設定しました。"
else
  echo "branch protectionを自動設定できませんでした。GitHubの権限またはプランを確認してください。" >&2
  exit 2
fi
