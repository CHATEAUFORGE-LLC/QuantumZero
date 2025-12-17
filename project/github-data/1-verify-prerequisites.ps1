# Prerequisites Verification Script
# Comprehensive pre-flight checks for QuantumZero project setup

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "QuantumZero Setup - Prerequisites Check" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verifying all prerequisites before setup..." -ForegroundColor Yellow
Write-Host ""

$allChecks = $true

# Check 1: Current directory
Write-Host "[1/8] Checking current directory..." -ForegroundColor Yellow
if (Test-Path "project/github-data") {
    Write-Host "  ✓ In correct directory" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Must run from QuantumZero repository root" -ForegroundColor Red
    Write-Host "    Current: $(Get-Location)" -ForegroundColor Gray
    Write-Host "    Expected: C:\Users\jrace\gitlab\CSC686\projects\QuantumZero" -ForegroundColor Gray
    $allChecks = $false
}
Write-Host ""

# Check 2: GitHub CLI installed
Write-Host "[2/8] Checking GitHub CLI installation..." -ForegroundColor Yellow
try {
    $ghVersion = gh --version | Select-Object -First 1
    Write-Host "  ✓ GitHub CLI installed: $ghVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ GitHub CLI not found" -ForegroundColor Red
    Write-Host "    Install from: https://cli.github.com/" -ForegroundColor Gray
    $allChecks = $false
}
Write-Host ""

# Check 3: GitHub CLI authenticated
Write-Host "[3/8] Checking GitHub CLI authentication..." -ForegroundColor Yellow
try {
    $authStatus = gh auth status 2>&1
    if ($authStatus -match "Logged in") {
        Write-Host "  ✓ Authenticated to GitHub" -ForegroundColor Green
        $authStatus | Select-String "Logged in" | Write-Host -ForegroundColor Gray
    }
    else {
        Write-Host "  ✗ Not authenticated" -ForegroundColor Red
        Write-Host "    Run: gh auth login" -ForegroundColor Gray
        $allChecks = $false
    }
}
catch {
    Write-Host "  ✗ Authentication check failed" -ForegroundColor Red
    Write-Host "    Run: gh auth login" -ForegroundColor Gray
    $allChecks = $false
}
Write-Host ""

# Check 4: Repository access
Write-Host "[4/8] Checking repository access..." -ForegroundColor Yellow
$repos = @(
    "CHATEAUFORGE-LLC/QuantumZero",
    "CHATEAUFORGE-LLC/QuantumZero-mobile",
    "CHATEAUFORGE-LLC/QuantumZero-server",
    "CHATEAUFORGE-LLC/QuantumZero-sdk"
)

foreach ($repo in $repos) {
    try {
        $repoInfo = gh repo view $repo --json name,isPrivate 2>$null | ConvertFrom-Json
        Write-Host "  ✓ Access to $repo" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Cannot access $repo" -ForegroundColor Red
        Write-Host "    Check repository exists and you have access" -ForegroundColor Gray
        $allChecks = $false
    }
}
Write-Host ""

# Check 5: JSON files exist
Write-Host "[5/8] Checking JSON data files..." -ForegroundColor Yellow
$jsonFiles = @(
    "project/github-data/labels.json",
    "project/github-data/functional-requirements.json",
    "project/github-data/nonfunctional-requirements.json",
    "project/github-data/epics-and-tasks.json",
    "project/github-data/issue-templates.json"
)

foreach ($file in $jsonFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ Found $(Split-Path -Leaf $file)" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Missing $file" -ForegroundColor Red
        $allChecks = $false
    }
}
Write-Host ""

# Check 6: JSON files are valid
Write-Host "[6/8] Validating JSON syntax..." -ForegroundColor Yellow
foreach ($file in $jsonFiles) {
    if (Test-Path $file) {
        try {
            Get-Content $file | ConvertFrom-Json | Out-Null
            Write-Host "  ✓ Valid $(Split-Path -Leaf $file)" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ Invalid JSON in $(Split-Path -Leaf $file)" -ForegroundColor Red
            Write-Host "    $($_.Exception.Message)" -ForegroundColor Gray
            $allChecks = $false
        }
    }
}
Write-Host ""

# Check 7: Script files exist
Write-Host "[7/8] Checking PowerShell scripts..." -ForegroundColor Yellow
$scriptFiles = @(
    "project/github-data/step1-create-labels.ps1",
    "project/github-data/step2-create-milestones.ps1",
    "project/github-data/step3-create-requirements.ps1",
    "project/github-data/step4-create-epics.ps1",
    "project/github-data/run-all-setup.ps1"
)

foreach ($file in $scriptFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ Found $(Split-Path -Leaf $file)" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Missing $file" -ForegroundColor Red
        $allChecks = $false
    }
}
Write-Host ""

# Check 8: Existing milestones
Write-Host "[8/8] Checking existing milestones..." -ForegroundColor Yellow
try {
    $existingIssues = gh issue list --repo "CHATEAUFORGE-LLC/QuantumZero" --json number,title --limit 10 2>$null | ConvertFrom-Json
    $milestoneIssues = $existingIssues | Where-Object { $_.title -match "^Milestone M\d" }
    
    if ($milestoneIssues.Count -gt 0) {
        Write-Host "  ⚠ Found $($milestoneIssues.Count) existing milestone issues" -ForegroundColor Yellow
        $milestoneIssues | ForEach-Object { Write-Host "    #$($_.number): $($_.title)" -ForegroundColor Gray }
        Write-Host "    These will remain separate from the new milestone structure" -ForegroundColor Gray
    }
    else {
        Write-Host "  ✓ No existing milestone issues found" -ForegroundColor Green
    }
}
catch {
    Write-Host "  ⚠ Could not check existing issues" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Pre-Flight Check Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if ($allChecks) {
    Write-Host "✓ All checks passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ready to proceed with setup." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Review SETUP-SUMMARY.md for details" -ForegroundColor White
    Write-Host "  2. Run: .\project\github-data\run-all-setup.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Estimated time: 25-30 minutes" -ForegroundColor Gray
    Write-Host "Issues to be created: ~120" -ForegroundColor Gray
}
else {
    Write-Host "✗ Some checks failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please resolve the issues above before proceeding." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
