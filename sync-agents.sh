#!/usr/bin/env bash
# sync-agents.sh
# Syncs the Copilot Dev Agents system into a consuming repository.
#
# Usage:
#   # From inside the consuming repo (submodule at .copilot-dev-agents/)
#   ./.copilot-dev-agents/sync-agents.sh
#
#   # Explicit target
#   ./.copilot-dev-agents/sync-agents.sh /path/to/consuming-repo

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(dirname "$SOURCE_DIR")}"

echo ""
echo "Copilot Dev Agents — Sync"
echo "  Source : $SOURCE_DIR"
echo "  Target : $TARGET_DIR"
echo ""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ensure_dir() { mkdir -p "$1"; }

copy_glob() {
    local src_dir="$1" pattern="$2" tgt_dir="$3"
    ensure_dir "$tgt_dir"
    for f in "$src_dir"/$pattern; do
        [ -f "$f" ] || continue
        cp -f "$f" "$tgt_dir/$(basename "$f")"
        echo "  copied  $(basename "$f")  →  $tgt_dir"
    done
}

ensure_file() {
    local tgt="$1" src="$2"
    if [ ! -f "$tgt" ]; then
        ensure_dir "$(dirname "$tgt")"
        cp "$src" "$tgt"
        echo "  created $tgt"
    else
        echo "  exists  $tgt  (skipped)"
    fi
}

# ---------------------------------------------------------------------------
# 1. Agent definition files  →  .github/agents/
# ---------------------------------------------------------------------------

echo "1. Syncing agent definitions..."
copy_glob "$SOURCE_DIR/.github/agents" "*.agent.md" "$TARGET_DIR/.github/agents"

# ---------------------------------------------------------------------------
# 2. Scoped instruction files  →  .github/instructions/
# ---------------------------------------------------------------------------

echo "2. Syncing instruction files..."
copy_glob "$SOURCE_DIR/.github/instructions" "*.instructions.md" "$TARGET_DIR/.github/instructions"

# ---------------------------------------------------------------------------
# 3. Doc templates  →  docs/templates/  (always overwrite — canonical versions)
# ---------------------------------------------------------------------------

echo "3. Syncing doc templates..."
copy_glob "$SOURCE_DIR/docs/templates" "*.md" "$TARGET_DIR/docs/templates"

# ---------------------------------------------------------------------------
# 4. Index files  →  create only if absent (user owns content)
# ---------------------------------------------------------------------------

echo "4. Ensuring index files exist..."
ensure_file "$TARGET_DIR/docs/epics/INDEX.md"   "$SOURCE_DIR/docs/epics/INDEX.md"
ensure_file "$TARGET_DIR/docs/tickets/INDEX.md" "$SOURCE_DIR/docs/tickets/INDEX.md"

# ---------------------------------------------------------------------------
# 5. Inject / update agent-system block in copilot-instructions.md
# ---------------------------------------------------------------------------

echo "5. Updating copilot-instructions.md..."

INSTRUCTIONS_TARGET="$TARGET_DIR/.github/copilot-instructions.md"
INSTRUCTIONS_SOURCE="$SOURCE_DIR/.github/copilot-instructions.md"
START_MARKER="<!-- AGENT-SYSTEM:START -->"
END_MARKER="<!-- AGENT-SYSTEM:END -->"

SOURCE_CONTENT="$(cat "$INSTRUCTIONS_SOURCE")"

INJECTED_BLOCK="
${START_MARKER}
<!-- This block is managed by copilot-dev-agents. Re-run sync-agents.sh to update. -->

${SOURCE_CONTENT}
${END_MARKER}"

if [ -f "$INSTRUCTIONS_TARGET" ]; then
    if grep -qF "$START_MARKER" "$INSTRUCTIONS_TARGET"; then
        # Replace existing block between markers (requires perl for multiline)
        perl -i -0pe \
            "s/\Q${START_MARKER}\E.*?\Q${END_MARKER}\E/${INJECTED_BLOCK//\//\\/}/gs" \
            "$INSTRUCTIONS_TARGET"
        echo "  updated agent-system block in $INSTRUCTIONS_TARGET"
    else
        # Append the block
        printf '%s' "$INJECTED_BLOCK" >> "$INSTRUCTIONS_TARGET"
        echo "  appended agent-system block to $INSTRUCTIONS_TARGET"
    fi
else
    ensure_dir "$(dirname "$INSTRUCTIONS_TARGET")"
    printf '%s' "$INJECTED_BLOCK" > "$INSTRUCTIONS_TARGET"
    echo "  created $INSTRUCTIONS_TARGET"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "Sync complete."
echo "Commit the changes to record the update in your repository."
echo ""
