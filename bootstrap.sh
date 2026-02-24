#!/usr/bin/env bash
set -euo pipefail

AGENTS_REPO="https://github.com/rhodes911/copilot-dev-agents"
SKIP_COMMIT=false

for arg in "$@"; do
    case "$arg" in
        --skip-commit) SKIP_COMMIT=true ;;
        http*) AGENTS_REPO="$arg" ;;
    esac
done

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

SUBMODULE_PATH=".copilot-dev-agents"

if [ -d "$SUBMODULE_PATH/.git" ]; then
    echo "Submodule already present - pulling latest..."
    git submodule update --remote "$SUBMODULE_PATH"
else
    echo "Adding submodule..."
    git submodule add "$AGENTS_REPO" "$SUBMODULE_PATH"
    git submodule update --init "$SUBMODULE_PATH"
fi

echo ""
SYNC_SCRIPT="$REPO_ROOT/$SUBMODULE_PATH/sync-agents.sh"

if [ ! -f "$SYNC_SCRIPT" ]; then
    echo "Error: sync script not found at $SYNC_SCRIPT"
    exit 1
fi

bash "$SYNC_SCRIPT" "$REPO_ROOT"

if [ "$SKIP_COMMIT" = false ]; then
    echo "Committing..."
    git add "$SUBMODULE_PATH" .gitmodules \
        .github/agents .github/instructions docs/templates \
        docs/epics/INDEX.md docs/tickets/INDEX.md 2>/dev/null || true

    if git diff --cached --quiet; then
        echo ""
        echo "Nothing new to commit - already up to date."
    else
        git commit -m "chore: bootstrap copilot-dev-agents"
        echo ""
        echo "Done. Open Copilot Chat in VS Code and pick an agent from the dropdown."
    fi
else
    echo ""
    echo "Done (commit skipped). Stage and commit when ready."
fi

echo ""
