<#
.SYNOPSIS
    Syncs the Copilot Dev Agents system into a consuming repository.

.DESCRIPTION
    Run from inside the consuming repository (or pass -TargetRepo).
    Copies agent definitions, instruction files, and doc templates into place.
    Injects/updates the agent-system rules block in copilot-instructions.md
    using <!-- AGENT-SYSTEM:START --> / <!-- AGENT-SYSTEM:END --> markers.

.PARAMETER TargetRepo
    Absolute path to the consuming repository root.
    Defaults to the parent of the directory this script lives in
    (i.e. if the submodule is at .copilot-dev-agents/, the parent is the repo root).

.EXAMPLE
    # Run from inside the consuming repo after updating the submodule
    .\.copilot-dev-agents\sync-agents.ps1

.EXAMPLE
    # Explicit target path
    .\.copilot-dev-agents\sync-agents.ps1 -TargetRepo C:\Repos\my-project
#>

param(
    [string]$TargetRepo = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$Source = $PSScriptRoot
$Target = $TargetRepo

Write-Host ""
Write-Host "Copilot Dev Agents — Sync" -ForegroundColor Cyan
Write-Host "  Source : $Source"
Write-Host "  Target : $Target"
Write-Host ""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Ensure-Dir([string]$path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Copy-Glob([string]$sourceDir, [string]$pattern, [string]$targetDir) {
    Ensure-Dir $targetDir
    $files = Get-ChildItem -Path $sourceDir -Filter $pattern -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Copy-Item -Path $file.FullName -Destination (Join-Path $targetDir $file.Name) -Force
        Write-Host "  copied  $($file.Name)  →  $targetDir" -ForegroundColor Green
    }
}

function Ensure-File([string]$targetPath, [string]$sourcePath) {
    if (-not (Test-Path $targetPath)) {
        Copy-Item -Path $sourcePath -Destination $targetPath -Force
        Write-Host "  created $targetPath" -ForegroundColor Yellow
    } else {
        Write-Host "  exists  $targetPath  (skipped)" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------------------
# 1. Agent definition files  →  .github/agents/
# ---------------------------------------------------------------------------

Write-Host "1. Syncing agent definitions..." -ForegroundColor White
Copy-Glob `
    (Join-Path $Source ".github\agents") `
    "*.agent.md" `
    (Join-Path $Target ".github\agents")

# ---------------------------------------------------------------------------
# 2. Scoped instruction files  →  .github/instructions/
# ---------------------------------------------------------------------------

Write-Host "2. Syncing instruction files..." -ForegroundColor White
Copy-Glob `
    (Join-Path $Source ".github\instructions") `
    "*.instructions.md" `
    (Join-Path $Target ".github\instructions")

# ---------------------------------------------------------------------------
# 3. Doc templates  →  docs/templates/  (always overwrite — canonical versions)
# ---------------------------------------------------------------------------

Write-Host "3. Syncing doc templates..." -ForegroundColor White
Copy-Glob `
    (Join-Path $Source "docs\templates") `
    "*.md" `
    (Join-Path $Target "docs\templates")

# ---------------------------------------------------------------------------
# 4. Index files  →  create only if absent (user owns content)
# ---------------------------------------------------------------------------

Write-Host "4. Ensuring index files exist..." -ForegroundColor White
Ensure-File `
    (Join-Path $Target "docs\epics\INDEX.md") `
    (Join-Path $Source "docs\epics\INDEX.md")
Ensure-File `
    (Join-Path $Target "docs\tickets\INDEX.md") `
    (Join-Path $Source "docs\tickets\INDEX.md")

# ---------------------------------------------------------------------------
# 5. Inject / update agent-system block in copilot-instructions.md
# ---------------------------------------------------------------------------

Write-Host "5. Updating copilot-instructions.md..." -ForegroundColor White

$instructionsTarget = Join-Path $Target ".github\copilot-instructions.md"
$instructionsSource = Join-Path $Source ".github\copilot-instructions.md"

$startMarker = "<!-- AGENT-SYSTEM:START -->"
$endMarker   = "<!-- AGENT-SYSTEM:END -->"

$sourceContent = Get-Content $instructionsSource -Raw

$injectedBlock = @"

$startMarker
<!-- This block is managed by copilot-dev-agents. Re-run sync-agents.ps1 to update. -->

$sourceContent
$endMarker
"@

if (Test-Path $instructionsTarget) {
    $existing = Get-Content $instructionsTarget -Raw

    if ($existing -match [regex]::Escape($startMarker)) {
        # Replace the existing block between markers
        $pattern = "(?s)" + [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)
        $updated = [regex]::Replace($existing, $pattern, $injectedBlock.Trim())
        Set-Content -Path $instructionsTarget -Value $updated -NoNewline
        Write-Host "  updated agent-system block in $instructionsTarget" -ForegroundColor Green
    } else {
        # Append the block
        Add-Content -Path $instructionsTarget -Value $injectedBlock
        Write-Host "  appended agent-system block to $instructionsTarget" -ForegroundColor Green
    }
} else {
    # No file yet — create it with just the block
    Ensure-Dir (Split-Path $instructionsTarget -Parent)
    Set-Content -Path $instructionsTarget -Value $injectedBlock.Trim()
    Write-Host "  created $instructionsTarget" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "Sync complete." -ForegroundColor Cyan
Write-Host "Commit the changes to record the update in your repository."
Write-Host ""
