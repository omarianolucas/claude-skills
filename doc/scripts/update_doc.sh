#!/bin/bash
set -euo pipefail

# Updates an existing Zoho Writer document with new content.
# Preserves doc_id and version history.
#
# Usage:
#   bash scripts/update_doc.sh <doc_id> <content_file>
#
# Arguments:
#   doc_id       — Zoho Writer document ID
#   content_file — Path to local HTML file with new content

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_usage() {
  echo "Usage: $0 <doc_id> <content_file>" >&2
  exit 1
}

[ $# -eq 2 ] || show_usage

DOC_ID="$1"
CONTENT_FILE="$2"

if [ ! -f "$CONTENT_FILE" ]; then
  echo "ERROR: Content file not found: $CONTENT_FILE" >&2
  exit 1
fi

TOKEN=$("$SCRIPT_DIR/auth.sh")

curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents/$DOC_ID" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@$CONTENT_FILE"
