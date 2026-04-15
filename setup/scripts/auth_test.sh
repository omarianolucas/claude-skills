#!/bin/bash
set -euo pipefail

# Tests a Zoho OAuth refresh token by generating an access token and hitting a test endpoint.
#
# Usage:
#   bash scripts/auth_test.sh <service>
#
# Services:
#   workdrive — tests WorkDrive API (GET /users/me)
#   meet      — tests Meet API (GET /sessions.json)
#
# Requires ~/.claude/secrets.env with ZOHO_CLIENT_ID, ZOHO_CLIENT_SECRET,
# and the corresponding ZOHO_REFRESH_TOKEN_* variable.

show_usage() {
  echo "Usage: $0 <service>" >&2
  echo "Services: workdrive, meet" >&2
  exit 1
}

[ $# -eq 1 ] || show_usage

SERVICE="$1"
source ~/.claude/secrets.env

case "$SERVICE" in
  workdrive)
    REFRESH_TOKEN="$ZOHO_REFRESH_TOKEN_WORKDRIVE"
    ;;
  meet)
    REFRESH_TOKEN="$ZOHO_REFRESH_TOKEN_MEET"
    ;;
  *)
    echo "ERROR: Unknown service '$SERVICE'. Use: workdrive, meet" >&2
    exit 1
    ;;
esac

if [ -z "$REFRESH_TOKEN" ]; then
  echo "ERROR: Refresh token for $SERVICE is empty" >&2
  exit 1
fi

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "FAIL: Could not generate access token for $SERVICE" >&2
  exit 1
fi

case "$SERVICE" in
  workdrive)
    RESULT=$(curl -s "https://www.zohoapis.com/workdrive/api/v1/users/me" \
      -H "Authorization: Bearer $TOKEN")
    NAME=$(echo "$RESULT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('data',{}).get('attributes',{}).get('display_name','unknown'))" 2>/dev/null)
    echo "WorkDrive OK — conectado como: $NAME"
    ;;
  meet)
    RESULT=$(curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/sessions.json" \
      -H "Authorization: Bearer $TOKEN")
    COUNT=$(echo "$RESULT" | python3 -c "import sys,json; print(len(json.loads(sys.stdin.read()).get('sessions',[])))" 2>/dev/null)
    echo "Meet OK — $COUNT reunioes encontradas"
    ;;
esac
