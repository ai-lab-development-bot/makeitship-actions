#!/usr/bin/env bash
# Repository checks, run in CI and locally: actionlint over the shared workflows
# and over each host's caller templates (placeholders filled), and the mark-deploy
# block kept identical in deploy.yml and mark.yml.
set -euo pipefail
cd "$(dirname "$0")/.."

actionlint .github/workflows/*.yml

for host in templates/*/; do
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/.github/workflows"
  for f in "$host"*.yml; do
    sed 's/__[A-Z_]*__/placeholder/g' "$f" > "$tmp/.github/workflows/$(basename "$f")"
  done
  # The callers reference this repository at @v1, which actionlint cannot fetch.
  (cd "$tmp" && actionlint -ignore 'could not read reusable workflow' .github/workflows/*.yml)
  rm -rf "$tmp"
done

block() { sed -n '/# >>> mark-deploy/,/# <<< mark-deploy/p' "$1"; }
if ! diff <(block .github/workflows/deploy.yml) <(block .github/workflows/mark.yml) >/dev/null; then
  echo "The mark-deploy block differs between deploy.yml and mark.yml; keep them identical." >&2
  exit 1
fi
echo "All checks passed."
