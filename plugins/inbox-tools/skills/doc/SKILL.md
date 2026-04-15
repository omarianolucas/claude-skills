---
name: doc
description: Create, read, update, or download Zoho Writer documents via REST API. Use this skill whenever the user wants to generate a formatted document — reports, one-pagers, case summaries, proposals, campaign analyses, executive summaries, or any polished HTML document stored in Zoho Writer/WorkDrive. Also triggers on "criar doc", "criar documento", "atualizar doc", "gerar relatório", "writer", "zoho writer", "one-pager", "formatar documento", "baixar doc", "download pdf do writer". Use this even when the user doesn't mention "Writer" explicitly — if they want to turn data or notes into a professional branded document in the cloud, this is the right skill. Do NOT use for file management (moving, copying, uploading raw files — that's workdrive), spreadsheet operations (that's zoho-sheet), transcriptions (that's transcribe), or case creation workflows (that's /case).
version: 0.3.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /doc — Zoho Writer Document Operations

Create, read, and update documents in Zoho Writer via REST API.

---

## Decision Flow

Before doing anything, figure out what the user needs:

```
User wants a document
    │
    ├─ "Create new doc" or "generate report/one-pager"
    │       │
    │       ├─ Does a doc with this name/purpose already exist in the target folder?
    │       │     YES → Read existing content, merge new data in, update the doc
    │       │     NO  → Create a new doc
    │       │
    │       └─ Did the user specify a folder?
    │             YES → Use that folder_id
    │             NO  → Ask, or use the project's default folder
    │
    ├─ "Update existing doc"
    │       │
    │       └─ ALWAYS read the current content first (download as HTML)
    │          Then merge new info with existing content — never overwrite blindly
    │          Then upload via the update endpoint
    │
    └─ "Read/download doc"
            └─ Use the download endpoint with the desired format
```

### Why this matters

Documents are often built incrementally — the user adds data over days or weeks. A blind overwrite destroys everything collected so far. Duplicates create confusion and break links. The merge-first approach protects existing work while adding new information.

---

## Authentication

```bash
source ~/.claude/secrets.env

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$ZOHO_REFRESH_TOKEN_WRITER" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
```

The Writer API uses `Authorization: Zoho-oauthtoken $TOKEN` (not `Bearer`). Tokens expire in ~1 hour — always refresh at the start of an operation.

---

## API Operations

### Download (read content)
```bash
curl -s "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID/download?format=html" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -o /tmp/documento.html
```
Supported formats: `html`, `pdf`, `docx`, `odt`, `rtf`, `txt`, `epub`.

### Get metadata
```bash
curl -s "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID" \
  -H "Authorization: Zoho-oauthtoken $TOKEN"
```
Returns `document_id`, `document_name`, `open_url`, `created_time`, `last_modified_time`, etc.

### Create document
```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html" \
  -F "folder_id=WORKDRIVE_FOLDER_ID" \
  -F "filename=Nome do Documento"
```
Returns `document_id`, `open_url`, `document_name`.

### Update document (new version)
```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html"
```
Replaces the entire content but preserves the same doc_id and version history — this is why updating is always preferred over delete+recreate.

---

## Generating HTML Content

Every document uses the Inbox brand style. The full style guide with copy-pasteable templates lives in `references/style-guide.md` — read it before generating any HTML.

Key principles:
- Save HTML to `/tmp/` before uploading via curl
- Zoho Writer doesn't inherit `font-family` from `<body>` — repeat `font-family: Poppins;` on every element (h1, h2, p, td, li, span, etc.)
- CSS gradients (`linear-gradient`) don't render in Writer — use solid `background-color`
- `<blockquote>` renders poorly in Writer — use `<p>` with `border-left` styling instead
- Merge fields (`<<field>>`, `${field}`) only work when inserted via Writer's UI — don't try to use them via API
- The `service` parameter in the create endpoint causes error R5012 — don't use it. Use `folder_id` directly.

---

## Checklist Before Creating a Doc

1. Check if a doc with this name/purpose already exists in the target folder (list files via WorkDrive API or search)
2. If it exists → download current HTML, merge new content, update
3. If it doesn't exist → generate HTML following the style guide, create new doc
4. After creating/updating, return the `open_url` to the user
