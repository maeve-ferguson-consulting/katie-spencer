#!/usr/bin/env bash
# Sync skills from the canonical skill-bank into this client plugin repo.
# The skill-bank is the source of truth. Run this after editing a skill in the
# bank, then commit and push — Katie's plugin auto-updates.
#
# Usage:
#   sync-from-skill-bank.sh              # sync all skills in plugin.json
#   sync-from-skill-bank.sh NAME [...]   # sync specific skill(s)
#
# After syncing: update the description in .claude-plugin/marketplace.json
# (even a minor touch triggers update detection in the desktop app).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_BANK="${SKILL_BANK:-$HOME/code/skill-bank/plugins/mfc-skill-bank/skills}"
DEST="$REPO_DIR/plugins/katie-spencer/skills"

# Skills currently in this plugin (order matches plugin.json)
ALL_SKILLS=(
  define-brand-voice
  build-carousel
  build-story
  speaking-engagement-scout
  craft-outreach
  prep-discovery
  build-proposal
  build-agreement
  plan-content
  write-newsletter
  repurpose-content
  chief-of-staff
)

if [[ $# -gt 0 ]]; then
  targets=("$@")
else
  targets=("${ALL_SKILLS[@]}")
fi

failed=()
for name in "${targets[@]}"; do
  src="$SKILL_BANK/$name"
  if [[ ! -d "$src" ]]; then
    echo "SKIP  $name — not found in skill-bank at $src" >&2
    failed+=("$name")
    continue
  fi
  echo "Syncing $name..."
  rsync -a --delete \
    --exclude='evals/' \
    --exclude='workspace/' \
    "$src/" "$DEST/$name/"
  echo "  OK"
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo ""
  echo "FAILED to sync: ${failed[*]}" >&2
  exit 1
fi

echo ""
echo "Synced: ${targets[*]}"
echo ""
echo "Next steps:"
echo "  1. Update the description in .claude-plugin/marketplace.json (triggers auto-update)"
echo "  2. Validate: claude plugin validate ."
echo "  3. Commit and push"
