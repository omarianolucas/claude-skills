---
name: case
description: Manage Email Intelligence case studies — create cases, fill data, check status, analyze proof strength, generate one-pagers, rank cases, check claim coverage. Use when user mentions "case", "caso", "case study", "criar case", "case novo", "preencher case", "status do case", "analisar case", "one-pager", "ranking de cases", "claims", "evidencia", "depoimento", "proof checklist", "hormozi". This is a workflow skill that orchestrates /doc, /workdrive, and /brand. Do NOT use for generic document creation (that's /doc), file management (that's /workdrive), or meeting operations (that's /meet).
version: 0.7.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Agent, Skill]
argument-hint: <subcommand> [cliente]
---

# Skill: /case — Gestao de Cases do Email Intelligence

Workflow que orquestra o ciclo completo de cases: criacao de pasta, documentos branded, preenchimento, analise e ranking.

---

## Dependencias

### Obrigatorias
Antes de executar qualquer subcomando, verificar se existem em `~/.claude/skills/`:
- `/workdrive` — criar pastas, listar arquivos, upload, download
- `/doc` — criar/ler/atualizar documentos no Writer
- `/brand` — cores, fontes e estilo dos templates

Se faltar alguma: informar o usuario e instruir a usar `/setup`.

**IMPORTANTE:** Toda operacao com WorkDrive, Writer ou Sheets deve ser feita via skills (`/workdrive`, `/doc`) e NAO via MCP tools. As skills contem os endpoints REST corretos e autenticacao via OAuth2.

### Opcionais
- `/meet` — baixar gravacoes de meetings para uso como evidencia

---

## Subcomandos

### `/case novo [cliente]`
Criar um novo case. Cria pasta + subpasta Evidencias + docs branded (Case Document, Transcription, One-Pager). Adiciona linha na planilha Cases. Sempre verificar se ja existe antes de criar — nunca duplicar. Ver `references/known-ids.md` para IDs de pastas e planilhas.

### `/case evidencia [cliente]`
Receber prints/screenshots/arquivos, fazer upload na pasta Evidencias, extrair dados visiveis, e opcionalmente mergear no Case Document.

### `/case preencher [cliente]`
Receber dados brutos e preencher os documentos corretos. Identificar automaticamente onde cada info encaixa (metricas → Resultados, quotes → Depoimento, contexto → A Dor). Sempre ler doc existente antes de atualizar — merge-first.

### `/case status [cliente]`
Checklist do que tem vs. o que falta: doc preenchido, entrevista transcrita, one-pager gerado, mapa Miro, evidencias coletadas, depoimento, nota prova, campos da planilha.

### `/case status` (sem cliente)
Visao geral de todos os cases: ler planilha completa, exibir tabela resumida.

### `/case analisar [cliente]`
Avaliar forca do case usando criterios Hormozi. Ver `references/proof-checklist.md` para os 13 criterios. Calcular nota 0-10, sugerir melhorias, atualizar planilha.

### `/case ranking`
Comparar cases publicaveis. Ordenar por Nota Prova, destacar qual e mais forte para cada claim.

### `/case claims`
Cobertura de claims. Ver `references/claims.md` para o mapa C001-C009. Cruzar com planilha, exibir cobertura.

### `/case onepager [cliente]`
Gerar one-pager de vendas extraindo dados do case doc. Usar template `templates/onepager.html`.

---

## Regras

- Sempre responder em portugues brasileiro
- Ao preencher dados, identificar automaticamente onde cada info encaixa
- Toda acao que muda dados do case deve atualizar a planilha correspondente
- Nota Prova e de 0 a 10, baseada nos criterios Hormozi de forca de prova
- Formato de depoimento aceita: texto, audio, video, imagem
- Nunca usar "EmailAnalytics" — sempre "Email Intelligence"
- Worksheet padrao em planilhas: `"Sheet1"`
- **No duplicates, merge-first** — sempre check se doc existe, ler conteudo antes de atualizar, nunca sobrescrever

---

## Usage Examples

```
/case novo Acme Corp
/case preencher Acme Corp
/case evidencia Acme Corp
/case status Acme Corp
/case status
/case analisar Acme Corp
/case ranking
/case claims
/case onepager Acme Corp
```

---

## References

- `references/known-ids.md` — Folder IDs, spreadsheet IDs, column mappings
- `references/claims.md` — Email Intelligence claims map (C001-C009)
- `references/proof-checklist.md` — Hormozi proof criteria and scoring guide
- `references/case-template.md` — Case document structure reference
- `references/interview-guide.md` — Interview guide for case collection
- `references/onepager-template.md` — One-pager structure reference
- `references/transcricao-template.md` — Transcription template reference

## Templates

- `templates/case-document.html` — HTML template for Case Study
- `templates/transcription.html` — HTML template for interview transcription
- `templates/onepager.html` — HTML template for sales one-pager
