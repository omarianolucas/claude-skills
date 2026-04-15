#!/bin/bash
set -euo pipefail

# Downloads a Zoho Meet recording (MP4) using the download URL.
# Note: uses Zoho-oauthtoken auth (NOT Bearer) — this is a Zoho inconsistency.
#
# Usage:
#   bash scripts/download_recording.sh <download_url> <output_file>
#
# Arguments:
#   download_url — The downloadUrl from the recordings API
#   output_file  — Local path to save the MP4

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_usage() {
  echo "Usage: $0 <download_url> <output_file>" >&2
  exit 1
}

[ $# -eq 2 ] || show_usage

DOWNLOAD_URL="$1"
OUTPUT_FILE="$2"

TOKEN=$("$SCRIPT_DIR/auth.sh")

# IMPORTANT: Meet downloads require Zoho-oauthtoken, not Bearer
HTTP_CODE=$(curl -sL -w "%{http_code}" "$DOWNLOAD_URL" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -o "$OUTPUT_FILE")

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "ERROR: Download failed with HTTP $HTTP_CODE" >&2
  exit 1
fi

echo "$OUTPUT_FILE"
