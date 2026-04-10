# Inbox — Claude Code Skills

Skills para o Claude Code usadas pelo time da Inbox.

## Quick Start

1. **Instalar Claude Code** — [claude.com/claude-code](https://claude.com/claude-code)

2. **Clonar o repo**
   ```bash
   git clone https://github.com/omarianolucas/claude-skills.git ~/.claude/skills
   ```

3. **Abrir Claude Code e rodar**
   ```
   /setup
   ```

O `/setup` vai listar as skills disponiveis, instalar as que voce quiser e configurar as APIs necessarias.

## Skills Disponiveis

### Capacidades
| Skill | O que faz |
|-------|-----------|
| `/brand` | Cores, fontes e estilo visual da Inbox |
| `/workdrive` | Criar pastas, mover arquivos no Zoho WorkDrive |
| `/doc` | Criar e atualizar documentos no Zoho Writer |
| `/meet` | Baixar gravacoes do Zoho Meet |
| `/transcribe` | Transcrever audio/video com Whisper (local) |

### Workflows
| Skill | O que faz | Precisa de |
|-------|-----------|------------|
| `/case` | Gestao completa de case studies | workdrive, doc, brand |

## Atualizacoes

```
/setup update
```
