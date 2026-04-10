---
name: setup
description: Use this skill to install skills, configure APIs, and manage the skills ecosystem. Also used when user mentions "setup", "instalar skill", "configurar API", "onboarding", "atualizar skills".
version: 0.1.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: [subcommand]
---

# Skill: /setup — Instalar Skills e Configurar APIs

Ponto de entrada para novos membros do time e gestao das skills instaladas.

**Repo:** github.com/omarianolucas/claude-skills

---

## Subcomandos

### `/setup` (sem argumentos)
Fluxo completo de onboarding.

1. Verificar se `~/.claude/secrets.env` existe. Se nao, criar a partir do template.
2. Listar skills disponiveis no repo (ver catalogo abaixo)
3. Perguntar quais o usuario quer instalar
4. Baixar as skills escolhidas do GitHub pra `~/.claude/skills/`
5. Para cada skill que precisa de API (tem secao Scopes):
   a. Mostrar os escopos necessarios
   b. Perguntar se o usuario ja tem um Self Client no Zoho
   c. Se nao: guiar criacao em console.zoho.com → Add Client → Self Client
   d. Pedir Client ID e Client Secret (salvar no secrets.env)
   e. Instruir a gerar authorization code com os escopos listados
   f. Pedir o code gerado
   g. Trocar pelo refresh token via API:
      ```bash
      curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
        -d "code=CODE_DO_USUARIO" \
        -d "client_id=$ZOHO_CLIENT_ID" \
        -d "client_secret=$ZOHO_CLIENT_SECRET" \
        -d "grant_type=authorization_code"
      ```
   h. Salvar refresh token no secrets.env na variavel correta
   i. Testar a conexao fazendo uma chamada simples
6. Confirmar que tudo esta funcionando

### `/setup list`
Listar skills disponiveis no repo.

1. Buscar pastas no repo via GitHub API:
   ```bash
   curl -s "https://api.github.com/repos/omarianolucas/claude-skills/contents/" | python3 -c "
   import sys,json
   for item in json.loads(sys.stdin.read()):
       if item['type'] == 'dir' and not item['name'].startswith(('_','.')) :
           print(item['name'])
   "
   ```
2. Para cada skill, buscar o frontmatter do SKILL.md pra mostrar nome e descricao
3. Marcar quais ja estao instaladas localmente

### `/setup install [skill1] [skill2] ...`
Instalar skills especificas.

1. Para cada skill solicitada:
   a. Verificar se ja esta instalada em `~/.claude/skills/`
   b. Se nao, baixar do GitHub:
      ```bash
      # Baixar SKILL.md
      curl -sL "https://raw.githubusercontent.com/omarianolucas/claude-skills/main/SKILL_NAME/SKILL.md" \
        -o ~/.claude/skills/SKILL_NAME/SKILL.md --create-dirs

      # Se tiver subpastas (templates, references), baixar tambem
      ```
   c. Se a skill tem secao Scopes, avisar que precisa configurar API
2. Listar o que foi instalado e o que falta configurar

### `/setup update`
Checar e atualizar skills instaladas.

1. Para cada skill em `~/.claude/skills/`:
   a. Ler a versao local (frontmatter `version`)
   b. Buscar a versao no repo via GitHub API
   c. Se versao remota > local: baixar a nova versao
   d. Se tem subpastas (templates, references): atualizar tambem
2. Mostrar o que foi atualizado

### `/setup status`
Mostrar estado atual.

1. Listar skills instaladas com versao
2. Verificar se secrets.env existe e quais tokens estao configurados
3. Testar conexao de cada API configurada

---

## Catalogo de Skills

### Capacidades (independentes)
| Skill | Descricao | Precisa API? | Scopes |
|-------|-----------|-------------|--------|
| **brand** | Cores, fontes e estilo visual da Inbox | Nao | — |
| **workdrive** | CRUD de pastas/arquivos no Zoho WorkDrive | Sim | WorkDrive.files.ALL, WorkDrive.organization.ALL, WorkDrive.workspace.ALL |
| **doc** | Criar/atualizar docs no Zoho Writer | Sim | ZohoWriter.documentEditor.ALL, ZohoWriter.merge.ALL, ZohoPC.files.ALL |
| **meet** | Gravacoes e meetings do Zoho Meet | Sim | ZohoMeeting.meetinguds.READ, ZohoFiles.files.READ, ZohoMeeting.recording.READ, ZohoMeeting.recording.DELETE, ZohoMeeting.meeting.READ, ZohoMeeting.meeting.CREATE, ZohoMeeting.meeting.UPDATE, ZohoMeeting.meeting.DELETE, ZohoMeeting.manageOrg.READ |
| **transcribe** | Transcricao local com Whisper | Nao | — |

### Workflows (combinam capacidades)
| Skill | Descricao | Deps obrigatorias | Deps opcionais |
|-------|-----------|-------------------|----------------|
| **case** | Gestao de cases Email Intelligence | workdrive, doc, brand | meet, transcribe |

---

## secrets.env

Localizado em `~/.claude/secrets.env`. Template:

```env
# Zoho OAuth2 — Client (compartilhado entre todas as APIs)
ZOHO_CLIENT_ID=
ZOHO_CLIENT_SECRET=
ZOHO_ORG_ID=

# Tokens por skill (cada um com seus escopos)
ZOHO_REFRESH_TOKEN_WORKDRIVE=
ZOHO_REFRESH_TOKEN_WRITER=
ZOHO_REFRESH_TOKEN_MEET=
```

Cada token e gerado independentemente com os escopos da skill correspondente.

---

## Guia de criacao do Self Client Zoho

1. Acesse console.zoho.com
2. Clique em "Add Client"
3. Escolha "Self Client"
4. Anote o **Client ID** e **Client Secret**
5. Clique em "Generate Code"
6. Cole os escopos necessarios (separados por virgula)
7. Selecione duracao de 10 minutos
8. Selecione o portal/org correto
9. Clique em "Create"
10. Copie o code gerado e cole quando o /setup pedir
