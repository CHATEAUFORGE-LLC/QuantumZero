# Create GitHub Structure
# Consolidated script for creating labels, milestones, requirements, epics, and tasks

$ErrorActionPreference = "Continue"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Create GitHub Structure" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$ORG = "CHATEAUFORGE-LLC"
$REPOS = @(
    "QuantumZero",
    "QuantumZero-mobile",
    "QuantumZero-server",
    "QuantumZero-sdk"
)

$DATA_DIR = ".\project\github-data"

# Statistics tracking
$stats = @{
    LabelsCreated = 0
    MilestonesCreated = 0
    RequirementsCreated = 0
    EpicsCreated = 0
    TasksCreated = 0
    Errors = 0
}

#region Step 1: Create Labels
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 1: Creating Labels" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$labelsFile = "$DATA_DIR\labels.json"
if (-not (Test-Path $labelsFile)) {
    Write-Host "✗ Error: Cannot find $labelsFile" -ForegroundColor Red
    exit 1
}

$labelsData = Get-Content $labelsFile -Raw | ConvertFrom-Json

foreach ($repo in $REPOS) {
    $fullRepo = "$ORG/$repo"
    Write-Host "Processing: $fullRepo" -ForegroundColor Cyan
    
    foreach ($label in $labelsData.labels) {
        try {
            gh label create $label.name `
                --repo $fullRepo `
                --color $label.color `
                --description $label.description `
                --force 2>$null
            
            $stats.LabelsCreated++
            Write-Host "  ✓ $($label.name)" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ $($label.name): $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
        }
        Start-Sleep -Milliseconds 100
    }
    Write-Host ""
}
#endregion

#region Step 2: Create Milestones
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 2: Creating Milestones" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$epicsFile = "$DATA_DIR\epics-and-tasks.json"
if (-not (Test-Path $epicsFile)) {
    Write-Host "✗ Error: Cannot find $epicsFile" -ForegroundColor Red
    exit 1
}

$epicsData = Get-Content $epicsFile -Raw | ConvertFrom-Json

foreach ($repo in $REPOS) {
    $fullRepo = "$ORG/$repo"
    Write-Host "Processing: $fullRepo" -ForegroundColor Cyan
    
    foreach ($milestone in $epicsData.milestones) {
        try {
            # Check if milestone exists
            $existing = gh api "repos/$fullRepo/milestones" --jq ".[] | select(.title == `"$($milestone.title)`")" 2>$null
            
            if ($existing) {
                Write-Host "  ⊙ $($milestone.title) (exists)" -ForegroundColor Gray
                continue
            }
            
            # Create milestone
            $body = @{
                title = $milestone.title
                due_on = $milestone.dueDate + "T23:59:59Z"
                description = $milestone.description
            } | ConvertTo-Json
            
            $body | gh api "repos/$fullRepo/milestones" --method POST --input - | Out-Null
            
            $stats.MilestonesCreated++
            Write-Host "  ✓ $($milestone.title)" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ $($milestone.title): $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
        }
        Start-Sleep -Milliseconds 200
    }
    Write-Host ""
}
#endregion

#region Step 3: Create Requirement Issues
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 3: Creating Requirement Issues" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Process functional requirements
$funcReqsFile = "$DATA_DIR\functional-requirements.json"
if (Test-Path $funcReqsFile) {
    $funcReqs = Get-Content $funcReqsFile -Raw | ConvertFrom-Json
    
    foreach ($req in $funcReqs.requirements) {
        $repo = "$ORG/$($req.repository)"
        
        # Check if requirement issue already exists
        $existing = gh issue list --repo $repo --search "in:title `"$($req.title)`"" --limit 1 --json number 2>$null | ConvertFrom-Json
        if ($existing) {
            Write-Host "  ⊙ [$($req.id)] $($req.title) (exists)" -ForegroundColor Gray
            continue
        }
        
        # Build issue body
        $body = @"
## Requirement Details

**ID:** $($req.id)
**Category:** $($req.category)
**Type:** Functional

## Description

$($req.description)

## Acceptance Criteria

$(($req.acceptanceCriteria | ForEach-Object { "- $_" }) -join "`n")

## Milestone

$($req.milestone)

## Component

$($req.repository)
"@
        
        # Create issue
        try {
            $labels = ($req.labels -join ",")
            gh issue create --repo $repo --title "[$($req.id)] $($req.title)" --body $body --label $labels | Out-Null
            
            $stats.RequirementsCreated++
            Write-Host "  ✓ [$($req.id)] $($req.title)" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ [$($req.id)] $($req.title): $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
        }
        Start-Sleep -Milliseconds 500
    }
}

# Process non-functional requirements
$nfReqsFile = "$DATA_DIR\nonfunctional-requirements.json"
if (Test-Path $nfReqsFile) {
    $nfReqs = Get-Content $nfReqsFile -Raw | ConvertFrom-Json
    
    foreach ($req in $nfReqs.requirements) {
        $repo = "$ORG/$($req.repository)"
        
        # Check if requirement issue already exists
        $existing = gh issue list --repo $repo --search "in:title `"$($req.title)`"" --limit 1 --json number 2>$null | ConvertFrom-Json
        if ($existing) {
            Write-Host "  ⊙ [$($req.id)] $($req.title) (exists)" -ForegroundColor Gray
            continue
        }
        
        # Build issue body
        $body = @"
## Requirement Details

**ID:** $($req.id)
**Category:** $($req.category)
**Type:** Non-Functional

## Description

$($req.description)

## Acceptance Criteria

$(($req.acceptanceCriteria | ForEach-Object { "- $_" }) -join "`n")

## Milestone

$($req.milestone)

## Component

$($req.repository)
"@
        
        # Create issue
        try {
            $labels = ($req.labels -join ",")
            gh issue create --repo $repo --title "[$($req.id)] $($req.title)" --body $body --label $labels | Out-Null
            
            $stats.RequirementsCreated++
            Write-Host "  ✓ [$($req.id)] $($req.title)" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ [$($req.id)] $($req.title): $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
        }
        Start-Sleep -Milliseconds 500
    }
}
Write-Host ""
#endregion

#region Step 4: Create Epic and Task Issues
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 4: Creating Epic and Task Issues" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($epic in $epicsData.epics) {
    $repo = "$ORG/$($epic.repository)"
    $epicTitle = $epic.title
    
    # Check if epic already exists
    $existingEpic = gh issue list --repo $repo --search "in:title `"$epicTitle`"" --limit 1 --json number,title 2>$null | ConvertFrom-Json
    
    if ($existingEpic) {
        $epicNumber = $existingEpic.number
        Write-Host "  ⊙ $epicTitle #$epicNumber (exists)" -ForegroundColor Gray
    }
    else {
        # Create epic issue
        $epicBody = @"
## Epic Overview

$($epic.description)

## Milestone

$($epic.milestone)

## Tasks

"@
        
        try {
            $labels = ($epic.labels -join ",")
            $epicNumber = gh issue create --repo $repo --title $epicTitle --body $epicBody --label $labels --json number | ConvertFrom-Json | Select-Object -ExpandProperty number
            
            $stats.EpicsCreated++
            Write-Host "  ✓ $epicTitle #$epicNumber" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ $epicTitle: $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
            continue
        }
        Start-Sleep -Milliseconds 500
    }
    
    # Create tasks for this epic
    $taskList = @()
    foreach ($task in $epic.tasks) {
        $taskTitle = $task.title
        
        # Check if task already exists
        $existingTask = gh issue list --repo $repo --search "in:title `"$taskTitle`"" --limit 1 --json number 2>$null | ConvertFrom-Json
        
        if ($existingTask) {
            $taskNumber = $existingTask.number
            Write-Host "    ⊙ $taskTitle #$taskNumber (exists)" -ForegroundColor Gray
            $taskList += "- [ ] #$taskNumber - $taskTitle"
            continue
        }
        
        # Build task body
        $taskBody = @"
## Task Description

$($task.description)

## Acceptance Criteria

$(($task.acceptanceCriteria | ForEach-Object { "- $_" }) -join "`n")

## Parent Epic

Part of: #$epicNumber

## Related Requirements

$(if ($task.relatedRequirements) { ($task.relatedRequirements | ForEach-Object { "- $_" }) -join "`n" } else { "None specified" })
"@
        
        # Create task issue
        try {
            $labels = ($task.labels -join ",")
            $taskNumber = gh issue create --repo $repo --title $taskTitle --body $taskBody --label $labels --json number | ConvertFrom-Json | Select-Object -ExpandProperty number
            
            $stats.TasksCreated++
            Write-Host "    ✓ $taskTitle #$taskNumber" -ForegroundColor Green
            $taskList += "- [ ] #$taskNumber - $taskTitle"
        }
        catch {
            Write-Host "    ✗ $taskTitle: $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
        }
        Start-Sleep -Milliseconds 500
    }
    
    # Update epic with task list
    if ($taskList.Count -gt 0) {
        try {
            $epicData = gh issue view $epicNumber --repo $repo --json body,number | ConvertFrom-Json
            $updatedBody = $epicData.body + "`n`n" + ($taskList -join "`n")
            
            # Write to temp file
            $tempFile = [System.IO.Path]::GetTempFileName()
            $updatedBody | Out-File -FilePath $tempFile -Encoding UTF8
            
            # Update epic
            gh issue edit $epicNumber --repo $repo --body-file $tempFile | Out-Null
            Remove-Item $tempFile
            
            Write-Host "    ✓ Updated epic with $($taskList.Count) task links" -ForegroundColor Green
        }
        catch {
            Write-Host "    ✗ Failed to update epic task list: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}
#endregion

# Summary
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Labels Created:       $($stats.LabelsCreated)" -ForegroundColor Green
Write-Host "Milestones Created:   $($stats.MilestonesCreated)" -ForegroundColor Green
Write-Host "Requirements Created: $($stats.RequirementsCreated)" -ForegroundColor Green
Write-Host "Epics Created:        $($stats.EpicsCreated)" -ForegroundColor Green
Write-Host "Tasks Created:        $($stats.TasksCreated)" -ForegroundColor Green
Write-Host "Errors:               $($stats.Errors)" -ForegroundColor $(if ($stats.Errors -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "✓ GitHub structure creation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Run configure-project-board.ps1 to set up project board" -ForegroundColor Yellow
Write-Host ""
