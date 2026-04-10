---
name: meet
description: Use this skill for Zoho Meet operations — list/download recordings, download transcripts, create/manage meetings. Also used when user mentions "meeting", "gravacao", "recording", "reuniao".
version: 0.2.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /meet — Zoho Meet Operations

Operacoes no Zoho Meet via API REST. Gerencia gravacoes e meetings.

---

## OAuth2

Credenciais em `~/.claude/secrets.env` (ver skill `/workdrive` para template).

```bash
source ~/.claude/secrets.env

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$ZOHO_REFRESH_TOKEN_MEET" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
```

**Org ID:** `$ZOHO_ORG_ID` (default: `777191179`)

---

## Operacoes

### Listar gravacoes
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/777191179/recordings.json" \
  -H "Authorization: Bearer $TOKEN"
```
Retorna array `recordings` com `meetingKey`, `erecordingId`, `downloadUrl`, `duration`, `topic`, etc.

### Pegar gravacao especifica
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/777191179/recordings/MEETING_KEY.json" \
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

## Skills relacionadas

- `/transcribe` — transcrever o MP4 baixado com Whisper local
- `/doc` — criar doc de transcricao no Writer
- `/workdrive` — OAuth2 e operacoes de arquivo

---

## Limitacoes

- Transcricao nativa do Zoho Meet e muito ruim para pt-BR — usar skill `/transcribe`
- Download de arquivos usa auth `Zoho-oauthtoken` (nao `Bearer`)
- MP4s podem ser grandes (157MB pra 26min) — baixar em `/tmp/`
