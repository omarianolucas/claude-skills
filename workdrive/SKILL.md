---
name: workdrive
description: Use this skill for any Zoho WorkDrive operation — create folders, list files, move/copy/trash files, search, get file details. Also handles OAuth2 token refresh for all Zoho APIs.
version: 0.1.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /workdrive — Zoho WorkDrive Operations

Operacoes no Zoho WorkDrive via API REST. Tambem gerencia OAuth2 para todas as APIs Zoho (Writer, Sheet, WorkDrive).

---

## OAuth2

Credenciais salvas em memoria (`zoho_oauth2.md`). Sempre renovar o access token no inicio de cada operacao.

```bash
TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=<REFRESH_TOKEN>" \
  -d "client_id=<CLIENT_ID>" \
  -d "client_secret=<CLIENT_SECRET>" \
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

---

## IDs conhecidos

### Team Folder: Success
- Team ID: `qn8bbaab53b29144a4ea497dc029575a4c3d4`
- Library ID: `l0dnwfd181094cb5f4ac7a2c5dc8edc824cfb`
- Dominio: `workdrive.inbox.ac`

### Pasta Email Intelligence
- Root: `e6ecq456d877840c142f6a133a4bb4847f339`
  - cases/: `e6ecq49cce46733684c5a8ccff21b24cb8812`
  - ab-tests/: `e6ecq851e5c6cc0304833a3563c12f3128683`
