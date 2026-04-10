# OAuth2 Zoho — Receita Canonica

Referencia de manutencao. Se mudar o fluxo OAuth2, atualizar aqui e propagar pras skills.

## Refresh Token → Access Token

```bash
source ~/.claude/secrets.env

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$REFRESH_TOKEN_VAR" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
```

## Authorization Code → Refresh Token

```bash
curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "code=AUTHORIZATION_CODE" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=authorization_code"
```

## Auth Headers

- **WorkDrive:** `Authorization: Bearer $TOKEN`
- **Writer:** `Authorization: Zoho-oauthtoken $TOKEN`
- **Meet (API):** `Authorization: Bearer $TOKEN`
- **Meet (download):** `Authorization: Zoho-oauthtoken $TOKEN`
