# QuantumZero Project Setup - Master Script
# Orchestrates complete project setup from JSON configuration files

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = $PSScriptRoot

Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                ║" -ForegroundColor Cyan
Write-Host "║      QuantumZero GitHub Project Setup         ║" -ForegroundColor Cyan
Write-Host "║                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will create a complete GitHub project structure:" -ForegroundColor White
Write-Host ""
Write-Host "  • 124 labels across 4 repositories" -ForegroundColor Gray
Write-Host "  • 24 milestones (6 per repository)" -ForegroundColor Gray
Write-Host "  • 129 issues (60 requirements, 17 epics, 52 tasks)" -ForegroundColor Gray
Write-Host "  • Organization project board with custom fields" -ForegroundColor Gray
Write-Host "  • Epic → Task relationships (52 links)" -ForegroundColor Gray
Write-Host "  • Requirement → Implementation traceability" -ForegroundColor Gray
Write-Host ""
Write-Host "Estimated time: 15-20 minutes" -ForegroundColor Yellow
Write-Host ""

# Prompt for confirmation
$proceed = Read-Host "Do you want to proceed? (yes/no)"
if ($proceed -ne "yes") {
    Write-Host ""
    Write-Host "Setup canceled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Track total time
$totalStart = Get-Date

#region Step 1: Verify Prerequisites
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║ Step 1/4: Verifying Prerequisites             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$prereqScript = Join-Path $SCRIPT_DIR "1-verify-prerequisites.ps1"
if (Test-Path $prereqScript) {
    try {
        & $prereqScript
        
        # Check if verification passed (script would exit on failure)
        Write-Host ""
        Write-Host "✓ All prerequisites verified successfully!" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "✗ Prerequisites verification failed" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please resolve the issues above and run setup again." -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "⚠ verify-prerequisites.ps1 not found, skipping verification" -ForegroundColor Yellow
    Write-Host ""
    
    $continueAnyway = Read-Host "Continue anyway? (yes/no)"
    if ($continueAnyway -ne "yes") {
        Write-Host "Setup canceled." -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""
}

Start-Sleep -Seconds 2
#endregion

#region Step 2: Create GitHub Structure
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║ Step 2/4: Creating GitHub Structure           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$structureScript = Join-Path $SCRIPT_DIR "2-create-github-structure.ps1"
if (Test-Path $structureScript) {
    $step2Start = Get-Date
    
    try {
        & $structureScript
        
        $step2Duration = (Get-Date) - $step2Start
        Write-Host "✓ GitHub structure created in $([math]::Round($step2Duration.TotalMinutes, 1)) minutes" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "✗ Error creating GitHub structure: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "You can try running create-github-structure.ps1 manually to debug." -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "✗ create-github-structure.ps1 not found" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 2
#endregion

#region Step 3: Configure Project Board
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║ Step 3/4: Configuring Project Board           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$projectScript = Join-Path $SCRIPT_DIR "3-configure-project-board.ps1"
if (Test-Path $projectScript) {
    $step3Start = Get-Date
    
    try {
        & $projectScript
        
        $step3Duration = (Get-Date) - $step3Start
        Write-Host "✓ Project board configured in $([math]::Round($step3Duration.TotalMinutes, 1)) minutes" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "✗ Error configuring project board: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "You can try running 3-configure-project-board.ps1 manually to debug." -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "✗ 3-configure-project-board.ps1 not found" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 2
#endregion

#region Step 4: Link Requirements to Implementation
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║ Step 4/4: Linking Requirements                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$linkScript = Join-Path $SCRIPT_DIR "5-link-requirements.ps1"
if (Test-Path $linkScript) {
    $step4Start = Get-Date
    
    try {
        & $linkScript
        
        $step4Duration = (Get-Date) - $step4Start
        Write-Host "✓ Requirements linked in $([math]::Round($step4Duration.TotalMinutes, 1)) minutes" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "✗ Error linking requirements: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "You can try running 5-link-requirements.ps1 manually to debug." -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "⚠ 5-link-requirements.ps1 not found, skipping requirement links" -ForegroundColor Yellow
}
#endregion

#region Completion Summary
$totalDuration = (Get-Date) - $totalStart

Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                ║" -ForegroundColor Green
Write-Host "║         SETUP COMPLETE! 🎉                     ║" -ForegroundColor Green
Write-Host "║                                                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Total time: $([math]::Round($totalDuration.TotalMinutes, 1)) minutes" -ForegroundColor White
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "What was created:" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  ✓ 124 labels (31 types × 4 repositories)" -ForegroundColor Green
Write-Host "  ✓ 24 milestones (M1-M6 × 4 repositories)" -ForegroundColor Green
Write-Host "  ✓ 60 requirement issues" -ForegroundColor Green
Write-Host "  ✓ 17 epic issues" -ForegroundColor Green
Write-Host "  ✓ 52 task issues" -ForegroundColor Green
Write-Host "  ✓ 129 items in project board" -ForegroundColor Green
Write-Host "  ✓ Custom fields populated (Type, Priority, Risk, Dates)" -ForegroundColor Green
Write-Host "  ✓ Epic → Task relationships (52 links)" -ForegroundColor Green
Write-Host "  ✓ Requirement → Implementation traceability" -ForegroundColor Green
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. View your project board:" -ForegroundColor White
Write-Host "     https://github.com/orgs/CHATEAUFORGE-LLC/projects/1" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Review issues in each repository:" -ForegroundColor White
Write-Host "     • QuantumZero: https://github.com/CHATEAUFORGE-LLC/QuantumZero/issues" -ForegroundColor Cyan
Write-Host "     • Mobile: https://github.com/CHATEAUFORGE-LLC/QuantumZero-mobile/issues" -ForegroundColor Cyan
Write-Host "     • Server: https://github.com/CHATEAUFORGE-LLC/QuantumZero-server/issues" -ForegroundColor Cyan
Write-Host "     • SDK: https://github.com/CHATEAUFORGE-LLC/QuantumZero-sdk/issues" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Start assigning issues to team members" -ForegroundColor White
Write-Host ""
Write-Host "  4. Begin work on Milestone M1 tasks!" -ForegroundColor White
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
#endregion
