---
name: meet
description: Use this skill for Zoho Meet operations — list/download recordings, create/manage meetings. Also used when user mentions "meeting", "gravacao", "recording", "reuniao".
version: 0.3.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /meet — Zoho Meet Operations

Gerenciar meetings e gravacoes no Zoho Meet via API REST.

---

## Scopes

```
ZohoMeeting.meetinguds.READ, ZohoFiles.files.READ, ZohoMeeting.recording.READ, ZohoMeeting.recording.DELETE, ZohoMeeting.meeting.READ, ZohoMeeting.meeting.CREATE, ZohoMeeting.meeting.UPDATE, ZohoMeeting.meeting.DELETE, ZohoMeeting.manageOrg.READ
```

Variavel no secrets.env: `ZOHO_REFRESH_TOKEN_MEET`

---

## OAuth2

```bash
source ~/.claude/secrets.env

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$ZOHO_REFRESH_TOKEN_MEET" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
```

---

## Operacoes

### Listar gravacoes
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/recordings.json" \
  -H "Authorization: Bearer $TOKEN"
```
Retorna array `recordings` com `meetingKey`, `erecordingId`, `downloadUrl`, `duration`, `topic`, etc.

### Pegar gravacao especifica
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/recordings/MEETING_KEY.json" \
  -H "Authorization: Bearer $TOKEN"
```

### Baixar MP4 da gravacao
```bash
curl -sL "DOWNLOAD_URL" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -o /tmp/meeting.mp4
```
Usar o `downloadUrl` retornado pela API. Auth com `Zoho-oauthtoken` (nao `Bearer`).

---

## Limitacoes

- Transcricao nativa do Zoho Meet eh muito ruim para pt-BR
- Download de arquivos usa auth `Zoho-oauthtoken` (nao `Bearer`)
- MP4s podem ser grandes (157MB pra 26min) — baixar em `/tmp/`
