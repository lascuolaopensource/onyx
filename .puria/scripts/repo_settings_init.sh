#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  repo_settings_init.sh [OWNER/REPO]

Description:
  Bootstrap GitHub repository settings for the Puria agent workflow.

  The script configures:
    - squash merge only
    - merge commits disabled
    - rebase merge disabled
    - automatic head branch deletion after merge
    - pull request branch update button enabled
    - default branch ruleset requiring pull requests
    - one approval
    - resolved conversations before merge
    - force-push protection
    - branch deletion protection

Requirements:
  - gh CLI installed
  - authenticated gh session
  - repository administration permission

Examples:
  .puria/scripts/repo_settings_init.sh puria/md
  .puria/scripts/repo_settings_init.sh

If OWNER/REPO is omitted, the script uses the current gh repository context.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

require_cmd gh

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated" >&2
  echo "run: gh auth login" >&2
  exit 1
fi

REPO_FULL_NAME="${1:-}"

if [[ -z "$REPO_FULL_NAME" ]]; then
  REPO_FULL_NAME="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
fi

if [[ -z "$REPO_FULL_NAME" || "$REPO_FULL_NAME" != */* ]]; then
  echo "invalid repository: $REPO_FULL_NAME" >&2
  echo "expected OWNER/REPO" >&2
  exit 1
fi

OWNER="${REPO_FULL_NAME%%/*}"
REPO="${REPO_FULL_NAME#*/}"

DEFAULT_BRANCH="$(gh repo view "$REPO_FULL_NAME" --json defaultBranchRef --jq '.defaultBranchRef.name')"

if [[ -z "$DEFAULT_BRANCH" || "$DEFAULT_BRANCH" == "null" ]]; then
  echo "could not detect default branch for $REPO_FULL_NAME" >&2
  exit 1
fi

echo "repository: $REPO_FULL_NAME"
echo "default branch: $DEFAULT_BRANCH"
echo

echo "checking current repository merge settings..."
gh repo view "$REPO_FULL_NAME" \
  --json allowMergeCommit,allowRebaseMerge,allowSquashMerge,deleteBranchOnMerge \
  --jq .

echo
echo "configuring squash-only merge policy and PR branch cleanup..."
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$OWNER/$REPO" \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=true \
  -f allow_update_branch=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY \
  >/dev/null

echo "merge settings updated"
echo

echo "checking existing protect-default-branch ruleset..."
RULESET_ID="$(
  gh api "/repos/$OWNER/$REPO/rulesets" \
    --jq '.[] | select(.name == "protect-default-branch") | .id' 2>/dev/null || true
)"

RULESET_PAYLOAD="$(mktemp)"
trap 'rm -f "$RULESET_PAYLOAD"' EXIT

cat >"$RULESET_PAYLOAD" <<'JSON'
{
  "name": "protect-default-branch",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "pull_request",
      "parameters": {
        "allowed_merge_methods": ["squash"],
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_approving_review_count": 1,
        "required_review_thread_resolution": true
      }
    }
  ],
  "bypass_actors": []
}
JSON

if [[ -n "$RULESET_ID" ]]; then
  echo "updating existing ruleset: $RULESET_ID"
  gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$OWNER/$REPO/rulesets/$RULESET_ID" \
    --input "$RULESET_PAYLOAD" \
    >/dev/null
else
  echo "creating protect-default-branch ruleset"
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$OWNER/$REPO/rulesets" \
    --input "$RULESET_PAYLOAD" \
    >/dev/null
fi

echo "ruleset configured"
echo

echo "verifying repository merge settings..."
gh repo view "$REPO_FULL_NAME" \
  --json allowMergeCommit,allowRebaseMerge,allowSquashMerge,deleteBranchOnMerge \
  --jq .

echo
echo "verifying rulesets..."
gh api "/repos/$OWNER/$REPO/rulesets" \
  --jq '.[] | select(.name == "protect-default-branch") | {id, name, target, enforcement}'

echo
echo "verifying active rules for $DEFAULT_BRANCH..."
gh api "/repos/$OWNER/$REPO/rules/branches/$DEFAULT_BRANCH" \
  --jq '.[] | {type}' || {
    echo "warning: could not read active rules for $DEFAULT_BRANCH" >&2
    echo "check repository permissions or GitHub plan support for rulesets" >&2
  }

echo
echo "done"
echo
cat <<EOF
Repository bootstrap complete for $REPO_FULL_NAME.

Expected behavior:
  - direct substantial work on $DEFAULT_BRANCH should be blocked
  - PRs should use squash merge only
  - merge commits and rebase merges should be disabled
  - head branches should be deleted after merge
  - PR branches can be updated from the base branch
EOF
