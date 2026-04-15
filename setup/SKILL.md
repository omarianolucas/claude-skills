---
name: setup
description: Install skills, configure Zoho APIs (OAuth2), manage the skills ecosystem, and onboard new users. Use when user mentions "setup", "instalar skill", "configurar API", "onboarding", "atualizar skills", "listar skills", "status das skills", "configurar zoho", "self client", "refresh token", or needs help getting started with the tooling. Do NOT use for actual document creation (that's /doc), file management (that's /workdrive), or brand questions (that's /brand).
version: 0.2.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: [subcommand]
---

# Skill: /setup — Install Skills & Configure APIs

Entry point for new team members and management of installed skills.

**Repo:** github.com/omarianolucas/claude-skills

---

## Subcommands

### `/setup` (no args)
Full onboarding flow:

1. Check if `~/.claude/secrets.env` exists — if not, create from template
2. List available skills (see catalog below)
3. Ask which ones to install
4. Download chosen skills from GitHub to `~/.claude/skills/`
5. For each skill that needs an API (has Scopes section):
   a. Show required scopes
   b. Check if user already has a Self Client on Zoho
   c. If not: guide creation at console.zoho.com → Add Client → Self Client
   d. Ask for Client ID and Client Secret (save to secrets.env)
   e. Instruct to generate authorization code with listed scopes
   f. Ask for the generated code
   g. Exchange for refresh token:
      ```bash
      curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
        -d "code=USER_CODE" \
        -d "client_id=$ZOHO_CLIENT_ID" \
        -d "client_secret=$ZOHO_CLIENT_SECRET" \
        -d "grant_type=authorization_code"
      ```
   h. Save refresh token to secrets.env
   i. Test connection with a simple API call
6. Confirm everything works

### `/setup list`
List available skills.

1. Fetch repo contents via GitHub API:
   ```bash
   curl -s "https://api.github.com/repos/omarianolucas/claude-skills/contents/" | python3 -c "
   import sys,json
   for item in json.loads(sys.stdin.read()):
       if item['type'] == 'dir' and not item['name'].startswith(('_','.')):
           print(item['name'])
   "
   ```
2. For each skill, fetch SKILL.md frontmatter to show name and description
3. Mark which ones are already installed locally

### `/setup install [skill1] [skill2] ...`
Install specific skills.

1. For each skill:
   a. Check if already in `~/.claude/skills/`
   b. If not, download from GitHub:
      ```bash
      curl -sL "https://raw.githubusercontent.com/omarianolucas/claude-skills/main/SKILL_NAME/SKILL.md" \
        -o ~/.claude/skills/SKILL_NAME/SKILL.md --create-dirs
      # Also download subfolders (references/, scripts/, etc.) if they exist
      ```
   c. If skill has Scopes section, warn that API config is needed
2. List what was installed and what needs API config

### `/setup update`
Check and update installed skills.

1. For each skill in `~/.claude/skills/`:
   a. Read local version (frontmatter `version`)
   b. Fetch remote version via GitHub API
   c. If remote > local: download new version (including subfolders)
2. Show what was updated

### `/setup status`
Show current state.

1. List installed skills with version
2. Check if secrets.env exists and which tokens are configured
3. Test connection for each configured API

---

## Skills vs Plugins

There are two ways to add capabilities:

- **Skills** (`~/.claude/skills/`) — custom skills created by the team, managed via this /setup skill and the GitHub repo. These are specific to our workflows (Inbox brand, Zoho APIs, case management).
- **Plugins** (`~/.claude/plugins/`) — installed via `claude plugin install name@marketplace`. These are community/official plugins for general capabilities (LSP, code review, skill-creator, etc.).

This skill manages **custom skills only**. For plugins, use `claude plugin install/uninstall`.

---

## Skill Catalog

### Standalone skills
| Skill | Version | Description | Needs API? | Scopes |
|-------|---------|-------------|------------|--------|
| **brand** | 0.2.0 | Inbox brand colors, fonts, visual style | No | — |
| **workdrive** | 0.4.0 | File/folder management in Zoho WorkDrive | Yes | WorkDrive.files.ALL, WorkDrive.organization.ALL, WorkDrive.workspace.ALL |
| **doc** | 0.3.0 | Create/read/update Zoho Writer docs with Inbox brand style | Yes | ZohoWriter.documentEditor.ALL, ZohoWriter.merge.ALL, ZohoPC.files.ALL |
| **meet** | — | Zoho Meet recordings and meetings | Yes | ZohoMeeting.meetinguds.READ, ZohoFiles.files.READ, ZohoMeeting.recording.*, ZohoMeeting.meeting.*, ZohoMeeting.manageOrg.READ |
| **transcribe** | — | Local audio/video transcription with Whisper | No | — |

### Workflow skills (combine standalone skills)
| Skill | Description | Required deps | Optional deps |
|-------|-------------|---------------|---------------|
| **case** | Email Intelligence case management | workdrive, doc, brand | meet, transcribe |

---

## secrets.env

Located at `~/.claude/secrets.env`. Template:

```env
# Zoho OAuth2 — Client (shared across all APIs)
ZOHO_CLIENT_ID=
ZOHO_CLIENT_SECRET=
ZOHO_ORG_ID=

# Refresh tokens per skill (each with its own scopes)
ZOHO_REFRESH_TOKEN_WORKDRIVE=
ZOHO_REFRESH_TOKEN_WRITER=
ZOHO_REFRESH_TOKEN_MEET=
```

Note: WORKDRIVE and WRITER currently share the same refresh token (same Self Client with combined scopes). MEET has a separate token with its own scopes.

---

## Self Client Creation Guide

1. Go to console.zoho.com
2. Click "Add Client"
3. Choose "Self Client"
4. Note the **Client ID** and **Client Secret**
5. Click "Generate Code"
6. Paste required scopes (comma-separated)
7. Set duration to 10 minutes
8. Select the correct portal/org
9. Click "Create"
10. Copy the generated code and paste when /setup asks for it
