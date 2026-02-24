#!/usr/bin/env bash
#
# bootstrap.sh
# Bootstraps the Copilot Dev Agents system into a new or existing repository.
#
# Run from the root of any repository (new or existing). Adds
# copilot-dev-agents as a git submodule, runs the sync, and makes the
# initial commit — so you are ready to use the agents immediately.
#
# Usage:
#   # Quickest: pipe from GitHub raw
#   bash <(curl -fsSL https://raw.githubusercontent.com/rhodes911/copilot-dev-agents/master/bootstrap.sh)
#
#   # With explicit repo URL
#   bash bootstrap.sh https://github.com/rhodes911/copilot-dev-agents
#
#   # Skip commit (stage only)
#   bash bootstrap.sh --skip-commit

set -euo pipefail

AGENTS_REPO="${1:-https://github.com/rhodes911/copilot-dev-agents}"
SKIP_COMMIT=false

# Handle --skip-commit flag anywhere in args
for arg in "$@"; do
    if [ "$arg" = "--skip-commit" ]; then
        SKIP_COMMIT=true
        AGENTS_REPO="${1:-https://github.com/rhodes911/copilot-dev-agents}"
    fi
done

# ---------------------------------------------------------------------------
# Verify we are inside a git repo
# ---------------------------------------------------------------------------

if ! git rev-parse --show-toplevel > /dev/null 2>&1; then
    echo "Error: not inside a git repository. Run 'git init' first."
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo ""
echo "Copilot Dev Agents - Bootstrap"
echo "  Repo root  : $REPO_ROOT"
echo "  Agents src : $AGENTS_REPO"
echo ""

# ---------------------------------------------------------------------------
# Add submodule (skip if already present)
# ---------------------------------------------------------------------------

SUBMODULE_PATH=".copilot-dev-agents"

if [ -d "$SUBMODULE_PATH/.git" ]; then
    echo "Submodule already present. Pulling latest..."
    git submodule update --remote "$SUBMODULE_PATH"
else
    echo "Adding submodule..."
    git submodule add "$AGENTS_REPO" "$SUBMODULE_PATH"
    git submodule update --init "$SUBMODULE_PATH"
fi

# ---------------------------------------------------------------------------
# Run sync
# ---------------------------------------------------------------------------

echo ""
SYNC_SCRIPT="$REPO_ROOT/$SUBMODULE_PATH/sync-agents.sh"

if [ ! -f "$SYNC_SCRIPT" ]; then
    echo "Error: sync script not found at $SYNC_SCRIPT"
    exit 1
fi

bash "$SYNC_SCRIPT" "$REPO_ROOT"

# ---------------------------------------------------------------------------
# Commit
# ---------------------------------------------------------------------------

if [ "$SKIP_COMMIT" = false ]; then
    echo "Committing..."
    git add "$SUBMODULE_PATH" .gitmodules \
        .github/agents .github/instructions docs/templates \
        docs/epics/INDEX.md docs/tickets/INDEX.md 2>/dev/null || true

    if git diff --cached --quiet; then
        echo ""
        echo "Nothing new to commit — already up to date."
    else
        git commit -m "chore: bootstrap copilot-dev-agents"
        echo ""
        echo "Bootstrap complete. The development agents are ready."
    fi
else
    echo ""
    echo "Bootstrap complete (commit skipped). Stage and commit when ready."
fi

echo ""
echo "Open Copilot Chat in VS Code, pick an agent from the dropdown, and start."
echo ""
