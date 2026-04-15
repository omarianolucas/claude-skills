---
name: setup
description: Install skills, configure Zoho APIs (OAuth2), manage the skills ecosystem, and onboard new users. Use when user mentions "setup", "instalar skill", "configurar API", "onboarding", "atualizar skills", "listar skills", "status das skills", "configurar zoho", "self client", "refresh token", "credenciais", "credentials", or needs help getting started with the tooling. Do NOT use for actual document creation (that's /doc), file management (that's /workdrive), or brand questions (that's /brand).
version: 0.4.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: [subcommand]
---

# Skill: /setup — Install Skills & Configure APIs

Entry point for new team members. Supports two environments:
- **Terminal** (CLI `claude`) — full setup: clone repo, install skills, configure APIs
- **Desktop app** (Claude Code) — skills already installed via UI, focus on configuring credentials

**Repo:** github.com/omarianolucas/claude-skills

---

## Environment Detection

When the user runs `/setup` without arguments, detect automatically:

```bash
if [ -d ~/.claude/skills/.git ]; then
  # Git repo present → Terminal flow
else
  # No git repo → Desktop flow (credentials only)
fi
```

The user can force a flow: `/setup terminal`, `/setup credenciais`.

---

## Subcommands

| Subcommand | Description |
|---|---|
| `/setup` | Detect environment and run the appropriate flow |
| `/setup credenciais` | Configure Zoho credentials (create/update secrets.env) |
| `/setup terminal` | Full flow: clone + install + credentials |
| `/setup list` | List available skills from GitHub |
| `/setup install [skills]` | Install specific skills from GitHub |
| `/setup update` | Update installed skills to latest version |
| `/setup status` | Show state: installed skills + configured tokens |

---

## Terminal Flow (`/setup terminal`)

1. Check if `~/.claude/secrets.env` exists — if not, create from template (see `references/self-client-guide.md`)
2. List available skills (see `references/skill-catalog.md`)
3. Ask which ones to install
4. Download chosen skills from GitHub to `~/.claude/skills/`
5. Run the credentials flow for each skill that needs an API
6. Run `bash scripts/check_status.sh` to confirm everything works

### `/setup list`

Fetch repo contents via GitHub API, show each skill with name/version/description. Mark which ones are already installed locally. See `references/skill-catalog.md` for the full catalog.

### `/setup install [skill1] [skill2] ...`

For each skill: check if already in `~/.claude/skills/`, if not download from GitHub (SKILL.md + subfolders). Warn if skill has API scopes that need configuration.

### `/setup update`

For each skill in `~/.claude/skills/`: compare local version (frontmatter) with remote version via GitHub API. Download new version if remote > local.

---

## Credentials Flow (`/setup credenciais`)

Interactive guide to configure Zoho credentials. See `references/self-client-guide.md` for the full Self Client creation guide, scopes, and secrets.env template.

### Step 1 — Check secrets.env

Run `bash scripts/check_status.sh` to see what's already configured.

### Step 2 — Client ID and Secret

If missing, guide the user through Self Client creation (see `references/self-client-guide.md`). Ask for the Org ID (ZOHO_ORG_ID) — needed for /meet.

### Step 3 — Tokens per service

For each service the user wants:

**WorkDrive + Writer** (shared token): ask user to generate code with combined scopes, then exchange:
```bash
REFRESH_TOKEN=$(bash scripts/exchange_code.sh <code>)
```
Save as both `ZOHO_REFRESH_TOKEN_WORKDRIVE` and `ZOHO_REFRESH_TOKEN_WRITER` in secrets.env.

**Meet** (separate token): same flow with Meet scopes. Save as `ZOHO_REFRESH_TOKEN_MEET`.

### Step 4 — Test connections

```bash
bash scripts/auth_test.sh workdrive
bash scripts/auth_test.sh meet
```

### Step 5 — Summary

Show final status: what's configured, what's working, file location (`~/.claude/secrets.env`).

---

## `/setup status`

Run `bash scripts/check_status.sh` then test each configured API with `bash scripts/auth_test.sh <service>`.

---

## Usage Examples

```
/setup
/setup credenciais
/setup terminal
/setup install doc workdrive case
/setup status
/setup update
```

---

## Scripts

- `scripts/auth_test.sh` — Test a Zoho OAuth token by hitting a service endpoint
- `scripts/exchange_code.sh` — Exchange a Self Client authorization code for a refresh token
- `scripts/check_status.sh` — Check installed skills and configured secrets

## References

- `references/self-client-guide.md` — Step-by-step Self Client creation, scopes per service, secrets.env template
- `references/skill-catalog.md` — Available skills with versions, descriptions, and dependencies
