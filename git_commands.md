# Git Commands and Scripts - Design Patterns Flutter App

## 🚫 IMPORTANT: AI GIT RESTRICTIONS
**The AI is PROHIBITED from using Git commands directly.**

If file deletion or rollback is needed, the AI must request user assistance.

---

## 📊 COMMIT HISTORY SCRIPT

### PowerShell Script (Windows)
Create file: `generate_git_log.ps1`

```powershell
#!/usr/bin/env pwsh

# Git Commit History Generator
# Generates grouped commit log by date

param(
    [string]$OutputFile = "git_history.md",
    [string]$Repository = ".",
    [int]$MaxCommits = 100
)

Write-Host "🚀 Generating Git commit history..." -ForegroundColor Green

# Change to repository directory
Set-Location $Repository

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Error "❌ Not a Git repository!"
    exit 1
}

# Generate commit log with custom format
$commits = git log --pretty=format:"%H|%s|%an|%ad|%ar" --date=short --max-count=$MaxCommits

if (-not $commits) {
    Write-Error "❌ No commits found!"
    exit 1
}

# Group commits by date
$groupedCommits = @{}
foreach ($commit in $commits) {
    $parts = $commit -split '\|'
    $hash = $parts[0].Substring(0, 7)  # Short hash
    $subject = $parts[1]
    $author = $parts[2]
    $date = $parts[3]
    $relative = $parts[4]
    
    if (-not $groupedCommits[$date]) {
        $groupedCommits[$date] = @()
    }
    
    $groupedCommits[$date] += @{
        Hash = $hash
        Subject = $subject
        Author = $author
        Date = $date
        Relative = $relative
    }
}

# Generate Markdown report
$markdown = @"
# Git Commit History Report
**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Repository:** $(Split-Path -Leaf (Get-Location))
**Total Commits:** $($commits.Count)

---

"@

# Sort dates in descending order (most recent first)
$sortedDates = $groupedCommits.Keys | Sort-Object -Descending

foreach ($date in $sortedDates) {
    $commitsForDate = $groupedCommits[$date]
    $markdown += "## 📅 $date`n`n"
    
    foreach ($commit in $commitsForDate) {
        $markdown += "- **$($commit.Hash)** - $($commit.Subject)`n"
        $markdown += "  - 👤 **Author:** $($commit.Author)`n"
        $markdown += "  - 📅 **Date:** $($commit.Date) ($($commit.Relative))`n`n"
    }
    
    $markdown += "---`n`n"
}

# Add statistics
$uniqueAuthors = ($commits | ForEach-Object { ($_ -split '\|')[2] } | Sort-Object -Unique).Count
$markdown += @"
## 📊 Statistics

- **Total Commits:** $($commits.Count)
- **Date Range:** $(($sortedDates | Select-Object -Last 1)) to $(($sortedDates | Select-Object -First 1))
- **Unique Authors:** $uniqueAuthors
- **Days with Commits:** $($groupedCommits.Keys.Count)

---
*Generated with Git History Script v1.0*
"@

# Write to file
$markdown | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "✅ Git history generated successfully!" -ForegroundColor Green
Write-Host "📄 Output file: $OutputFile" -ForegroundColor Cyan
Write-Host "📊 Processed $($commits.Count) commits across $($groupedCommits.Keys.Count) days" -ForegroundColor Yellow
```

### Bash Script (Linux/macOS)
Create file: `generate_git_log.sh`

```bash
#!/bin/bash

# Git Commit History Generator
# Generates grouped commit log by date

OUTPUT_FILE=${1:-"git_history.md"}
MAX_COMMITS=${2:-100}

echo "🚀 Generating Git commit history..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a Git repository!"
    exit 1
fi

# Temporary file for processing
TEMP_FILE=$(mktemp)

# Generate commit log
git log --pretty=format:"%H|%s|%an|%ad|%ar" --date=short --max-count=$MAX_COMMITS > "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
    echo "❌ No commits found!"
    rm "$TEMP_FILE"
    exit 1
fi

# Create markdown file
cat > "$OUTPUT_FILE" << EOF
# Git Commit History Report
**Generated:** $(date "+%Y-%m-%d %H:%M:%S")
**Repository:** $(basename "$(pwd)")
**Total Commits:** $(wc -l < "$TEMP_FILE")

---

EOF

# Process commits and group by date
declare -A commits_by_date

while IFS='|' read -r hash subject author date relative; do
    short_hash=${hash:0:7}
    
    if [ -z "${commits_by_date[$date]}" ]; then
        commits_by_date[$date]="$short_hash|$subject|$author|$date|$relative"
    else
        commits_by_date[$date]="${commits_by_date[$date]}"$'\n'"$short_hash|$subject|$author|$date|$relative"
    fi
done < "$TEMP_FILE"

# Sort dates in descending order and output
for date in $(printf '%s\n' "${!commits_by_date[@]}" | sort -r); do
    echo "## 📅 $date" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "${commits_by_date[$date]}" | while IFS='|' read -r short_hash subject author commit_date relative; do
        echo "- **$short_hash** - $subject" >> "$OUTPUT_FILE"
        echo "  - 👤 **Author:** $author" >> "$OUTPUT_FILE"
        echo "  - 📅 **Date:** $commit_date ($relative)" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done
    
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# Add statistics
TOTAL_COMMITS=$(wc -l < "$TEMP_FILE")
UNIQUE_AUTHORS=$(cut -d'|' -f3 "$TEMP_FILE" | sort -u | wc -l)
UNIQUE_DATES=$(printf '%s\n' "${!commits_by_date[@]}" | wc -l)
FIRST_DATE=$(printf '%s\n' "${!commits_by_date[@]}" | sort | head -1)
LAST_DATE=$(printf '%s\n' "${!commits_by_date[@]}" | sort | tail -1)

cat >> "$OUTPUT_FILE" << EOF
## 📊 Statistics

- **Total Commits:** $TOTAL_COMMITS
- **Date Range:** $FIRST_DATE to $LAST_DATE
- **Unique Authors:** $UNIQUE_AUTHORS
- **Days with Commits:** $UNIQUE_DATES

---
*Generated with Git History Script v1.0*
EOF

# Cleanup
rm "$TEMP_FILE"

echo "✅ Git history generated successfully!"
echo "📄 Output file: $OUTPUT_FILE"
echo "📊 Processed $TOTAL_COMMITS commits across $UNIQUE_DATES days"
```

---

## 🚀 **COMMAND TO EXECUTE** (Run only once)

### Windows (PowerShell) - **RECOMMENDED COMMAND**
```powershell
# Step 1: Make script executable (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Step 2: Run git history generator
./generate_git_log.ps1

# Alternative with custom output file
./generate_git_log.ps1 -OutputFile "git_bitacora.md" -MaxCommits 100
```

### Linux/macOS (Bash)
```bash
# Step 1: Make executable and run
chmod +x generate_git_log.sh
./generate_git_log.sh

# Alternative with custom parameters  
./generate_git_log.sh "git_bitacora.md" 100
```

### **OUTPUT FILE DETAILS:**
- **Default filename**: `git_history.md`
- **Location**: Project root directory (same level as pubspec.yaml)
- **Format**: Markdown with commits grouped by date (newest first)
- **Content**: Commit hash, message, author, date, relative time

### **EXPECTED RESULT:**
```
✅ Git history generated successfully!
📄 Output file: git_history.md
📊 Processed X commits across Y days
```

---

## 📋 USEFUL GIT COMMANDS FOR USER

### Basic Information
```bash
# Show current branch and status
git status

# Show commit history (oneline)
git log --oneline

# Show commit history with graph
git log --graph --oneline --decorate --all

# Show last N commits
git log -n 10

# Show commits from specific author
git log --author="username"

# Show commits in date range
git log --since="2024-01-01" --until="2024-12-31"
```

### Branch Management
```bash
# List all branches
git branch -a

# Create new branch
git checkout -b new-feature

# Switch to branch
git checkout main

# Delete branch (local)
git branch -d feature-name

# Delete branch (remote)
git push origin --delete feature-name
```

### File Operations
```bash
# Show changes in working directory
git diff

# Show changes in staged files
git diff --cached

# Show changes between commits
git diff commit1 commit2

# Show files changed in commit
git show --name-only commit-hash

# Restore file to last commit
git checkout -- filename

# Remove file from git (keep local)
git rm --cached filename
```

### Emergency Commands
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Show reflog (recovery)
git reflog

# Create backup branch
git branch backup-$(date +%Y%m%d-%H%M%S)
```

---

## ⚠️ IMPORTANT NOTES

1. **Run the history script only once** as requested
2. **The AI cannot execute these commands** - user must run them
3. **Always backup important changes** before running destructive commands
4. **Use the generated markdown report** for documentation purposes
5. **Keep scripts in project root** for easy access
