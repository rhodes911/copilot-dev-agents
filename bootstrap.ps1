<#
.SYNOPSIS
    Bootstraps the Copilot Dev Agents system into a new or existing repository.

.DESCRIPTION
    Run this from the root of any repository (new or existing).
    It adds copilot-dev-agents as a git submodule, runs the sync, and
    makes the initial commit — so you are ready to use the agents immediately.

.PARAMETER AgentsRepo
    URL of the copilot-dev-agents GitHub repository.
    Defaults to the canonical upstream.

.PARAMETER SkipCommit
    If set, stages the files but does not commit (useful if you want to
    review or combine with other changes first).

.EXAMPLE
    # Quickest: pipe from GitHub raw
    irm https://raw.githubusercontent.com/rhodes911/copilot-dev-agents/master/bootstrap.ps1 | iex

.EXAMPLE
    # Explicit repo URL
    irm https://raw.githubusercontent.com/rhodes911/copilot-dev-agents/master/bootstrap.ps1 `
      -OutFile bootstrap.ps1; .\bootstrap.ps1 -AgentsRepo https://github.com/rhodes911/copilot-dev-agents
#>

param(
    [string]$AgentsRepo  = "https://github.com/rhodes911/copilot-dev-agents",
    [switch]$SkipCommit
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Verify we are inside a git repo
# ---------------------------------------------------------------------------

try {
    $repoRoot = git rev-parse --show-toplevel 2>&1
    if ($LASTEXITCODE -ne 0) { throw }
} catch {
    Write-Error "Not inside a git repository. Run 'git init' first."
    exit 1
}

$repoRoot = $repoRoot.Trim()
Set-Location $repoRoot

Write-Host ""
Write-Host "Copilot Dev Agents - Bootstrap"
Write-Host "  Repo root  : $repoRoot"
Write-Host "  Agents src : $AgentsRepo"
Write-Host ""

# ---------------------------------------------------------------------------
# Add submodule (skip if already present)
# ---------------------------------------------------------------------------

$submodulePath = ".copilot-dev-agents"

if (Test-Path (Join-Path $repoRoot $submodulePath ".git")) {
    Write-Host "Submodule already present. Pulling latest..."
    git submodule update --remote $submodulePath
} else {
    Write-Host "Adding submodule..."
    git submodule add $AgentsRepo $submodulePath
    git submodule update --init $submodulePath
}

# ---------------------------------------------------------------------------
# Run sync
# ---------------------------------------------------------------------------

Write-Host ""
$syncScript = Join-Path $repoRoot $submodulePath "sync-agents.ps1"

if (-not (Test-Path $syncScript)) {
    Write-Error "Sync script not found at $syncScript. Bootstrap cannot continue."
    exit 1
}

& $syncScript -TargetRepo $repoRoot

# ---------------------------------------------------------------------------
# Commit
# ---------------------------------------------------------------------------

if (-not $SkipCommit) {
    Write-Host "Committing..."
    git add $submodulePath
    git add .gitmodules
    git add .github/agents
    git add .github/instructions
    git add docs/templates
    git add docs/epics/INDEX.md 2>$null
    git add docs/tickets/INDEX.md 2>$null

    $staged = git diff --cached --name-only 2>&1
    if ($staged) {
        git commit -m "chore: bootstrap copilot-dev-agents"
        Write-Host ""
        Write-Host "Bootstrap complete. The development agents are ready." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Nothing new to commit — already up to date." -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "Bootstrap complete (commit skipped). Stage and commit when ready." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Open Copilot Chat in VS Code, pick an agent from the dropdown, and start."
Write-Host ""
