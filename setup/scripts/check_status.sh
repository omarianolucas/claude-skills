#!/bin/bash
set -euo pipefail

# Checks the status of secrets.env and installed skills.
#
# Usage:
#   bash scripts/check_status.sh
#
# Outputs a summary of configured tokens and installed skills.

echo "=== Secrets ==="
if [ -f ~/.claude/secrets.env ]; then
  source ~/.claude/secrets.env
  [ -n "${ZOHO_CLIENT_ID:-}" ] && echo "Client ID: configurado" || echo "Client ID: FALTANDO"
  [ -n "${ZOHO_CLIENT_SECRET:-}" ] && echo "Client Secret: configurado" || echo "Client Secret: FALTANDO"
  [ -n "${ZOHO_ORG_ID:-}" ] && echo "Org ID: configurado" || echo "Org ID: FALTANDO"
  [ -n "${ZOHO_REFRESH_TOKEN_WORKDRIVE:-}" ] && echo "Token WorkDrive: configurado" || echo "Token WorkDrive: FALTANDO"
  [ -n "${ZOHO_REFRESH_TOKEN_WRITER:-}" ] && echo "Token Writer: configurado" || echo "Token Writer: FALTANDO"
  [ -n "${ZOHO_REFRESH_TOKEN_MEET:-}" ] && echo "Token Meet: configurado" || echo "Token Meet: FALTANDO"
else
  echo "secrets.env: NAO ENCONTRADO"
fi

echo ""
echo "=== Skills Instaladas ==="
if [ -d ~/.claude/skills ]; then
  for skill_dir in ~/.claude/skills/*/; do
    [ -f "$skill_dir/SKILL.md" ] || continue
    SKILL_NAME=$(basename "$skill_dir")
    VERSION=$(grep -m1 '^version:' "$skill_dir/SKILL.md" | sed 's/version: *//' || echo "?")
    echo "$SKILL_NAME v$VERSION"
  done
else
  echo "Nenhuma skill instalada"
fi
