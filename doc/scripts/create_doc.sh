#!/bin/bash
set -euo pipefail

# Creates a new document in Zoho Writer.
# Returns JSON with document_id, open_url, document_name.
#
# Usage:
#   bash scripts/create_doc.sh <folder_id> <filename> <content_file>
#
# Arguments:
#   folder_id    — WorkDrive folder ID where the doc will be created
#   filename     — Display name for the document
#   content_file — Path to local HTML file with document content

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_usage() {
  echo "Usage: $0 <folder_id> <filename> <content_file>" >&2
  exit 1
}

[ $# -eq 3 ] || show_usage

FOLDER_ID="$1"
FILENAME="$2"
CONTENT_FILE="$3"

if [ ! -f "$CONTENT_FILE" ]; then
  echo "ERROR: Content file not found: $CONTENT_FILE" >&2
  exit 1
fi

TOKEN=$("$SCRIPT_DIR/auth.sh")

curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@$CONTENT_FILE" \
  -F "folder_id=$FOLDER_ID" \
  -F "filename=$FILENAME"
