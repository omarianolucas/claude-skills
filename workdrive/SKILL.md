---
name: workdrive
description: Manage files and folders in Zoho WorkDrive — create folders, list contents, move/copy/rename/trash/delete files, upload files, download files, search, and share links. Use this skill whenever the user wants to organize files in WorkDrive, check what's in a folder, upload or download something, create share links, or manage file structure. Also triggers on "workdrive", "criar pasta", "listar arquivos", "mover arquivo", "copiar arquivo", "upload", "subir arquivo", "baixar arquivo", "compartilhar link", "share link", "deletar arquivo". Do NOT use for creating formatted documents (that's /doc), case workflows (that's /case), transcriptions (that's /transcribe), or spreadsheet data operations (that's zoho-sheet).
version: 0.4.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /workdrive — Zoho WorkDrive Operations

Manage files and folders in Zoho WorkDrive via REST API and MCP tools.

---

## Decision Flow

```
User wants something in WorkDrive
    │
    ├─ Read-only (list, search, details, download)
    │     └─ Prefer MCP tools — they're simpler and don't need OAuth
    │
    ├─ Create folder / upload file / create native doc
    │     └─ Use REST API (MCP can also do these, but REST gives more control)
    │
    ├─ Move / rename / copy
    │     └─ Either MCP or REST works. MCP is simpler for single ops.
    │
    ├─ Share links (create, list, delete)
    │     └─ MCP tools available: createExternalShareLink, getFileShareLinks, deleteExternalShareLink
    │
    └─ Delete / trash
          └─ DANGEROUS — always confirm with user first
          └─ Prefer trash (soft delete, recoverable) over permanent delete
          └─ Never batch-delete without explicit confirmation
```

### MCP vs REST

There are MCP tools available for WorkDrive (prefixed `mcp__zoho-workdrive__` or `mcp__claude_ai_Workdrive__`). Use them when possible — they handle auth automatically and are simpler. Fall back to REST API when:
- The MCP tool doesn't exist for an operation
- You need finer control (query params, pagination)
- You need to chain multiple operations in a script

---

## Authentication (REST API only)

```bash
source ~/.claude/secrets.env

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$ZOHO_REFRESH_TOKEN_WORKDRIVE" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
```

Auth header: `Authorization: Bearer $TOKEN`

---

## REST API Operations

### Create folder
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/files" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"name":"FOLDER_NAME","parent_id":"PARENT_FOLDER_ID"},"type":"files"}}'
```
Returns `data.id` with the new folder_id.

### List folder contents
```bash
curl -s "https://www.zohoapis.com/workdrive/api/v1/files/FOLDER_ID/files" \
  -H "Authorization: Bearer $TOKEN"
```

### Get file/folder details
```bash
curl -s "https://www.zohoapis.com/workdrive/api/v1/files/RESOURCE_ID" \
  -H "Authorization: Bearer $TOKEN"
```
Returns metadata: name, type, size, created_time, modified_time, parent_id, permalink, etc.

### Download file
```bash
curl -s "https://www.zohoapis.com/workdrive/api/v1/download/FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -o /tmp/downloaded_file.ext
```

### Search files in a folder
```bash
curl -s "https://www.zohoapis.com/workdrive/api/v1/files/FOLDER_ID/files?filter[type]=all&filter[name]=SEARCH_TERM" \
  -H "Authorization: Bearer $TOKEN"
```

### Rename file/folder
```bash
curl -s -X PATCH "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"name":"NEW_NAME"},"type":"files"}}'
```

### Move file/folder
```bash
curl -s -X PATCH "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"parent_id":"DEST_FOLDER_ID"},"type":"files"}}'
```

### Copy file/folder
Use the MCP tool `ZohoWorkdrive_copyFileOrFolder` — there's no simple REST endpoint for copy. It takes `resource_id` (source) and `destination_parent_id`.

### Upload file (up to ~250MB)
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "content=@/path/to/file.pdf" \
  -F "parent_id=PARENT_FOLDER_ID" \
  -F "override-name-exist=true"
```
- `override-name-exist=true` overwrites if file with same name exists
- Returns `data[0].attributes.resource_id` and `Permalink`

### Upload large file (stream, >250MB)
```bash
curl -s -X POST "https://upload.zoho.com/workdrive-api/v1/stream/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-filename: large_file.zip" \
  -H "x-parent_id: PARENT_FOLDER_ID" \
  -H "upload-id: UNIQUE_UPLOAD_ID" \
  -H "x-streammode: 1" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @/path/to/large_file.zip
```

### Create native document (Writer/Sheet/Show)
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/files" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"name":"DOC_NAME","parent_id":"FOLDER_ID","service_type":"zw"},"type":"files"}}'
```
`service_type`: `zw` (Writer), `zohosheet` (Sheet), `zohoshow` (Show)

---

## Destructive Operations — Handle with Care

### Move to trash (soft delete, recoverable)
```bash
curl -s -X PATCH "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"status":"51"},"type":"files"}}'
```

### Delete permanently (irreversible)
```bash
curl -s -X DELETE "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN"
```

Always prefer trash over permanent delete. Permanent delete destroys the file and all its version history — there's no undo. Only use when the user explicitly asks for permanent deletion and confirms.

---

## Known IDs

These are frequently used folder IDs. Check if they're still valid before using — folders can be renamed or moved.

- Team ID: check with `ZohoWorkdrive_getAllTeamsOfUser`
- My Folders: check with `ZohoWorkdrive_getmyfolderid`
- Team folders: list with `ZohoWorkdrive_listAllTeamFoldersOfaTeam`
