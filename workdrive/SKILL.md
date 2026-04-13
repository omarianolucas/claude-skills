---
name: workdrive
description: Use this skill for Zoho WorkDrive operations — create folders, list files, move/copy/trash/delete files, search, upload files. Also used when user mentions "workdrive", "criar pasta", "listar arquivos", "mover arquivo", "upload", "subir arquivo".
version: 0.3.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /workdrive — Zoho WorkDrive Operations

CRUD de pastas e arquivos no Zoho WorkDrive via API REST.

---

## Scopes

```
WorkDrive.files.ALL, WorkDrive.organization.ALL, WorkDrive.workspace.ALL
```

Variavel no secrets.env: `ZOHO_REFRESH_TOKEN_WORKDRIVE`

---

## OAuth2

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

## Operacoes

### Criar pasta
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/files" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"name":"NOME","parent_id":"PARENT_FOLDER_ID"},"type":"files"}}'
```
Retorna `data.id` com o folder_id criado.

### Listar arquivos de uma pasta
```bash
curl -s "https://www.zohoapis.com/workdrive/api/v1/files/FOLDER_ID/files" \
  -H "Authorization: Bearer $TOKEN"
```

### Renomear arquivo/pasta
```bash
curl -s -X PATCH "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"name":"NOVO_NOME"},"type":"files"}}'
```

### Mover arquivo/pasta
```bash
curl -s -X PATCH "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"parent_id":"DEST_FOLDER_ID"},"type":"files"}}'
```

### Mover para trash (soft delete)
```bash
curl -s -X PATCH "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"status":"51"},"type":"files"}}'
```

### Deletar permanentemente
```bash
curl -s -X DELETE "https://www.zohoapis.com/workdrive/api/v1/files/FILE_ID" \
  -H "Authorization: Bearer $TOKEN"
```

### Buscar arquivos
```bash
curl -s "https://www.zohoapis.com/workdrive/api/v1/files/FOLDER_ID/files?filter[type]=all&filter[name]=SEARCH_TERM" \
  -H "Authorization: Bearer $TOKEN"
```

### Criar doc nativo (Writer/Sheet/Show)
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/files" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data":{"attributes":{"name":"NOME","parent_id":"FOLDER_ID","service_type":"zw"},"type":"files"}}'
```
`service_type`: `zw` (Writer), `zohosheet` (Sheet), `zohoshow` (Show)

### Upload de arquivo (ate ~250MB)
```bash
curl -s -X POST "https://www.zohoapis.com/workdrive/api/v1/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "content=@/caminho/do/arquivo.pdf" \
  -F "parent_id=PARENT_FOLDER_ID" \
  -F "override-name-exist=true"
```
Parametros form-data:
- `content` (obrigatorio) — arquivo binario
- `parent_id` (obrigatorio) — ID da pasta destino
- `override-name-exist` (opcional) — `true` para sobrescrever se ja existir arquivo com mesmo nome

Response:
```json
{
  "data": [{
    "attributes": {
      "Permalink": "https://www.zohoapis.com/workdrive/file/{resource_id}",
      "parent_id": "PARENT_FOLDER_ID",
      "FileName": "arquivo.pdf",
      "resource_id": "RESOURCE_ID"
    },
    "type": "files"
  }]
}
```

### Upload de arquivo grande (stream, >250MB)
Endpoint diferente — usa `upload.zoho.com`:
```bash
curl -s -X POST "https://upload.zoho.com/workdrive-api/v1/stream/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-filename: arquivo_grande.zip" \
  -H "x-parent_id: PARENT_FOLDER_ID" \
  -H "upload-id: UPLOAD_ID_UNICO" \
  -H "x-streammode: 1" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @/caminho/do/arquivo_grande.zip
```
Headers obrigatorios:
- `x-filename` — nome do arquivo
- `x-parent_id` — ID da pasta destino
- `upload-id` — string unica para identificar o upload
- `x-streammode: 1` — ativa modo stream
- `Content-Type: application/octet-stream`

Response:
```json
{
  "data": [{
    "attributes": {
      "file_name": "arquivo_grande.zip",
      "parent_id": "PARENT_FOLDER_ID",
      "resource_id": "RESOURCE_ID"
    },
    "type": "API_UPLOAD"
  }],
  "status": "SUCCESS"
}
```

### Checar status de upload
```bash
curl -s "https://www.zohoapis.com/workdrive/uploadprogress?uploadid=upload_{ZohoUserID}_{upload-id}" \
  -H "Authorization: Bearer $TOKEN"
```
O `uploadid` segue o formato: `upload_{ZohoUserID}_{upload-id_usado_no_stream_upload}`
