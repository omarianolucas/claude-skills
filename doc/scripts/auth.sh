#!/bin/bash
set -euo pipefail

# Generates a fresh Zoho OAuth access token for the Writer API.
# Prints the token to stdout. Exits non-zero on failure.
#
# Usage:
#   TOKEN=$(bash scripts/auth.sh)
#   curl -H "Authorization: Zoho-oauthtoken $TOKEN" ...

source ~/.claude/secrets.env

RESPONSE=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$ZOHO_REFRESH_TOKEN_WRITER" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token")

TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "ERROR: Failed to obtain access token. Response: $RESPONSE" >&2
  exit 1
fi

echo "$TOKEN"
