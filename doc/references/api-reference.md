# Zoho Writer API Reference

## Authentication

The Writer API uses `Authorization: Zoho-oauthtoken $TOKEN` (not `Bearer`). Tokens expire in ~1 hour — always refresh at the start of an operation.

Use `scripts/auth.sh` to generate a fresh token:
```bash
TOKEN=$(bash scripts/auth.sh)
```

---

## Endpoints

### Download (read content)
```bash
bash scripts/download_doc.sh <doc_id> <format> <output_file>
```
Supported formats: `html`, `pdf`, `docx`, `odt`, `rtf`, `txt`, `epub`.

Raw curl equivalent:
```bash
curl -s "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID/download?format=html" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -o /tmp/documento.html
```

### Get metadata
```bash
curl -s "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID" \
  -H "Authorization: Zoho-oauthtoken $TOKEN"
```
Returns `document_id`, `document_name`, `open_url`, `created_time`, `last_modified_time`, etc.

### Create document
```bash
bash scripts/create_doc.sh <folder_id> <filename> <content_file>
```
Returns JSON with `document_id`, `open_url`, `document_name`.

Raw curl equivalent:
```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html" \
  -F "folder_id=WORKDRIVE_FOLDER_ID" \
  -F "filename=Nome do Documento"
```

### Update document (new version)
```bash
bash scripts/update_doc.sh <doc_id> <content_file>
```
Replaces the entire content but preserves the same doc_id and version history — this is why updating is always preferred over delete+recreate.

Raw curl equivalent:
```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html"
```

---

## Known Gotchas

- The `service` parameter in the create endpoint causes error R5012 — don't use it. Use `folder_id` directly.
- Merge fields (`<<field>>`, `${field}`) only work when inserted via Writer's UI — don't try to use them via API.
