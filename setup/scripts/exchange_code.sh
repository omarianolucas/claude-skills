#!/bin/bash
set -euo pipefail

# Exchanges a Zoho Self Client authorization code for a refresh token.
#
# Usage:
#   bash scripts/exchange_code.sh <code>
#
# Requires ~/.claude/secrets.env with ZOHO_CLIENT_ID and ZOHO_CLIENT_SECRET.
# Prints the refresh token to stdout.

show_usage() {
  echo "Usage: $0 <authorization_code>" >&2
  exit 1
}

[ $# -eq 1 ] || show_usage

CODE="$1"
source ~/.claude/secrets.env

RESPONSE=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "code=$CODE" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=authorization_code")

REFRESH_TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('refresh_token',''))" 2>/dev/null)

if [ -z "$REFRESH_TOKEN" ]; then
  echo "ERROR: Failed to exchange code. Response: $RESPONSE" >&2
  exit 1
fi

echo "$REFRESH_TOKEN"
