---
name: workdrive
description: Use this skill for Zoho WorkDrive operations — create folders, list files, move/copy/trash/delete files, search. Also used when user mentions "workdrive", "criar pasta", "listar arquivos", "mover arquivo".
version: 0.2.0
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
