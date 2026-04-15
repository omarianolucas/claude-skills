---
name: setup
description: Install skills, configure Zoho APIs (OAuth2), manage the skills ecosystem, and onboard new users. Use when user mentions "setup", "instalar skill", "configurar API", "onboarding", "atualizar skills", "listar skills", "status das skills", "configurar zoho", "self client", "refresh token", "credenciais", "credentials", or needs help getting started with the tooling. Do NOT use for actual document creation (that's /doc), file management (that's /workdrive), or brand questions (that's /brand).
version: 0.3.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: [subcommand]
---

# Skill: /setup — Install Skills & Configure APIs

Entry point for new team members. Supports two environments:
- **Terminal** (CLI `claude`) — full setup: clone repo, install skills, configure APIs
- **Desktop app** (Claude Code baixado) — skills já instaladas via UI, foca em configurar credenciais

**Repo:** github.com/omarianolucas/claude-skills

---

## Detecção de Ambiente

Quando o usuario roda `/setup` sem argumentos, detectar automaticamente:

```bash
if [ -d ~/.claude/skills/.git ]; then
  # Repo git presente → Fluxo Terminal
else
  # Sem repo git → Fluxo Desktop (credenciais)
fi
```

O usuario pode forçar o fluxo:
- `/setup terminal` → fluxo completo (terminal)
- `/setup credenciais` → só configuração de tokens (desktop)

---

## Subcomandos

| Subcomando | Descrição |
|---|---|
| `/setup` | Detecta ambiente e roda o fluxo apropriado |
| `/setup credenciais` | Configurar credenciais Zoho (criar/atualizar secrets.env) |
| `/setup terminal` | Fluxo completo: clone + install + credenciais |
| `/setup list` | Listar skills disponíveis no GitHub |
| `/setup install [skills]` | Instalar skills específicas do GitHub |
| `/setup update` | Atualizar skills instaladas |
| `/setup status` | Mostrar estado: skills instaladas + tokens configurados |

---

## Fluxo Terminal (`/setup terminal` ou auto-detectado)

Full onboarding para quem usa Claude Code no terminal.

1. Check if `~/.claude/secrets.env` exists — if not, create from template
2. List available skills (see catalog below)
3. Ask which ones to install
4. Download chosen skills from GitHub to `~/.claude/skills/`
5. Run the credentials flow (same as `/setup credenciais`) for each skill that needs an API
6. Confirm everything works

### `/setup list`

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

1. For each skill:
   a. Check if already in `~/.claude/skills/`
   b. If not, download from GitHub:
      ```bash
      curl -sL "https://raw.githubusercontent.com/omarianolucas/claude-skills/main/SKILL_NAME/SKILL.md" \
        -o ~/.claude/skills/SKILL_NAME/SKILL.md --create-dirs
      # Also download subfolders (references/, scripts/, templates/) if they exist
      ```
   c. If skill has API scopes, warn that credential config is needed
2. List what was installed and what needs API config

### `/setup update`

1. For each skill in `~/.claude/skills/`:
   a. Read local version (frontmatter `version`)
   b. Fetch remote version via GitHub API
   c. If remote > local: download new version (including subfolders)
2. Show what was updated

---

## Fluxo Credenciais (`/setup credenciais` ou auto-detectado no desktop)

Guia interativo para configurar as credenciais Zoho. Funciona tanto no terminal quanto no desktop app.

### Passo 1 — Verificar secrets.env

```bash
if [ -f ~/.claude/secrets.env ]; then
  source ~/.claude/secrets.env
  # Mostrar quais tokens já estão configurados
else
  # Criar arquivo a partir do template
fi
```

Se o arquivo já existe, mostrar resumo:
- Client ID/Secret: configurado/faltando
- Token WorkDrive: configurado/faltando
- Token Writer: configurado/faltando
- Token Meet: configurado/faltando

### Passo 2 — Client ID e Secret

Se `ZOHO_CLIENT_ID` ou `ZOHO_CLIENT_SECRET` estão vazios:

1. Perguntar: "Você já tem um Self Client configurado no Zoho?"
2. Se **sim**: pedir Client ID e Client Secret
3. Se **não**: guiar a criação:
   - "Acesse https://api-console.zoho.com/"
   - "Clique em **Add Client** → **Self Client**"
   - "Copie o **Client ID** e o **Client Secret** que aparecerem"
   - Pedir os valores
4. Perguntar o Org ID (ZOHO_ORG_ID) — necessário para o /meet
5. Salvar no `secrets.env`:
   ```bash
   # Usar sed ou python para atualizar as linhas no arquivo
   ```

### Passo 3 — Tokens por skill

Para cada skill com API, perguntar se o usuario vai usar e configurar:

#### WorkDrive + Writer (compartilham o mesmo token)

Scopes necessários (gerar UM código com todos):
```
WorkDrive.files.ALL,WorkDrive.organization.ALL,WorkDrive.workspace.ALL,ZohoWriter.documentEditor.ALL,ZohoWriter.merge.ALL,ZohoPC.files.ALL
```

1. Perguntar: "Você vai usar /workdrive e /doc? (gerenciar arquivos e criar documentos)"
2. Se sim:
   a. "No console.zoho.com, no seu Self Client, clique em **Generate Code**"
   b. "Cole esses scopes:" → mostrar os scopes acima
   c. "Selecione **10 minutes** como duração"
   d. "Selecione o portal/org correto"
   e. "Clique **Create** e cole o código gerado aqui"
   f. Receber o código e trocar por refresh token:
      ```bash
      source ~/.claude/secrets.env
      RESPONSE=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
        -d "code=USER_CODE" \
        -d "client_id=$ZOHO_CLIENT_ID" \
        -d "client_secret=$ZOHO_CLIENT_SECRET" \
        -d "grant_type=authorization_code")
      REFRESH_TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['refresh_token'])")
      ```
   g. Salvar como `ZOHO_REFRESH_TOKEN_WORKDRIVE` e `ZOHO_REFRESH_TOKEN_WRITER` (mesmo token)
   h. Testar conexão:
      ```bash
      # Testar WorkDrive
      TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
        -d "refresh_token=$REFRESH_TOKEN" \
        -d "client_id=$ZOHO_CLIENT_ID" \
        -d "client_secret=$ZOHO_CLIENT_SECRET" \
        -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
      curl -s "https://www.zohoapis.com/workdrive/api/v1/users/me" \
        -H "Authorization: Bearer $TOKEN" | python3 -c "
      import sys,json
      r = json.loads(sys.stdin.read())
      name = r.get('data',{}).get('attributes',{}).get('display_name','')
      print(f'WorkDrive OK — conectado como: {name}')
      "
      ```

#### Meet (token separado)

Scopes necessários:
```
ZohoMeeting.meetinguds.READ,ZohoFiles.files.READ,ZohoMeeting.recording.READ,ZohoMeeting.recording.DELETE,ZohoMeeting.meeting.READ,ZohoMeeting.meeting.CREATE,ZohoMeeting.meeting.UPDATE,ZohoMeeting.meeting.DELETE,ZohoMeeting.manageOrg.READ
```

1. Perguntar: "Você vai usar /meet? (gravações e reuniões)"
2. Se sim: mesmo fluxo de gerar código + trocar por token
3. Salvar como `ZOHO_REFRESH_TOKEN_MEET`
4. Testar conexão:
   ```bash
   curl -s "https://meeting.zoho.com/meeting/api/v2/$ZOHO_ORG_ID/sessions.json" \
     -H "Authorization: Bearer $TOKEN" | python3 -c "
   import sys,json
   r = json.loads(sys.stdin.read())
   print(f'Meet OK — {len(r.get(\"sessions\",[]))} reuniões encontradas')
   "
   ```

### Passo 4 — Resumo

Mostrar resumo final:
```
✅ Configuração concluída!

Client ID/Secret: ✅ configurado
WorkDrive: ✅ funcionando (conectado como Lucas)
Writer: ✅ funcionando (mesmo token do WorkDrive)
Meet: ✅ funcionando (3 reuniões encontradas)

Arquivo: ~/.claude/secrets.env
```

---

## `/setup status`

1. List installed skills with version
2. Check if secrets.env exists and which tokens are configured
3. Test connection for each configured API
4. Show summary table

---

## Skills vs Plugins

- **Skills** (`~/.claude/skills/`) — custom skills do time Inbox, gerenciadas via /setup (terminal) ou instaladas via .skill files (desktop)
- **Plugins** (`~/.claude/plugins/`) — plugins oficiais/community via `claude plugin install`

---

## Skill Catalog

### Standalone skills
| Skill | Version | Description | Needs API? | Scopes |
|-------|---------|-------------|------------|--------|
| **brand** | 0.2.0 | Inbox brand colors, fonts, visual style | No | — |
| **workdrive** | 0.4.0 | File/folder management in Zoho WorkDrive | Yes | WorkDrive.files.ALL, WorkDrive.organization.ALL, WorkDrive.workspace.ALL |
| **doc** | 0.3.0 | Create/read/update Zoho Writer docs with Inbox brand style | Yes | ZohoWriter.documentEditor.ALL, ZohoWriter.merge.ALL, ZohoPC.files.ALL |
| **meet** | 0.4.0 | Zoho Meet recordings and meetings | Yes | ZohoMeeting.meetinguds.READ, ZohoFiles.files.READ, ZohoMeeting.recording.*, ZohoMeeting.meeting.*, ZohoMeeting.manageOrg.READ |

### Workflow skills (combine standalone skills)
| Skill | Description | Required deps | Optional deps |
|-------|-------------|---------------|---------------|
| **case** | Email Intelligence case management | workdrive, doc, brand | meet |

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

1. Go to https://api-console.zoho.com/
2. Click "Add Client"
3. Choose "Self Client"
4. Note the **Client ID** and **Client Secret**
5. Click "Generate Code"
6. Paste required scopes (comma-separated)
7. Set duration to 10 minutes
8. Select the correct portal/org
9. Click "Create"
10. Copy the generated code and paste when /setup asks for it
