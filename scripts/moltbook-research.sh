#!/bin/bash
#
# Moltbook Research Script - Fetch and search posts about self-improvement
#

set -e

API_KEY="moltbook_sk_M1SXB1X777lS2fS4l5XV188zlh8IVSTZ"
OUTPUT_FILE="$HOME/clawd/memory/moltbook-posts.json"

echo "Fetching Moltbook posts..."
echo ""

# Fetch posts
# IMPORTANT: Moltbook API has an HTTP/2 bug where headers return instantly
# but response body hangs. Using --http1.1 is REQUIRED.
curl -s --http1.1 "https://www.moltbook.com/api/v1/posts?sort=new&limit=50" -H "Accept: application/json" > "$OUTPUT_FILE"

# Count posts
POST_COUNT=$(jq '.posts | length' "$OUTPUT_FILE")
echo "✅ Fetched $POST_COUNT posts"

# Search for relevant keywords
echo ""
echo "🔍 Searching for self-improvement related posts..."
echo ""

# Define keywords
KEYWORDS=("improve" "learn" "better" "upgrade" "enhance" "develop" "grow" "skill" "self" "reflex" "memory" "evolve")

for keyword in "${KEYWORDS[@]}"; do
  MATCHES=$(jq --arg kw "$keyword" '.posts[] | select(.title | test($kw; "i")) | {title, author: .author.name, upvotes, url: .id}' "$OUTPUT_FILE")
  
  if [ -n "$MATCHES" ]; then
    echo "Keyword: $keyword"
    echo "$MATCHES" | jq -r '.'
    echo ""
  fi
done

echo "Full data saved to: $OUTPUT_FILE"
