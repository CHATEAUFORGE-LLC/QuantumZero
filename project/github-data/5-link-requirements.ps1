# Link Requirements to Implementation
# Adds implementation references to requirements for complete traceability

$ErrorActionPreference = "Continue"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Link Requirements to Implementation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script adds task references to requirement issues" -ForegroundColor Yellow
Write-Host "for complete traceability and visibility." -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: Uses issue body references instead of sub-issue API" -ForegroundColor Gray
Write-Host "since tasks already have epics as parents." -ForegroundColor Gray
Write-Host ""

# Configuration
$ORG = "CHATEAUFORGE-LLC"
$REPOS = @(
    "QuantumZero",
    "QuantumZero-mobile",
    "QuantumZero-server",
    "QuantumZero-sdk"
)

$stats = @{
    LinksCreated = 0
    RequirementLinksAdded = 0
    AlreadyLinked = 0
    RequirementsNotFound = 0
    IssuesNotFound = 0
    Errors = 0
}

# Load epic/task data to get related requirements
$epicsFile = ".\epics-and-tasks.json"
if (-not (Test-Path $epicsFile)) {
    $epicsFile = ".\project\github-data\epics-and-tasks.json"
}

if (-not (Test-Path $epicsFile)) {
    Write-Host "✗ Error: Cannot find epics-and-tasks.json" -ForegroundColor Red
    exit 1
}

Write-Host "Loading epic and task data..." -ForegroundColor Yellow
$epicsData = Get-Content $epicsFile -Raw | ConvertFrom-Json
Write-Host "✓ Loaded $($epicsData.epics.Count) epics with tasks" -ForegroundColor Green
Write-Host ""

# Build cache of issue IDs by requirement ID and title
Write-Host "Building issue cache..." -ForegroundColor Yellow
$issueCache = @{}
$requirementCache = @{}

foreach ($repo in $REPOS) {
    $fullRepo = "$ORG/$repo"
    Write-Host "  Caching issues from $repo..." -ForegroundColor Gray
    
    try {
        $issues = gh issue list --repo $fullRepo --limit 1000 --state all --json number,title | ConvertFrom-Json
        
        foreach ($issue in $issues) {
            # Cache by title
            $issueCache[$issue.title] = @{
                Number = $issue.number
                Repository = $fullRepo
            }
            
            # Cache requirements by ID (extract from title like [F-OP-01])
            if ($issue.title -match '^\[([A-Z]+-[A-Z]+-\d+)\]') {
                $reqId = $matches[1]
                $requirementCache[$reqId] = @{
                    Number = $issue.number
                    Repository = $fullRepo
                    Title = $issue.title
                }
            }
        }
    }
    catch {
        Write-Host "  ⚠ Warning: Could not cache issues from $repo" -ForegroundColor Yellow
    }
}

Write-Host "✓ Cached $($issueCache.Count) issues and $($requirementCache.Count) requirements" -ForegroundColor Green
Write-Host ""

# Process each epic
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Linking Epics and Tasks to Requirements" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($epic in $epicsData.epics) {
    $repo = "$ORG/$($epic.repository)"
    $epicTitle = $epic.title
    
    Write-Host "Processing: $epicTitle" -ForegroundColor White
    
    # Find epic issue
    if (-not $issueCache.ContainsKey($epicTitle)) {
        Write-Host "  ⚠ Epic issue not found" -ForegroundColor Yellow
        $stats.IssuesNotFound++
        Write-Host ""
        continue
    }
    
    $epicInfo = $issueCache[$epicTitle]
    $epicNumber = $epicInfo.Number
    $epicRepo = $epicInfo.Repository
    
    # Get epic node ID
    try {
        $epicNodeId = gh api "repos/$epicRepo/issues/$epicNumber" --jq '.node_id'
    }
    catch {
        Write-Host "  ✗ Could not get epic node ID" -ForegroundColor Red
        $stats.Errors++
        Write-Host ""
        continue
    }
    
    # Process each task in the epic
    foreach ($task in $epic.tasks) {
        $taskTitle = $task.title
        
        # Skip if no related requirements
        if (-not $task.related_requirements -or $task.related_requirements.Count -eq 0) {
            Write-Host "  ⊙ Task: $taskTitle (no requirements)" -ForegroundColor Gray
            continue
        }
        
        # Find task issue
        if (-not $issueCache.ContainsKey($taskTitle)) {
            Write-Host "  ⚠ Task not found: $taskTitle" -ForegroundColor Yellow
            $stats.IssuesNotFound++
            continue
        }
        
        $taskInfo = $issueCache[$taskTitle]
        $taskNumber = $taskInfo.Number
        $taskRepo = $taskInfo.Repository
        
        # Get task node ID
        try {
            $taskNodeId = gh api "repos/$taskRepo/issues/$taskNumber" --jq '.node_id'
        }
        catch {
            Write-Host "  ✗ Could not get task node ID: $taskTitle" -ForegroundColor Red
            $stats.Errors++
            continue
        }
        
        Write-Host "  Task: $taskTitle #$taskNumber" -ForegroundColor Cyan
        
        # Link task to each related requirement
        foreach ($reqId in $task.related_requirements) {
            if (-not $requirementCache.ContainsKey($reqId)) {
                Write-Host "    ⚠ Requirement not found: $reqId" -ForegroundColor Yellow
                $stats.RequirementsNotFound++
                continue
            }
            
            $reqInfo = $requirementCache[$reqId]
            $reqNumber = $reqInfo.Number
            $reqRepo = $reqInfo.Repository
            $reqTitle = $reqInfo.Title
            
            # Get requirement node ID
            try {
                $reqNodeId = gh api "repos/$reqRepo/issues/$reqNumber" --jq '.node_id'
            }
            catch {
                Write-Host "    ✗ Could not get requirement node ID: $reqId" -ForegroundColor Red
                $stats.Errors++
                continue
            }
            
            # Add task reference to requirement issue body
            # (Can't use sub-issue API since tasks already have epic as parent)
            try {
                # Get current requirement body
                $reqBody = gh api "repos/$reqRepo/issues/$reqNumber" --jq '.body'
                
                # Check if implementation section exists
                if ($reqBody -notmatch "## Implementation") {
                    # Add implementation section with task reference
                    $updatedBody = $reqBody + "`n`n## Implementation`n`n- #$taskNumber - $taskTitle"
                }
                elseif ($reqBody -notmatch "#$taskNumber") {
                    # Add task reference to existing implementation section
                    $updatedBody = $reqBody -replace "(## Implementation)", "`$1`n- #$taskNumber - $taskTitle"
                }
                else {
                    # Task already referenced
                    Write-Host "    ⊙ Already referenced in $reqId" -ForegroundColor Gray
                    $stats.AlreadyLinked++
                    continue
                }
                
                # Update requirement issue body
                $tempFile = [System.IO.Path]::GetTempFileName()
                $updatedBody | Out-File -FilePath $tempFile -Encoding UTF8
                gh issue edit $reqNumber --repo $reqRepo --body-file $tempFile | Out-Null
                Remove-Item $tempFile
                
                Write-Host "    ✓ Referenced in requirement $reqId #$reqNumber" -ForegroundColor Green
                $stats.LinksCreated++
            }
            catch {
                Write-Host "    ✗ Failed to reference in $reqId`: $($_.Exception.Message)" -ForegroundColor Red
                $stats.Errors++
            }
        }
        
        # Now update the task body to link back to all its requirements
        if ($task.related_requirements -and $task.related_requirements.Count -gt 0) {
            try {
                # Get current task body
                $taskBody = gh api "repos/$taskRepo/issues/$taskNumber" --jq '.body'
                $needsUpdate = $false
                $updatedTaskBody = $taskBody
                
                # Build list of requirement links
                $reqLinks = @()
                foreach ($reqId in $task.related_requirements) {
                    if ($requirementCache.ContainsKey($reqId)) {
                        $reqInfo = $requirementCache[$reqId]
                        $reqLinks += "- #$($reqInfo.Number) - ${reqId}: $($reqInfo.Title)"
                    }
                }
                
                if ($reqLinks.Count -gt 0) {
                    # Check if Related Requirements section exists
                    if ($updatedTaskBody -notmatch "## Related Requirements") {
                        # Add Related Requirements section
                        $reqSection = "`n`n## Related Requirements`n`n" + ($reqLinks -join "`n")
                        $updatedTaskBody = $updatedTaskBody + $reqSection
                        $needsUpdate = $true
                    }
                    else {
                        # Check if any links are missing
                        foreach ($reqLink in $reqLinks) {
                            if ($updatedTaskBody -notmatch [regex]::Escape($reqLink)) {
                                # Add missing requirement link
                                $updatedTaskBody = $updatedTaskBody -replace "(## Related Requirements)", "`$1`n$reqLink"
                                $needsUpdate = $true
                            }
                        }
                    }
                    
                    if ($needsUpdate) {
                        # Update task issue body
                        $tempFile = [System.IO.Path]::GetTempFileName()
                        $updatedTaskBody | Out-File -FilePath $tempFile -Encoding UTF8
                        gh issue edit $taskNumber --repo $taskRepo --body-file $tempFile | Out-Null
                        Remove-Item $tempFile
                        
                        Write-Host "    ✓ Added requirement links to task" -ForegroundColor Cyan
                        $stats.RequirementLinksAdded++
                    }
                }
            }
            catch {
                Write-Host "    ⚠ Failed to update task body: $($_.Exception.Message)" -ForegroundColor Yellow
            }
            
            Start-Sleep -Milliseconds 300
        }
    }
    
    Write-Host ""
}

# Summary
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Task → Requirement Links:    $($stats.LinksCreated)" -ForegroundColor Green
Write-Host "Requirement → Task Links:    $($stats.RequirementLinksAdded)" -ForegroundColor Cyan
Write-Host "Already Linked:              $($stats.AlreadyLinked)" -ForegroundColor Gray
Write-Host "Requirements Not Found:      $($stats.RequirementsNotFound)" -ForegroundColor Yellow
Write-Host "Issues Not Found:            $($stats.IssuesNotFound)" -ForegroundColor Yellow
Write-Host "Errors:                  $($stats.Errors)" -ForegroundColor $(if ($stats.Errors -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($stats.LinksCreated -gt 0 -or $stats.RequirementLinksAdded -gt 0) {
    Write-Host "✓ Bidirectional requirement traceability created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor White
    Write-Host "  • View requirements to see 'Implementation' section with tasks" -ForegroundColor Gray
    Write-Host "  • View tasks to see 'Related Requirements' section with requirements" -ForegroundColor Gray
    Write-Host "  • Click any reference to jump between requirements and tasks" -ForegroundColor Gray
    Write-Host "  • Track completion by checking linked tasks" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Structure:" -ForegroundColor White
    Write-Host "  Requirement (has Implementation section)" -ForegroundColor Gray
    Write-Host "      ⟷ Tasks (bidirectional links in descriptions)" -ForegroundColor Gray
    Write-Host "          → Epic (parent via sub-issue API)" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Host "⚠ No new references were created." -ForegroundColor Yellow
    Write-Host ""
    if ($stats.AlreadyLinked -gt 0) {
        Write-Host "All task references may already exist in requirements." -ForegroundColor Gray
    }
    else {
        Write-Host "Check that issues exist and related_requirements are defined in JSON." -ForegroundColor Gray
    }
    Write-Host ""
}
