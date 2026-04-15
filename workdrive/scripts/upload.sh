#!/bin/bash
set -euo pipefail

# Uploads a file to Zoho WorkDrive (up to ~250MB).
# Returns JSON response with resource_id and Permalink.
#
# Usage:
#   bash scripts/upload.sh <parent_folder_id> <file_path> [--overwrite]
#
# Options:
#   --overwrite  Overwrite if file with same name exists (default: false)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_usage() {
  echo "Usage: $0 <parent_folder_id> <file_path> [--overwrite]" >&2
  exit 1
}

[ $# -ge 2 ] || show_usage

PARENT_ID="$1"
FILE_PATH="$2"
OVERRIDE="false"

[ "${3:-}" = "--overwrite" ] && OVERRIDE="true"

if [ ! -f "$FILE_PATH" ]; then
  echo "ERROR: File not found: $FILE_PATH" >&2
  exit 1
fi

TOKEN=$("$SCRIPT_DIR/auth.sh")

curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "content=@$FILE_PATH" \
  -F "parent_id=$PARENT_ID" \
  -F "override-name-exist=$OVERRIDE"
