# Configure Project Board
# Consolidated script for adding issues to project board and configuring fields

$ErrorActionPreference = "Continue"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Configure Project Board" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$ORG = "CHATEAUFORGE-LLC"
$PROJECT_NUMBER = 1
$PROJECT_URL = "https://github.com/orgs/$ORG/projects/$PROJECT_NUMBER"

$REPOS = @(
    "$ORG/QuantumZero",
    "$ORG/QuantumZero-mobile",
    "$ORG/QuantumZero-server",
    "$ORG/QuantumZero-sdk"
)

# Milestone date mapping
$milestoneDates = @{
    "milestone:m1" = @{ Start = "2025-11-23"; End = "2025-12-27" }
    "milestone:m2" = @{ Start = "2025-12-16"; End = "2026-01-10" }
    "milestone:m3" = @{ Start = "2026-01-06"; End = "2026-01-20" }
    "milestone:m4" = @{ Start = "2026-01-21"; End = "2026-02-02" }
    "milestone:m5" = @{ Start = "2026-02-03"; End = "2026-02-15" }
    "milestone:m6" = @{ Start = "2026-02-16"; End = "2026-02-28" }
}

$stats = @{
    ItemsAdded = 0
    FieldsUpdated = 0
    RelationshipsCreated = 0
    Errors = 0
}

#region Step 1: Get Project Information
Write-Host "Step 1: Getting project information..." -ForegroundColor Yellow
Write-Host ""

try {
    $projectsData = gh project list --owner $ORG --format json | ConvertFrom-Json
    $project = $projectsData.projects | Where-Object { $_.title -eq "QuantumZero" -or $_.number -eq $PROJECT_NUMBER }
    
    if (-not $project) {
        Write-Host "✗ Error: Could not find project" -ForegroundColor Red
        exit 1
    }
    
    $projectId = $project.id
    Write-Host "✓ Found project: $($project.title)" -ForegroundColor Green
    Write-Host "  ID: $projectId" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "✗ Error accessing project: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
#endregion

#region Step 2: Add Issues to Project
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 2: Adding Issues to Project Board" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($repo in $REPOS) {
    Write-Host "Processing: $repo" -ForegroundColor Cyan
    
    try {
        $issues = gh issue list --repo $repo --limit 1000 --state all --json number,title | ConvertFrom-Json
        
        foreach ($issue in $issues) {
            try {
                gh project item-add $PROJECT_NUMBER --owner $ORG --url "https://github.com/$repo/issues/$($issue.number)" 2>$null | Out-Null
                $stats.ItemsAdded++
                Write-Host "  ✓ #$($issue.number) - $($issue.title)" -ForegroundColor Green
            }
            catch {
                if ($_.Exception.Message -match "already exists") {
                    Write-Host "  ⊙ #$($issue.number) - $($issue.title) (already in project)" -ForegroundColor Gray
                }
                else {
                    Write-Host "  ✗ #$($issue.number): $($_.Exception.Message)" -ForegroundColor Red
                    $stats.Errors++
                }
            }
            Start-Sleep -Milliseconds 250
        }
        Write-Host ""
    }
    catch {
        Write-Host "  ✗ Error processing repository: $($_.Exception.Message)" -ForegroundColor Red
        $stats.Errors++
    }
}
#endregion

#region Step 3: Configure Project Fields
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 3: Configuring Project Fields" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Get project fields using GraphQL
$query = @'
{
  organization(login: "CHATEAUFORGE-LLC") {
    projectV2(number: 1) {
      id
      title
      fields(first: 20) {
        nodes {
          ... on ProjectV2Field {
            id
            name
          }
          ... on ProjectV2SingleSelectField {
            id
            name
            options {
              id
              name
            }
          }
        }
      }
    }
  }
}
'@

$projectData = gh api graphql -f query=$query | ConvertFrom-Json
$project = $projectData.data.organization.projectV2
$projectGlobalId = $project.id
$fields = $project.fields.nodes

Write-Host "✓ Project: $($project.title)" -ForegroundColor Green
Write-Host "  ID: $projectGlobalId" -ForegroundColor Gray
Write-Host ""

# Find fields
$issueTypeField = $fields | Where-Object { $_.name -eq "Issue Type" }
$priorityField = $fields | Where-Object { $_.name -eq "Priority" }
$riskField = $fields | Where-Object { $_.name -eq "Risk" }
$startDateField = $fields | Where-Object { $_.name -eq "Start Date" }
$endDateField = $fields | Where-Object { $_.name -eq "End Date" }

# Build option maps
$issueTypeOptions = @{}
if ($issueTypeField) {
    $issueTypeField.options | ForEach-Object { $issueTypeOptions[$_.name] = $_.id }
    Write-Host "✓ Issue Type field found ($($issueTypeOptions.Count) options)" -ForegroundColor Green
}
else {
    Write-Host "⚠ Issue Type field not found" -ForegroundColor Yellow
}

$priorityOptions = @{}
if ($priorityField) {
    $priorityField.options | ForEach-Object { $priorityOptions[$_.name] = $_.id }
    Write-Host "✓ Priority field found ($($priorityOptions.Count) options)" -ForegroundColor Green
}
else {
    Write-Host "⚠ Priority field not found" -ForegroundColor Yellow
}

$riskOptions = @{}
if ($riskField) {
    $riskField.options | ForEach-Object { $riskOptions[$_.name] = $_.id }
    Write-Host "✓ Risk field found ($($riskOptions.Count) options)" -ForegroundColor Green
}
else {
    Write-Host "⚠ Risk field not found" -ForegroundColor Yellow
}

if ($startDateField) {
    Write-Host "✓ Start Date field found" -ForegroundColor Green
}
if ($endDateField) {
    Write-Host "✓ End Date field found" -ForegroundColor Green
}

Write-Host ""
#endregion

#region Step 4: Populate Field Values
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 4: Populating Field Values from Labels" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($repo in $REPOS) {
    $issues = gh issue list --repo $repo --limit 1000 --state all --json number,title,labels | ConvertFrom-Json
    
    foreach ($issue in $issues) {
        $issueUrl = "https://github.com/$repo/issues/$($issue.number)"
        $labels = $issue.labels | ForEach-Object { $_.name }
        
        # Get project item ID
        $itemQuery = @"
query {
  resource(url: "$issueUrl") {
    ... on Issue {
      projectItems(first: 10) {
        nodes {
          id
          project {
            id
          }
        }
      }
    }
  }
}
"@
        
        try {
            $itemData = gh api graphql -f query=$itemQuery | ConvertFrom-Json
            $projectItem = $itemData.data.resource.projectItems.nodes | Where-Object { $_.project.id -eq $projectGlobalId }
            
            if (-not $projectItem) {
                Write-Host "  ⊙ #$($issue.number) not in project, skipping" -ForegroundColor Gray
                continue
            }
            
            $itemId = $projectItem.id
            Write-Host "  Processing #$($issue.number) - $($issue.title)" -ForegroundColor Cyan
            
            # Determine Issue Type from labels
            $issueType = $null
            if ($labels -contains "requirement") {
                if ($issue.title -match "^\[F-") {
                    $issueType = "Functional"
                }
                elseif ($issue.title -match "^\[NF-") {
                    $issueType = "Non Functional"
                }
            }
            else {
                # Check for type:* labels
                $typeLabel = $labels | Where-Object { $_ -match "^type:" } | Select-Object -First 1
                if ($typeLabel) {
                    $typeValue = ($typeLabel -replace "^type:", "")
                    $issueType = $typeValue.Substring(0,1).ToUpper() + $typeValue.Substring(1)
                }
            }
            
            # Update Issue Type
            if ($issueType -and $issueTypeOptions.ContainsKey($issueType)) {
                $mutation = @"
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "$projectGlobalId"
    itemId: "$itemId"
    fieldId: "$($issueTypeField.id)"
    value: {singleSelectOptionId: "$($issueTypeOptions[$issueType])"}
  }) {
    projectV2Item {
      id
    }
  }
}
"@
                gh api graphql -f query=$mutation | Out-Null
                Write-Host "    ✓ Issue Type: $issueType" -ForegroundColor Green
                $stats.FieldsUpdated++
            }
            
            # Update Priority
            $priorityLabel = $labels | Where-Object { $_ -match "^priority:" } | Select-Object -First 1
            if ($priorityLabel) {
                $priorityValue = ($priorityLabel -replace "^priority:", "")
                $priority = $priorityValue.Substring(0,1).ToUpper() + $priorityValue.Substring(1)
                
                if ($priorityOptions.ContainsKey($priority)) {
                    $mutation = @"
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "$projectGlobalId"
    itemId: "$itemId"
    fieldId: "$($priorityField.id)"
    value: {singleSelectOptionId: "$($priorityOptions[$priority])"}
  }) {
    projectV2Item {
      id
    }
  }
}
"@
                    gh api graphql -f query=$mutation | Out-Null
                    Write-Host "    ✓ Priority: $priority" -ForegroundColor Green
                    $stats.FieldsUpdated++
                }
            }
            
            # Update Risk
            $riskLabel = $labels | Where-Object { $_ -match "^risk:" } | Select-Object -First 1
            if ($riskLabel) {
                $riskValue = ($riskLabel -replace "^risk:", "")
                $risk = $riskValue.Substring(0,1).ToUpper() + $riskValue.Substring(1)
                
                if ($riskOptions.ContainsKey($risk)) {
                    $mutation = @"
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "$projectGlobalId"
    itemId: "$itemId"
    fieldId: "$($riskField.id)"
    value: {singleSelectOptionId: "$($riskOptions[$risk])"}
  }) {
    projectV2Item {
      id
    }
  }
}
"@
                    gh api graphql -f query=$mutation | Out-Null
                    Write-Host "    ✓ Risk: $risk" -ForegroundColor Green
                    $stats.FieldsUpdated++
                }
            }
            
            # Update Dates from milestone labels
            $milestoneLabel = $labels | Where-Object { $_ -match "^milestone:" } | Select-Object -First 1
            if ($milestoneLabel -and $milestoneDates.ContainsKey($milestoneLabel)) {
                $dates = $milestoneDates[$milestoneLabel]
                
                # Set Start Date
                if ($startDateField) {
                    $mutation = @"
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "$projectGlobalId"
    itemId: "$itemId"
    fieldId: "$($startDateField.id)"
    value: {date: "$($dates.Start)"}
  }) {
    projectV2Item {
      id
    }
  }
}
"@
                    gh api graphql -f query=$mutation | Out-Null
                }
                
                # Set End Date
                if ($endDateField) {
                    $mutation = @"
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "$projectGlobalId"
    itemId: "$itemId"
    fieldId: "$($endDateField.id)"
    value: {date: "$($dates.End)"}
  }) {
    projectV2Item {
      id
    }
  }
}
"@
                    gh api graphql -f query=$mutation | Out-Null
                }
                
                Write-Host "    ✓ Dates: $($dates.Start) to $($dates.End)" -ForegroundColor Green
                $stats.FieldsUpdated++
            }
            
            Start-Sleep -Milliseconds 250
        }
        catch {
            Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
        }
    }
}
Write-Host ""
#endregion

#region Step 5: Create Parent/Child Relationships
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 5: Creating Parent/Child Relationships" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Load epic/task relationships from JSON
$epicsFile = ".\project\github-data\epics-and-tasks.json"
if (Test-Path $epicsFile) {
    $epicsData = Get-Content $epicsFile -Raw | ConvertFrom-Json
    
    foreach ($epic in $epicsData.epics) {
        $repo = "$ORG/$($epic.repository)"
        
        # Find epic issue
        $epicIssues = gh issue list --repo $repo --search "in:title `"$($epic.title)`"" --limit 1 --json number,title --state all | ConvertFrom-Json
        if ($epicIssues.Count -eq 0) {
            Write-Host "  ⚠ Epic not found: $($epic.title)" -ForegroundColor Yellow
            continue
        }
        
        $epicNumber = $epicIssues[0].number
        $epicId = (gh api "repos/$repo/issues/$epicNumber" --jq '.node_id')
        
        Write-Host "  Epic: $($epic.title) #$epicNumber" -ForegroundColor White
        
        # Link each task to epic
        foreach ($task in $epic.tasks) {
            $taskIssues = gh issue list --repo $repo --search "in:title `"$($task.title)`"" --limit 1 --json number --state all | ConvertFrom-Json
            if ($taskIssues.Count -eq 0) {
                Write-Host "    ⚠ Task not found: $($task.title)" -ForegroundColor Yellow
                continue
            }
            
            $taskNumber = $taskIssues[0].number
            $taskId = (gh api "repos/$repo/issues/$taskNumber" --jq '.node_id')
            
            # Create parent relationship using GraphQL
            $mutation = @"
mutation {
  addSubIssue(input: {
    issueId: "$epicId"
    subIssueId: "$taskId"
  }) {
    subIssue {
      id
    }
  }
}
"@
            
            try {
                gh api graphql -f query=$mutation | Out-Null
                Write-Host "    ✓ Linked task #$taskNumber to epic #$epicNumber" -ForegroundColor Green
                $stats.RelationshipsCreated++
            }
            catch {
                if ($_.Exception.Message -match "already exists") {
                    Write-Host "    ⊙ Task #$taskNumber already linked" -ForegroundColor Gray
                }
                else {
                    Write-Host "    ✗ Failed to link task #$taskNumber: $($_.Exception.Message)" -ForegroundColor Red
                    $stats.Errors++
                }
            }
            Start-Sleep -Milliseconds 300
        }
        Write-Host ""
    }
}
else {
    Write-Host "⚠ Epic/task relationships file not found, skipping" -ForegroundColor Yellow
}
#endregion

# Summary
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Items Added:             $($stats.ItemsAdded)" -ForegroundColor Green
Write-Host "Fields Updated:          $($stats.FieldsUpdated)" -ForegroundColor Green
Write-Host "Relationships Created:   $($stats.RelationshipsCreated)" -ForegroundColor Green
Write-Host "Errors:                  $($stats.Errors)" -ForegroundColor $(if ($stats.Errors -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "✓ Project board configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "View project: $PROJECT_URL" -ForegroundColor Cyan
Write-Host ""
