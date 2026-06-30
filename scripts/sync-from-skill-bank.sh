#!/usr/bin/env bash
# Sync skills from the canonical skill-bank into this client plugin repo.
# The skill-bank is the source of truth. Run this after editing a skill in the
# bank, then commit and push — Katie's plugin auto-updates.
#
# Usage:
#   sync-from-skill-bank.sh              # sync all skills in plugin.json
#   sync-from-skill-bank.sh NAME [...]   # sync specific skill(s)
#
# Source resolution: portable client skills live in the client-deploy-kit plugin;
# a few (e.g. speaking-engagement-scout) live only in mfc-skill-bank. For each
# skill we prefer the client-deploy-kit copy and fall back to mfc-skill-bank.
# Override with SKILL_BANK=/path to force a single source dir.
#
# After syncing: update the description in .claude-plugin/marketplace.json
# (even a minor touch triggers update detection in the desktop app).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CDK_BANK="$HOME/code/skill-bank/plugins/client-deploy-kit/skills"
MFC_BANK="$HOME/code/skill-bank/plugins/mfc-skill-bank/skills"
DEST="$REPO_DIR/plugins/katie-spencer/skills"

# Search roots, in priority order. SKILL_BANK overrides to a single dir.
if [[ -n "${SKILL_BANK:-}" ]]; then
  ROOTS=("$SKILL_BANK")
else
  ROOTS=("$CDK_BANK" "$MFC_BANK")
fi

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
  content-strategist
  annual-strategic-planner
  quarterly-strategic-planner
  monthly-gameplan
  weekly-plan
)

if [[ $# -gt 0 ]]; then
  targets=("$@")
else
  targets=("${ALL_SKILLS[@]}")
fi

resolve_src() {
  local name="$1" root
  for root in "${ROOTS[@]}"; do
    if [[ -d "$root/$name" ]]; then
      echo "$root/$name"
      return 0
    fi
  done
  return 1
}

failed=()
for name in "${targets[@]}"; do
  if ! src="$(resolve_src "$name")"; then
    echo "SKIP  $name — not found in any skill-bank root (${ROOTS[*]})" >&2
    failed+=("$name")
    continue
  fi
  echo "Syncing $name  (from ${src#"$HOME"/code/skill-bank/plugins/})..."
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
