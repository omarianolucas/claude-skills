#!/bin/bash
set -euo pipefail

# Downloads a Zoho Writer document in the specified format.
#
# Usage:
#   bash scripts/download_doc.sh <doc_id> <format> <output_file>
#
# Arguments:
#   doc_id      — Zoho Writer document ID
#   format      — Output format: html, pdf, docx, odt, rtf, txt, epub
#   output_file — Local path to save the downloaded file

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_usage() {
  echo "Usage: $0 <doc_id> <format> <output_file>" >&2
  echo "Formats: html, pdf, docx, odt, rtf, txt, epub" >&2
  exit 1
}

[ $# -eq 3 ] || show_usage

DOC_ID="$1"
FORMAT="$2"
OUTPUT_FILE="$3"

TOKEN=$("$SCRIPT_DIR/auth.sh")

HTTP_CODE=$(curl -s -w "%{http_code}" \
  "https://www.zohoapis.com/writer/api/v1/documents/$DOC_ID/download?format=$FORMAT" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -o "$OUTPUT_FILE")

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "ERROR: Download failed with HTTP $HTTP_CODE" >&2
  exit 1
fi

echo "$OUTPUT_FILE"
