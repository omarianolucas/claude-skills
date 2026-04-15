# Skill Catalog

## Standalone Skills

| Skill | Version | Description | Needs API? |
|-------|---------|-------------|------------|
| **brand** | 0.2.1 | Inbox brand colors, fonts, visual style | No |
| **workdrive** | 0.5.0 | File/folder management in Zoho WorkDrive | Yes (WorkDrive scopes) |
| **doc** | 0.4.0 | Create/read/update Zoho Writer docs with Inbox brand style | Yes (Writer scopes, same token as WorkDrive) |
| **meet** | 0.5.0 | Zoho Meet recordings and meetings | Yes (Meet scopes, separate token) |

## Workflow Skills

| Skill | Version | Description | Required deps | Optional deps |
|-------|---------|-------------|---------------|---------------|
| **case** | 0.7.0 | Email Intelligence case management | workdrive, doc, brand | meet |

## Repo

All skills are at: `github.com/omarianolucas/claude-skills`

Each skill folder contains:
- `SKILL.md` (required)
- `scripts/` (optional — reusable shell scripts)
- `references/` (optional — docs, guides, templates as markdown)
- `templates/` (optional — HTML templates for document generation)
