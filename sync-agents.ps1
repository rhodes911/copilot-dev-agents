<#
.SYNOPSIS
    Syncs the Copilot Dev Agents system into a consuming repository.

.DESCRIPTION
    Run from inside the consuming repository.
    The submodule should be at .copilot-dev-agents/ relative to the repo root.

    What this script does:
      - Copies .github/agents/*.agent.md                  to target .github/agents/
      - Copies .github/instructions/*.instructions.md     to target .github/instructions/
      - Copies docs/templates/*.md                        to target docs/templates/
      - Creates docs/epics/INDEX.md if absent
      - Creates docs/tickets/INDEX.md if absent

.PARAMETER TargetRepo
    Absolute path to the consuming repository root.
    Defaults to the parent directory of the submodule folder.

.EXAMPLE
    .\.copilot-dev-agents\sync-agents.ps1

.EXAMPLE
    .\.copilot-dev-agents\sync-agents.ps1 -TargetRepo C:\Repos\my-project
#>

param(
    [string]$TargetRepo = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$src = $PSScriptRoot
$tgt = $TargetRepo

Write-Host ""
Write-Host "Copilot Dev Agents - Sync"
Write-Host "  Source : $src"
Write-Host "  Target : $tgt"
Write-Host ""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function EnsureDir {
    param([string]$Dir)
    if (-not (Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }
}

function CopyGlob {
    param([string]$SrcDir, [string]$Pattern, [string]$TgtDir)
    EnsureDir $TgtDir
    $items = Get-ChildItem -Path $SrcDir -Filter $Pattern -File -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        $dest = Join-Path $TgtDir $item.Name
        Copy-Item -LiteralPath $item.FullName -Destination $dest -Force
        Write-Host "  copied : $($item.Name)"
    }
}

function EnsureFile {
    param([string]$TgtPath, [string]$SrcPath)
    if (-not (Test-Path $TgtPath)) {
        EnsureDir (Split-Path $TgtPath -Parent)
        Copy-Item -LiteralPath $SrcPath -Destination $TgtPath -Force
        Write-Host "  created: $TgtPath"
    } else {
        Write-Host "  exists : $TgtPath (skipped)"
    }
}

# ---------------------------------------------------------------------------
# 1. Agent definition files
# ---------------------------------------------------------------------------

Write-Host "1. Syncing agent definitions..."
CopyGlob (Join-Path $src ".github\agents") "*.agent.md" (Join-Path $tgt ".github\agents")

# ---------------------------------------------------------------------------
# 2. Instruction files (includes agent-system.instructions.md with applyTo:"**")
# ---------------------------------------------------------------------------

Write-Host "2. Syncing instruction files..."
CopyGlob (Join-Path $src ".github\instructions") "*.instructions.md" (Join-Path $tgt ".github\instructions")

# ---------------------------------------------------------------------------
# 3. Doc templates (always latest - canonical versions)
# ---------------------------------------------------------------------------

Write-Host "3. Syncing doc templates..."
CopyGlob (Join-Path $src "docs\templates") "*.md" (Join-Path $tgt "docs\templates")

# ---------------------------------------------------------------------------
# 4. Index files - create only if absent (user owns content)
# ---------------------------------------------------------------------------

Write-Host "4. Ensuring index files..."
EnsureFile (Join-Path $tgt "docs\epics\INDEX.md")   (Join-Path $src "docs\epics\INDEX.md")
EnsureFile (Join-Path $tgt "docs\tickets\INDEX.md") (Join-Path $src "docs\tickets\INDEX.md")

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "Sync complete."
Write-Host "Stage and commit the changes to record the update:"
Write-Host "  git add .github/agents .github/instructions docs/templates"
Write-Host "  git commit -m 'chore: sync copilot-dev-agents'"
Write-Host ""
