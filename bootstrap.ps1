$AgentsRepo = "https://github.com/rhodes911/copilot-dev-agents"
$SkipCommit  = $false

$ErrorActionPreference = "Stop"

try {
    $repoRoot = git rev-parse --show-toplevel 2>&1
    if ($LASTEXITCODE -ne 0) { throw "not a git repo" }
} catch {
    Write-Host "Error: not inside a git repository. Run 'git init' first."
    exit 1
}

$repoRoot = $repoRoot.Trim()
Set-Location $repoRoot

Write-Host ""
Write-Host "Copilot Dev Agents - Bootstrap"
Write-Host "  Repo root  : $repoRoot"
Write-Host "  Agents src : $AgentsRepo"
Write-Host ""

$submodulePath = ".copilot-dev-agents"
$submoduleGit  = Join-Path (Join-Path $repoRoot $submodulePath) ".git"

if (Test-Path $submoduleGit) {
    Write-Host "Submodule already present - pulling latest..."
    git submodule update --remote $submodulePath
} else {
    Write-Host "Adding submodule..."
    git submodule add $AgentsRepo $submodulePath
    git submodule update --init $submodulePath
}

Write-Host ""
$syncScript = Join-Path (Join-Path $repoRoot $submodulePath) "sync-agents.ps1"

if (-not (Test-Path $syncScript)) {
    Write-Host "Error: sync script not found at $syncScript"
    exit 1
}

& $syncScript -TargetRepo $repoRoot

if (-not $SkipCommit) {
    Write-Host "Committing..."

    $toStage = @(
        $submodulePath,
        ".gitmodules",
        ".github/agents",
        ".github/instructions",
        "docs/templates",
        "docs/epics/INDEX.md",
        "docs/tickets/INDEX.md"
    )

    foreach ($item in $toStage) {
        git add $item 2>&1 | Out-Null
    }

    $staged = (git diff --cached --name-only 2>&1) -join ""
    if ($staged) {
        git commit -m "chore: bootstrap copilot-dev-agents"
        Write-Host ""
        Write-Host "Done. Open Copilot Chat in VS Code and pick an agent from the dropdown." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Nothing new to commit - already up to date." -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "Done (commit skipped). Stage and commit when ready." -ForegroundColor Yellow
}

Write-Host ""
