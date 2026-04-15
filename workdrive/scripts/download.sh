#!/bin/bash
set -euo pipefail

# Downloads a file from Zoho WorkDrive.
#
# Usage:
#   bash scripts/download.sh <file_id> <output_path>

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_usage() {
  echo "Usage: $0 <file_id> <output_path>" >&2
  exit 1
}

[ $# -eq 2 ] || show_usage

FILE_ID="$1"
OUTPUT_PATH="$2"

TOKEN=$("$SCRIPT_DIR/auth.sh")

HTTP_CODE=$(curl -s -w "%{http_code}" \
  "https://www.zohoapis.com/workdrive/api/v1/download/$FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -o "$OUTPUT_PATH")

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "ERROR: Download failed with HTTP $HTTP_CODE" >&2
  exit 1
fi

echo "$OUTPUT_PATH"
