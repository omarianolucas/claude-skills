---
name: meet
description: Manage Zoho Meet meetings and recordings — list/download recordings, create/schedule meetings, list past meetings, get participant info. Use when user mentions "meeting", "reunião", "reuniao", "gravação", "gravacao", "recording", "zoho meet", "agendar reunião", "baixar gravação", "participantes", "download recording". After downloading a recording, suggest /transcribe for transcription. Do NOT use for document creation (that's /doc), file management in WorkDrive (that's /workdrive), or transcription itself (that's /transcribe).
version: 0.5.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /meet — Zoho Meet Operations

Manage meetings and recordings in Zoho Meet via REST API.

---

## Decision Flow

```
User wants something with Meet
    │
    ├─ Recordings
    │     ├─ "List recordings" → list via API
    │     ├─ "Download recording" → use scripts/download_recording.sh
    │     └─ "Transcribe recording" → download first, then suggest /transcribe
    │
    ├─ Meetings
    │     ├─ "List meetings" → GET /sessions.json
    │     ├─ "Create/schedule meeting" → POST /sessions.json
    │     ├─ "Update meeting" → PUT /sessions/MEETING_KEY.json
    │     └─ "Delete meeting" → DELETE (confirm with user first)
    │
    └─ Participants
          └─ "Who attended?" → GET attendeereport.json
```

---

## API Operations

Use the scripts in `scripts/` for auth and downloads. See `references/api-reference.md` for all endpoints and curl examples.

```bash
# Authenticate
TOKEN=$(bash scripts/auth.sh)

# Download a recording (handles the Zoho-oauthtoken quirk automatically)
bash scripts/download_recording.sh <download_url> /tmp/meeting.mp4
```

---

## Known Limitations

- Zoho Meet's native transcription is very poor for pt-BR — always use /transcribe (Whisper) instead
- Download endpoint uses `Zoho-oauthtoken` auth, not Bearer (see `references/api-reference.md` for details)
- MP4s can be very large (~6MB/min) — always save to `/tmp/`
- Meeting timezone should default to `America/Sao_Paulo` unless user specifies otherwise
- Deleting recordings is irreversible — always confirm with user

---

## Usage Examples

```
/meet listar gravacoes recentes
/meet baixar gravacao da reuniao de ontem
/meet agendar reuniao amanha as 14h com joao@inbox.ac
/meet quem participou da reuniao de segunda?
/meet listar reunioes dessa semana
```

---

## Scripts

- `scripts/auth.sh` — Generate a fresh Zoho OAuth token for Meet
- `scripts/download_recording.sh` — Download a recording MP4 (handles auth quirk)

## References

- `references/api-reference.md` — Full REST API: recordings, meetings, participants, auth header quirk
