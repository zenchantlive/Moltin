#!/bin/bash
#
# Moltbook Post Script
# Reliable posting to Moltbook with retries and better error handling
#

set -e

# Load API key from credentials
CREDS_FILE="$HOME/.config/moltbook/credentials.json"
if [ ! -f "$CREDS_FILE" ]; then
    echo "Error: Moltbook credentials not found at $CREDS_FILE"
    exit 1
fi

API_KEY=$(jq -r '.api_key' "$CREDS_FILE")
AGENT_NAME=$(jq -r '.agent_name' "$CREDS_FILE")

# Default values
SUBMOLT="${1:-general}"
TITLE="$2"
CONTENT="$3"
MAX_RETRIES=3
CONNECT_TIMEOUT=15
MAX_TIME=45

# Validate inputs
if [ -z "$TITLE" ] || [ -z "$CONTENT" ]; then
    echo "Usage: $0 [submolt] <title> <content>"
    echo ""
    echo "Example:"
    echo '  $0 "Hello World" "This is my first post!"'
    echo '  $0 "dev" "Technical question" "How do I handle X?"'
    exit 1
fi

# Escape content for JSON (basic escaping)
CONTENT_ESCAPED=$(echo "$CONTENT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')

echo "Posting to Moltbook..."
echo "Agent: $AGENT_NAME"
echo "Submolt: $SUBMOLT"
echo "Title: $TITLE"
echo "Content: ${CONTENT:0:100}..."
echo ""

# Retry loop
ATTEMPT=1
while [ $ATTEMPT -le $MAX_RETRIES ]; do
    echo "Attempt $ATTEMPT of $MAX_RETRIES..."

    # Construct JSON payload
    PAYLOAD=$(cat <<EOF
{
  "submolt": "$SUBMOLT",
  "title": "$TITLE",
  "content": $CONTENT_ESCAPED
}
EOF
)

    # Make the request
    # IMPORTANT: Moltbook API has an HTTP/2 bug where headers return instantly
    # but response body hangs. Using --http1.1 is REQUIRED.
    RESPONSE=$(curl -s \
        --http1.1 \
        -X POST "https://www.moltbook.com/api/v1/posts" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD" \
        --connect-timeout $CONNECT_TIMEOUT \
        --max-time $MAX_TIME \
        -w "\n%{http_code}" \
        2>&1)

    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    echo "HTTP Status: $HTTP_CODE"

    # Check if successful
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        echo "✅ Post successful!"
        echo ""
        echo "Response:"
        echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
        exit 0
    fi

    # Check specific errors
    if echo "$BODY" | grep -q "429"; then
        echo "❌ Rate limited. Check retry_after in response:"
        echo "$BODY" | jq -r '.retry_after // "unknown"' 2>/dev/null || echo "unknown"
        exit 1
    fi

    if echo "$BODY" | grep -q "Invalid API key"; then
        echo "❌ Invalid API key. Check credentials."
        exit 1
    fi

    # Timeout or other error
    if [ "$HTTP_CODE" = "000" ] || [ "$HTTP_CODE" = "0000" ]; then
        echo "❌ Connection timeout. Retrying..."
    else
        echo "❌ Unexpected error: $HTTP_CODE"
        echo "$BODY"
    fi

    # Wait before retry
    if [ $ATTEMPT -lt $MAX_RETRIES ]; then
        WAIT=$((ATTEMPT * 5))
        echo "Waiting ${WAIT}s before retry..."
        sleep $WAIT
        ATTEMPT=$((ATTEMPT + 1))
    fi
done

echo ""
echo "❌ Failed after $MAX_RETRIES attempts"
echo "Last response:"
echo "$BODY"
exit 1
