---
name: workdrive
description: Manage files and folders in Zoho WorkDrive — create folders, list contents, move/copy/rename/trash/delete files, upload files, download files, search, and share links. Use this skill whenever the user wants to organize files in WorkDrive, check what's in a folder, upload or download something, create share links, or manage file structure. Also triggers on "workdrive", "criar pasta", "listar arquivos", "mover arquivo", "copiar arquivo", "upload", "subir arquivo", "baixar arquivo", "compartilhar link", "share link", "deletar arquivo". Do NOT use for creating formatted documents (that's /doc), case workflows (that's /case), transcriptions (that's /transcribe), or spreadsheet data operations (that's zoho-sheet).
version: 0.5.0
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
    │     └─ MCP tools: createExternalShareLink, getFileShareLinks, deleteExternalShareLink
    │
    └─ Delete / trash
          └─ DANGEROUS — always confirm with user first
          └─ Prefer trash (soft delete, recoverable) over permanent delete
          └─ Never batch-delete without explicit confirmation
```

### MCP vs REST

MCP tools are available for WorkDrive (prefixed `ZohoWorkdrive_`). Use them when possible — they handle auth automatically. Fall back to REST API when:
- The MCP tool doesn't exist for an operation
- You need finer control (query params, pagination)
- You need to chain multiple operations in a script

---

## API Operations

For REST API calls, use the scripts in `scripts/` — they handle authentication automatically. See `references/api-reference.md` for full endpoint details and raw curl equivalents.

```bash
# Authenticate (used internally by other scripts)
TOKEN=$(bash scripts/auth.sh)

# Upload a file
bash scripts/upload.sh <parent_folder_id> <file_path> [--overwrite]

# Download a file
bash scripts/download.sh <file_id> <output_path>
```

Auth header for REST: `Authorization: Bearer $TOKEN`.

For create folder, rename, move, search, trash, and delete — see `references/api-reference.md`.

---

## Destructive Operations — Handle with Care

Always prefer trash over permanent delete. Permanent delete destroys the file and all version history — no undo. Only use when the user explicitly asks and confirms.

---

## Known IDs

These are frequently used folder IDs. Check if they're still valid before using — folders can be renamed or moved.

- Team ID: check with `ZohoWorkdrive_getAllTeamsOfUser`
- My Folders: check with `ZohoWorkdrive_getmyfolderid`
- Team folders: list with `ZohoWorkdrive_listAllTeamFoldersOfaTeam`

---

## Usage Examples

```
/workdrive listar arquivos na pasta Cases
/workdrive criar pasta "Novo Cliente" dentro de Cases
/workdrive upload ~/Desktop/relatorio.pdf pra pasta do cliente Acme
/workdrive baixar o arquivo "Proposta.pdf" pra /tmp/
/workdrive mover "Arquivo.docx" da pasta Temp pra pasta Final
/workdrive criar share link do arquivo "Apresentacao.pptx"
```

---

## Scripts

- `scripts/auth.sh` — Generate a fresh Zoho OAuth token for WorkDrive
- `scripts/upload.sh` — Upload a file to a WorkDrive folder (up to ~250MB)
- `scripts/download.sh` — Download a file from WorkDrive

## References

- `references/api-reference.md` — Full REST API endpoints: create folder, list, search, rename, move, copy, upload, download, trash, delete, native docs
