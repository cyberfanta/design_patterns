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
