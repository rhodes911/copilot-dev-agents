#!/usr/bin/env bash
#
# sync-agents.sh
# Syncs the Copilot Dev Agents system into a consuming repository.
#
# Usage:
#   # From inside the consuming repo (submodule at .copilot-dev-agents/)
#   bash .copilot-dev-agents/sync-agents.sh
#
#   # Explicit target path
#   bash .copilot-dev-agents/sync-agents.sh /path/to/consuming-repo
#
# What this script does:
#   - Copies .github/agents/*.agent.md                 into target .github/agents/
#   - Copies .github/instructions/*.instructions.md    into target .github/instructions/
#   - Copies docs/templates/*.md                       into target docs/templates/
#   - Creates docs/epics/INDEX.md if absent
#   - Creates docs/tickets/INDEX.md if absent

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TGT="${1:-$(dirname "$SRC")}"

echo ""
echo "Copilot Dev Agents - Sync"
echo "  Source : $SRC"
echo "  Target : $TGT"
echo ""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ensure_dir() {
    mkdir -p "$1"
}

copy_glob() {
    local src_dir="$1"
    local pattern="$2"
    local tgt_dir="$3"
    ensure_dir "$tgt_dir"
    for f in "$src_dir"/$pattern; do
        [ -f "$f" ] || continue
        cp -f "$f" "$tgt_dir/$(basename "$f")"
        echo "  copied : $(basename "$f")"
    done
}

ensure_file() {
    local tgt_path="$1"
    local src_path="$2"
    if [ ! -f "$tgt_path" ]; then
        ensure_dir "$(dirname "$tgt_path")"
        cp "$src_path" "$tgt_path"
        echo "  created: $tgt_path"
    else
        echo "  exists : $tgt_path (skipped)"
    fi
}

# ---------------------------------------------------------------------------
# 1. Agent definition files
# ---------------------------------------------------------------------------

echo "1. Syncing agent definitions..."
copy_glob "$SRC/.github/agents" "*.agent.md" "$TGT/.github/agents"

# ---------------------------------------------------------------------------
# 2. Instruction files (includes agent-system.instructions.md with applyTo:"**")
# ---------------------------------------------------------------------------

echo "2. Syncing instruction files..."
copy_glob "$SRC/.github/instructions" "*.instructions.md" "$TGT/.github/instructions"

# ---------------------------------------------------------------------------
# 3. Doc templates (always latest - canonical versions)
# ---------------------------------------------------------------------------

echo "3. Syncing doc templates..."
copy_glob "$SRC/docs/templates" "*.md" "$TGT/docs/templates"

# ---------------------------------------------------------------------------
# 4. Index files - create only if absent (user owns content)
# ---------------------------------------------------------------------------

echo "4. Ensuring index files..."
ensure_file "$TGT/docs/epics/INDEX.md"   "$SRC/docs/epics/INDEX.md"
ensure_file "$TGT/docs/tickets/INDEX.md" "$SRC/docs/tickets/INDEX.md"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "Sync complete."
echo "Stage and commit the changes to record the update:"
echo "  git add .github/agents .github/instructions docs/templates"
echo "  git commit -m 'chore: sync copilot-dev-agents'"
echo ""
