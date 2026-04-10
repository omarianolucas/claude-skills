# Zoho Scopes por Skill

Referencia de manutencao. Mapa de escopos OAuth2 necessarios por skill.

## workdrive
```
WorkDrive.files.ALL, WorkDrive.organization.ALL, WorkDrive.workspace.ALL
```
Token: `ZOHO_REFRESH_TOKEN_WORKDRIVE`

## doc
```
ZohoWriter.documentEditor.ALL, ZohoWriter.merge.ALL, ZohoPC.files.ALL
```
Token: `ZOHO_REFRESH_TOKEN_WRITER`

## meet
```
ZohoMeeting.meetinguds.READ, ZohoFiles.files.READ, ZohoMeeting.recording.READ, ZohoMeeting.recording.DELETE, ZohoMeeting.meeting.READ, ZohoMeeting.meeting.CREATE, ZohoMeeting.meeting.UPDATE, ZohoMeeting.meeting.DELETE, ZohoMeeting.manageOrg.READ
```
Token: `ZOHO_REFRESH_TOKEN_MEET`

## Skills sem API propria
- **brand** — sem API
- **transcribe** — sem API (Whisper local)
- **case** — usa tokens de workdrive e doc
- **setup** — usa tokens das skills que configura
