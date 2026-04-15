---
name: meet
description: Manage Zoho Meet meetings and recordings — list/download recordings, create/schedule meetings, list past meetings, get participant info. Use when user mentions "meeting", "reunião", "reuniao", "gravação", "gravacao", "recording", "zoho meet", "agendar reunião", "baixar gravação", "participantes", "download recording". After downloading a recording, suggest /transcribe for transcription. Do NOT use for document creation (that's /doc), file management in WorkDrive (that's /workdrive), or transcription itself (that's /transcribe).
version: 0.4.0
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
    │     ├─ "List recordings" → GET /recordings.json
    │     ├─ "Download recording" → GET downloadUrl with Zoho-oauthtoken
    │     └─ "Transcribe recording" → download first, then suggest /transcribe
    │
    ├─ Meetings
    │     ├─ "List meetings" → GET /sessions.json
    │     ├─ "Create/schedule meeting" → POST /sessions.json
    │     ├─ "Update meeting" → PUT /sessions/MEETING_KEY.json
    │     └─ "Delete meeting" → DELETE /sessions/MEETING_KEY.json
    │
    └─ Participants
          └─ "Who attended?" → GET /sessions/MEETING_KEY/attendeereport.json
```

---

## Authentication

```bash
source ~/.claude/secrets.env

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$ZOHO_REFRESH_TOKEN_MEET" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
```

### Auth header quirk

Zoho Meet uses **two different auth headers** depending on the endpoint:

| Operation | Auth header |
|-----------|-------------|
| API calls (list, create, update, delete) | `Authorization: Bearer $TOKEN` |
| File downloads (recording MP4) | `Authorization: Zoho-oauthtoken $TOKEN` |

This is a Zoho inconsistency — the download endpoint rejects Bearer and requires Zoho-oauthtoken. Always use the correct one.

---

## Recordings

### List all recordings
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/recordings.json" \
  -H "Authorization: Bearer $TOKEN"
```
Returns `recordings` array with `meetingKey`, `erecordingId`, `downloadUrl`, `duration`, `topic`, `startTime`, etc.

### Get specific recording
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/recordings/MEETING_KEY.json" \
  -H "Authorization: Bearer $TOKEN"
```

### Download recording (MP4)
```bash
curl -sL "DOWNLOAD_URL" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -o /tmp/meeting_MEETING_KEY.mp4
```
Use the `downloadUrl` from the recordings API. Note: uses `Zoho-oauthtoken`, not `Bearer`.

MP4s can be large (~6MB/min, so a 30-min meeting is ~180MB). Always download to `/tmp/`.

After downloading, suggest using `/transcribe` to transcribe the audio — Zoho Meet's native transcription is poor for pt-BR.

### Delete recording
```bash
curl -s -X DELETE "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/recordings/RECORDING_ID.json" \
  -H "Authorization: Bearer $TOKEN"
```
Confirm with user before deleting — recordings are not recoverable.

---

## Meetings

### List meetings
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/sessions.json" \
  -H "Authorization: Bearer $TOKEN"
```

### Create meeting
```bash
curl -s -X POST "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/sessions.json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session": {
      "topic": "MEETING_TOPIC",
      "startTime": "2026-04-15T14:00:00-0300",
      "duration": 60,
      "timezone": "America/Sao_Paulo",
      "participants": [
        {"email": "user@example.com"}
      ]
    }
  }'
```
- `startTime` in ISO 8601 with timezone offset
- `duration` in minutes
- `participants` array with email addresses

### Update meeting
```bash
curl -s -X PUT "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/sessions/MEETING_KEY.json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session": {
      "topic": "NEW_TOPIC",
      "startTime": "2026-04-16T10:00:00-0300"
    }
  }'
```

### Delete meeting
```bash
curl -s -X DELETE "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/sessions/MEETING_KEY.json" \
  -H "Authorization: Bearer $TOKEN"
```
Confirm with user before deleting.

---

## Participants

### Get attendee report
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/sessions/MEETING_KEY/attendeereport.json" \
  -H "Authorization: Bearer $TOKEN"
```
Returns participant names, emails, join/leave times, and duration.

---

## Known Limitations

- Zoho Meet's native transcription is very poor for pt-BR — always use /transcribe (Whisper) instead
- Download endpoint uses `Zoho-oauthtoken` auth (not Bearer)
- MP4s can be very large (~6MB/min) — always save to `/tmp/`
- Meeting timezone should default to `America/Sao_Paulo` unless user specifies otherwise
