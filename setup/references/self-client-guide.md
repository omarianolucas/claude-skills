# Self Client Creation Guide

## Creating a Self Client

1. Go to https://api-console.zoho.com/
2. Click "Add Client"
3. Choose "Self Client"
4. Note the **Client ID** and **Client Secret**
5. Click "Generate Code"
6. Paste required scopes (comma-separated)
7. Set duration to 10 minutes
8. Select the correct portal/org
9. Click "Create"
10. Copy the generated code and paste when /setup asks for it

## Scopes by Service

### WorkDrive + Writer (single token, combined scopes)
```
WorkDrive.files.ALL,WorkDrive.organization.ALL,WorkDrive.workspace.ALL,ZohoWriter.documentEditor.ALL,ZohoWriter.merge.ALL,ZohoPC.files.ALL
```

### Meet (separate token)
```
ZohoMeeting.meetinguds.READ,ZohoFiles.files.READ,ZohoMeeting.recording.READ,ZohoMeeting.recording.DELETE,ZohoMeeting.meeting.READ,ZohoMeeting.meeting.CREATE,ZohoMeeting.meeting.UPDATE,ZohoMeeting.meeting.DELETE,ZohoMeeting.manageOrg.READ
```

## Exchanging Code for Refresh Token

Use `scripts/exchange_code.sh`:
```bash
REFRESH_TOKEN=$(bash scripts/exchange_code.sh <code>)
```

Note: WORKDRIVE and WRITER share the same refresh token. MEET has a separate token.

## secrets.env Template

Located at `~/.claude/secrets.env`:

```env
# Zoho OAuth2 — Client (shared across all APIs)
ZOHO_CLIENT_ID=
ZOHO_CLIENT_SECRET=
ZOHO_ORG_ID=

# Refresh tokens per service (each with its own scopes)
ZOHO_REFRESH_TOKEN_WORKDRIVE=
ZOHO_REFRESH_TOKEN_WRITER=
ZOHO_REFRESH_TOKEN_MEET=
```
