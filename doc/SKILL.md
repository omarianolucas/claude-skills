---
name: doc
description: Create, read, update, or download Zoho Writer documents via REST API. Use this skill whenever the user wants to generate a formatted document — reports, one-pagers, case summaries, proposals, campaign analyses, executive summaries, or any polished HTML document stored in Zoho Writer/WorkDrive. Also triggers on "criar doc", "criar documento", "atualizar doc", "gerar relatório", "writer", "zoho writer", "one-pager", "formatar documento", "baixar doc", "download pdf do writer". Use this even when the user doesn't mention "Writer" explicitly — if they want to turn data or notes into a professional branded document in the cloud, this is the right skill. Do NOT use for file management (moving, copying, uploading raw files — that's workdrive), spreadsheet operations (that's zoho-sheet), transcriptions (that's transcribe), or case creation workflows (that's /case).
version: 0.4.0
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

## API Operations

Use the scripts in `scripts/` for all API calls — they handle authentication automatically. See `references/api-reference.md` for full endpoint details and raw curl equivalents.

```bash
# Authenticate (used internally by other scripts)
TOKEN=$(bash scripts/auth.sh)

# Create a new document
bash scripts/create_doc.sh <folder_id> <filename> <content_file>

# Update an existing document
bash scripts/update_doc.sh <doc_id> <content_file>

# Download a document
bash scripts/download_doc.sh <doc_id> <format> <output_file>
```

The Writer API uses `Zoho-oauthtoken` (not `Bearer`). For metadata queries, see `references/api-reference.md`.

---

## Generating HTML Content

Every document uses the Inbox brand style. Read `references/style-guide.md` before generating any HTML — it has the full color palette, typography scale, and copy-pasteable templates.

Key principles:
- Save HTML to `/tmp/` before uploading
- Zoho Writer doesn't inherit `font-family` from `<body>` — repeat `font-family: Poppins;` on every element (h1, h2, p, td, li, span, etc.)
- CSS gradients (`linear-gradient`) don't render in Writer — use solid `background-color`
- `<blockquote>` renders poorly — use `<p>` with `border-left` styling instead

---

## Checklist

1. Check if a doc with this name/purpose already exists in the target folder (list files via WorkDrive API or search)
2. If it exists → download current HTML, merge new content, update
3. If it doesn't exist → generate HTML following the style guide, create new doc
4. After creating/updating, return the `open_url` to the user
5. Verify the doc opens correctly — confirm the link works and content rendered as expected

---

## Usage Examples

```
/doc criar relatorio mensal de vendas na pasta Relatorios
/doc atualizar o one-pager do case Acme Corp com os novos dados de ROI
/doc baixar o documento "Proposta Comercial" em PDF
/doc generate an executive summary from these meeting notes
```

---

## Scripts

- `scripts/auth.sh` — Generate a fresh Zoho OAuth token (used internally by other scripts)
- `scripts/create_doc.sh` — Create a new document in a WorkDrive folder
- `scripts/update_doc.sh` — Update an existing document preserving version history
- `scripts/download_doc.sh` — Download a document in any supported format

## References

- `references/style-guide.md` — Inbox brand colors, fonts, typography scale, and HTML templates
- `references/api-reference.md` — Zoho Writer REST API endpoints, parameters, and known gotchas
