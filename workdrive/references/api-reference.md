# WorkDrive REST API Reference

## Authentication

Use `scripts/auth.sh` to generate a token. Auth header: `Authorization: Bearer $TOKEN`.

```bash
TOKEN=$(bash scripts/auth.sh)
```

---

## File & Folder Operations

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
Returns metadata: name, type, size, created_time, modified_time, parent_id, permalink.

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

---

## Upload

### Standard upload (up to ~250MB)
```bash
bash scripts/upload.sh <parent_folder_id> <file_path> [--overwrite]
```

Raw curl equivalent:
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "content=@/path/to/file.pdf" \
  -F "parent_id=PARENT_FOLDER_ID" \
  -F "override-name-exist=true"
```
- `override-name-exist=true` overwrites if file with same name exists
- Returns `data[0].attributes.resource_id` and `Permalink`

### Stream upload (>250MB)
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

---

## Download

```bash
bash scripts/download.sh <file_id> <output_path>
```

---

## Native Documents

### Create native document (Writer/Sheet/Show)
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/files" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"name":"DOC_NAME","parent_id":"FOLDER_ID","service_type":"zw"},"type":"files"}}'
```
`service_type`: `zw` (Writer), `zohosheet` (Sheet), `zohoshow` (Show).

---

## Destructive Operations

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

Always prefer trash over permanent delete. Permanent delete destroys the file and all version history — no undo.
