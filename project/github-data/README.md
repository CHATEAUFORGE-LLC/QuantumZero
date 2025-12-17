# QuantumZero GitHub Project Setup

Complete automation for creating GitHub issues, project boards, and relationships from JSON configuration files.

## Quick Start

```powershell
# Navigate to project root
cd C:\Users\jrace\gitlab\CSC686\projects\QuantumZero

# Run complete setup
.\project\github-data\setup.ps1
```

That's it! The script will:
- ✓ Verify prerequisites (GitHub CLI, authentication, repository access)
- ✓ Create 31 labels across 4 repositories
- ✓ Create 6 milestones (M1-M6) with due dates
- ✓ Generate 129 issues (60 requirements, 17 epics, 52 tasks)
- ✓ Add all issues to organization project board
- ✓ Set milestones, priorities, risks, and dates
- ✓ Link parent/child relationships

**Time:** ~15-20 minutes | **Result:** Fully configured project ready for development

---

## What Gets Created

| Component | Count | Description |
|-----------|-------|-------------|
| **Labels** | 124 | 31 labels × 4 repos (type, priority, risk, milestone, component) |
| **Milestones** | 24 | 6 milestones × 4 repos (M1-M6, Nov 2025 - Feb 2026) |
| **Requirements** | 60 | 31 functional + 29 non-functional |
| **Epics** | 17 | Major feature groupings across 6 milestones |
| **Tasks** | 52 | Individual work items linked to epics |
| **Total Issues** | **129** | Distributed across 4 repositories |

### Repository Distribution
- **QuantumZero** (60 issues): Documentation, requirements, cross-cutting epics
- **QuantumZero-mobile** (34 issues): Mobile wallet, iOS/Android development
- **QuantumZero-server** (32 issues): Backend services, APIs, verification
- **QuantumZero-sdk** (3 issues): SDK evaluation and crypto libraries

### Milestone Timeline
```
M1 │ Requirements & Architecture    │ Nov 23 - Dec 27, 2025
M2 │ Core Identity & Wallet         │ Dec 16 - Jan 10, 2026
M3 │ Issuance & Verification        │ Jan 6 - Jan 20, 2026
M4 │ Zero-Knowledge Proofs          │ Jan 21 - Feb 2, 2026
M5 │ Integration & Testing          │ Feb 3 - Feb 15, 2026
M6 │ Documentation & Delivery       │ Feb 16 - Feb 28, 2026
```

---

## Prerequisites

- **GitHub CLI** (`gh`) version 2.40.0+ installed and authenticated
- **PowerShell** 7.0+ (Windows PowerShell 5.1+ also works)
- **Repository Access**: Admin/write access to all 4 repositories
- **Organization Access**: Member of CHATEAUFORGE-LLC organization

### Verify Prerequisites
```powershell
.\project\github-data\verify-prerequisites.ps1
```

---

## Configuration Files

All configuration is driven by JSON files in `project/github-data/`:

### Core Data Files

**`labels.json`** - 31 label definitions
```json
{
  "labels": [
    {"name": "type:analysis", "color": "1d76db", "description": "Analysis phase work"},
    {"name": "priority:high", "color": "d73a4a", "description": "High priority"},
    {"name": "risk:technical", "color": "fbca04", "description": "Technical risk"}
  ]
}
```

**`epics-and-tasks.json`** - Milestones, epics, and tasks
```json
{
  "milestones": [...],
  "epics": [
    {
      "title": "[EPIC] Requirements Finalization",
      "repository": "QuantumZero",
      "milestone": "M1",
      "labels": ["epic", "priority:high"],
      "tasks": [...]
    }
  ]
}
```

**`functional-requirements.json`** - 31 functional requirements (F-*)

**`nonfunctional-requirements.json`** - 29 non-functional requirements (NF-*)

---

## Scripts Overview

The setup process uses three main scripts:

### 1. `verify-prerequisites.ps1`
Checks all prerequisites before running setup:
- GitHub CLI installation and authentication
- Repository access permissions
- JSON file validity
- Current directory verification

**Run:** `.\project\github-data\verify-prerequisites.ps1`

### 2. `create-github-structure.ps1`
Creates the GitHub repository structure:
- Creates labels in all repositories
- Creates milestones with due dates
- Generates requirement issues
- Creates epic and task issues with relationships

**Run:** `.\project\github-data\create-github-structure.ps1`

### 3. `configure-project-board.ps1`
Configures the organization project board:
- Adds all issues to project board
- Populates custom fields (Issue Type, Priority, Risk)
- Sets milestone-based start/end dates
- Creates parent/child relationships

**Run:** `.\project\github-data\configure-project-board.ps1`

### 4. `setup.ps1` (Master Script)
Orchestrates all steps with progress tracking and error handling.

**Run:** `.\project\github-data\setup.ps1`

---

## Manual Setup (Step by Step)

If you prefer to run each step individually:

```powershell
# Step 1: Verify prerequisites
.\project\github-data\verify-prerequisites.ps1

# Step 2: Create GitHub structure (labels, milestones, issues)
.\project\github-data\create-github-structure.ps1

# Step 3: Configure project board (fields, relationships)
.\project\github-data\configure-project-board.ps1
```

---

## Label System

Labels are automatically applied to issues based on configuration:

### Type Labels (Work Phase)
- `type:analysis` - Requirements analysis, research
- `type:design` - Architecture, system design
- `type:implementation` - Development, coding
- `type:testing` - Testing, QA
- `type:documentation` - Documentation work
- `type:security` - Security-related work
- `type:research` - Research activities

### Priority Labels
- `priority:high` - Critical path, blockers
- `priority:medium` - Standard priority
- `priority:low` - Nice to have, future

### Risk Labels
- `risk:technical` - Technical complexity/uncertainty
- `risk:schedule` - Schedule pressure/dependency
- `risk:integration` - Integration challenges

### Component Labels
- `component:mobile` - Mobile wallet app
- `component:backend` - Backend services
- `component:sdk` - SDK and libraries
- `component:all` - Cross-cutting concerns

### Milestone Labels
- `milestone:m1` through `milestone:m6` - Milestone association

### Special Labels
- `epic` - Parent issue with child tasks
- `requirement` - Functional or non-functional requirement
- `bug` - Bug report
- `enhancement` - Feature enhancement

---

## Project Board Fields

The organization project board includes these custom fields:

| Field | Type | Options | Description |
|-------|------|---------|-------------|
| **Issue Type** | Single Select | Functional, Non Functional, Analysis, Design, Implementation, Documentation, Security, Research | Categorizes issue purpose |
| **Priority** | Single Select | High, Medium, Low | Priority level from labels |
| **Risk** | Single Select | Technical, Schedule, Integration | Associated risks |
| **Start Date** | Date | - | Milestone start date |
| **End Date** | Date | - | Milestone end date |

### Built-in Fields
- Title, Assignees, Status, Labels, Milestone, Repository
- **Parent issue** - Shows epic for tasks
- **Sub-issues progress** - Tracks task completion in epics

---

## Issue Relationships

Issues are linked using GitHub's relationship features:

### Parent/Child (Epic → Task)
- Tasks show parent epic in **Relationships** section
- Epics show child tasks as checkboxes in description
- Checking a task checkbox auto-updates epic progress

### Task Lists in Epics
Epic descriptions include task lists:
```markdown
## Tasks
- [ ] #42 - Implement DID generation workflow
- [ ] #43 - Implement VC storage model
- [x] #44 - Implement VP creation logic (completed)
```

When you close a task issue, its checkbox auto-checks in the epic! ✨

---

## Customization

### Modify Labels
Edit `labels.json` to add/remove/change labels:
```json
{"name": "custom:label", "color": "1d76db", "description": "Custom label"}
```

### Add Milestones
Edit `epics-and-tasks.json` milestones array:
```json
{
  "id": "M7",
  "title": "Milestone M7 - Post-Launch Support",
  "dueDate": "2026-03-31",
  "description": "Post-launch monitoring and support"
}
```

### Create New Epics
Add to `epics-and-tasks.json` epics array:
```json
{
  "title": "[EPIC] New Feature Area",
  "repository": "QuantumZero",
  "milestone": "M3",
  "labels": ["epic", "priority:high", "component:all"],
  "description": "Epic description...",
  "tasks": [...]
}
```

### Add Requirements
Add to `functional-requirements.json` or `nonfunctional-requirements.json`:
```json
{
  "id": "F-NEW-01",
  "title": "New Requirement",
  "category": "Operation",
  "description": "...",
  "acceptanceCriteria": [...],
  "milestone": "M3",
  "labels": ["requirement", "priority:high"]
}
```

After editing JSON files, re-run:
```powershell
.\project\github-data\create-github-structure.ps1
```

---

## Viewing Results

### GitHub Web UI
- **Project Board**: https://github.com/orgs/CHATEAUFORGE-LLC/projects/1
- **QuantumZero Issues**: https://github.com/CHATEAUFORGE-LLC/QuantumZero/issues
- **Mobile Issues**: https://github.com/CHATEAUFORGE-LLC/QuantumZero-mobile/issues
- **Server Issues**: https://github.com/CHATEAUFORGE-LLC/QuantumZero-server/issues
- **SDK Issues**: https://github.com/CHATEAUFORGE-LLC/QuantumZero-sdk/issues

### GitHub CLI
```powershell
# List all issues in main repo
gh issue list --repo CHATEAUFORGE-LLC/QuantumZero

# Filter by label
gh issue list --repo CHATEAUFORGE-LLC/QuantumZero --label "priority:high"

# Filter by milestone
gh issue list --repo CHATEAUFORGE-LLC/QuantumZero --milestone "M1"

# View specific issue
gh issue view 42 --repo CHATEAUFORGE-LLC/QuantumZero

# View project board
gh project view 1 --owner CHATEAUFORGE-LLC
```

---

## Troubleshooting

### GitHub CLI Not Authenticated
```powershell
gh auth login
# Follow prompts to authenticate with GitHub
```

### Permission Denied Errors
Ensure you have admin/write access to all repositories:
```powershell
gh repo view CHATEAUFORGE-LLC/QuantumZero
```

### Rate Limiting
Scripts include automatic rate limiting delays (250-500ms between operations). If you hit rate limits, wait a few minutes and re-run.

### Script Errors
Run verification first to diagnose issues:
```powershell
.\project\github-data\verify-prerequisites.ps1
```

### Issues Already Exist
Scripts check for existing issues and skip duplicates. To recreate, delete existing issues first:
```powershell
# List all issues
gh issue list --repo CHATEAUFORGE-LLC/QuantumZero --state all

# Delete specific issue (careful!)
gh issue delete 42 --repo CHATEAUFORGE-LLC/QuantumZero
```

---

## Architecture

### Data Flow
```
JSON Config Files
    ↓
create-github-structure.ps1
    ↓
GitHub Repositories (labels, milestones, issues)
    ↓
configure-project-board.ps1
    ↓
Project Board (fields, relationships)
```

### Script Dependencies
```
setup.ps1 (master orchestrator)
    ├── verify-prerequisites.ps1
    ├── create-github-structure.ps1
    │   ├── labels.json
    │   ├── epics-and-tasks.json
    │   ├── functional-requirements.json
    │   └── nonfunctional-requirements.json
    └── configure-project-board.ps1
```

---

## Project Statistics

- **Total Issues**: 129 across 4 repositories
- **Epics**: 17 (with 52 child tasks)
- **Requirements**: 60 (31 functional + 29 non-functional)
- **Labels**: 31 types, applied 124 times (31 × 4 repos)
- **Milestones**: 6 (M1-M6, spanning 14 weeks)
- **Parent/Child Links**: 52 task → epic relationships
- **Project Board Items**: 129 with custom fields populated
- **Setup Time**: ~15-20 minutes for complete automation

---

## Support

For issues or questions:
1. Check **Troubleshooting** section above
2. Run `verify-prerequisites.ps1` to diagnose problems
3. Review GitHub CLI docs: https://cli.github.com/manual/
4. Check GitHub Projects docs: https://docs.github.com/en/issues/planning-and-tracking-with-projects

---

## License

See [LICENSE](../../LICENSE) file in repository root.
