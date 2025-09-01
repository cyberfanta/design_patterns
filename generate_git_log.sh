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
