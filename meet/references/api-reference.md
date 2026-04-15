# Zoho Meet API Reference

## Authentication

Use `scripts/auth.sh` to generate a token.

```bash
TOKEN=$(bash scripts/auth.sh)
```

### Auth header quirk

Zoho Meet uses **two different auth headers** depending on the endpoint:

| Operation | Auth header |
|-----------|-------------|
| API calls (list, create, update, delete) | `Authorization: Bearer $TOKEN` |
| File downloads (recording MP4) | `Authorization: Zoho-oauthtoken $TOKEN` |

This is a Zoho inconsistency — the download endpoint rejects Bearer and requires Zoho-oauthtoken. The `scripts/download_recording.sh` script handles this automatically.

---

## Recordings

### List all recordings
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/recordings.json" \
  -H "Authorization: Bearer $TOKEN"
```
Returns `recordings` array with `meetingKey`, `erecordingId`, `downloadUrl`, `duration`, `topic`, `startTime`.

### Get specific recording
```bash
curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/recordings/MEETING_KEY.json" \
  -H "Authorization: Bearer $TOKEN"
```

### Download recording (MP4)
```bash
bash scripts/download_recording.sh <download_url> <output_file>
```

MP4s can be large (~6MB/min, so a 30-min meeting is ~180MB). Always download to `/tmp/`.

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
  -d '{"session": {"topic": "NEW_TOPIC", "startTime": "2026-04-16T10:00:00-0300"}}'
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
