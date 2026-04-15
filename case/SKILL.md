---
name: case
description: Manage Email Intelligence case studies — create cases, fill data, check status, analyze proof strength, generate one-pagers, rank cases, check claim coverage. Use when user mentions "case", "caso", "case study", "criar case", "case novo", "preencher case", "status do case", "analisar case", "one-pager", "ranking de cases", "claims", "evidencia", "depoimento", "proof checklist", "hormozi". This is a workflow skill that orchestrates /doc, /workdrive, and /brand. Do NOT use for generic document creation (that's /doc), file management (that's /workdrive), or meeting operations (that's /meet).
version: 0.6.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, Skill]
argument-hint: <subcommand> [cliente]
---

# Skill: /case — Gestao de Cases do Email Intelligence

Workflow que orquestra o ciclo completo de cases: criacao de pasta, documentos branded, preenchimento, analise e ranking.

---

## Dependencias

### Obrigatorias (sem essas, /case nao roda)
Antes de executar qualquer subcomando, verificar se existem em `~/.claude/skills/`:
- `/workdrive` — criar pastas, listar arquivos, upload, download
- `/doc` — criar/ler/atualizar documentos no Writer
- `/brand` — cores, fontes e estilo dos templates

Se faltar alguma: informar o usuario e instruir a usar `/setup` pra instalar.

**IMPORTANTE:** Toda operacao com WorkDrive, Writer ou Sheets deve ser feita via skills (`/workdrive`, `/doc`) e NAO via MCP tools. As skills contem os endpoints REST corretos e autenticacao via OAuth2.

### Opcionais
- `/meet` — baixar gravacoes de meetings para uso como evidência

---

## IDs especificos de Cases

### Pastas (WorkDrive)
- cases/: `e6ecq49cce46733684c5a8ccff21b24cb8812`
- ab-tests/: `e6ecq851e5c6cc0304833a3563c12f3128683`

### Planilhas (Zoho Sheet)
- **Cases** (16 colunas): resource_id `e6ecq10636f566058469ea504d66793a35c75`
  - Colunas (index 1-16): ID, Cliente, Nicho, Produto, Tamanho da Base, Data Implementacao, Status, Dor Resolvida, Impacto Principal, Tempo ate Resultado, Claim Principal, Nota Prova (0-10), Tem Depoimento, Formato Depoimento, Link Pasta, Notas
- **AB Tests** (11 colunas): resource_id `e6ecq946b8ca126e147b98105c7835d431f5c`
  - Colunas (index 1-11): ID, Hipotese, Impacto Esperado, Esforco, Cliente, Status, Resultado, Aprendizado Principal, Impacto Observado, Link Pasta, Notas

### Templates HTML
Salvos em `~/.claude/skills/case/templates/`:
- `case-document.html` — Case Study completo
- `transcription.html` — Transcricao de entrevista
- `onepager.html` — One-pager de vendas

---

## Subcomandos

### `/case novo [cliente]`
Criar um novo case para o cliente informado.

1. Checar dependencias obrigatorias
2. Obter token (`source ~/.claude/secrets.env` + OAuth2)
3. Listar arquivos em `cases/` para verificar se ja existe pasta do cliente
4. Se nao existir pasta:
   a. Criar pasta do cliente em `cases/` (usando /workdrive)
   b. Criar subpasta `Evidencias` dentro da pasta do cliente (usando /workdrive)
      - Aqui serao armazenados prints, screenshots, gravacoes e qualquer arquivo de prova
   c. **ANTES de criar qualquer doc:** listar arquivos da pasta do cliente no WorkDrive para verificar se os docs ja existem
   d. Para cada doc que **NAO existe**, criar (usando /doc + /brand pra estilo):
      - `filename=Case Document - [Cliente]` usando `templates/case-document.html`
      - `filename=Transcription - [Cliente]` usando `templates/transcription.html`
      - `filename=One-Pager - [Cliente]` usando `templates/onepager.html`
   e. Para cada doc que **JA existe**, ler o conteudo atual antes de qualquer alteracao — nunca criar duplicata
   f. Substituir "ACME" pelo nome real do cliente nos HTMLs antes de enviar
5. Se ja existir pasta:
   a. Listar arquivos da pasta para ver quais docs ja existem
   b. Criar somente os docs que faltam
   c. Para docs existentes: ler conteudo atual e preservar dados ja preenchidos
   d. **NUNCA criar doc duplicado** — se o doc ja existe, atualizar via `POST /writer/api/v1/documents/DOC_ID` com o conteudo novo
6. Ler planilha Cases para descobrir proximo ID sequencial (CASE-XXX)
7. Adicionar linha na planilha Cases com:
   - ID sequencial
   - Nome do cliente
   - Status: `em coleta`
   - Link da pasta: `https://workdrive.inbox.ac/folder/<folder_id>`
   - Demais campos vazios
8. Lembrar o usuario de:
   - Criar o mapa visual no Miro e colar o link no case doc
   - Coletar provas (prints, screenshots, gravacoes) e fazer upload na pasta
9. Confirmar criacao ao usuario com checklist do que foi criado

### `/case evidencia [cliente]`
Receber prints/screenshots/arquivos e salvar na pasta Evidencias do case.

1. Checar dependencias obrigatorias
2. Obter token
3. Buscar a pasta do cliente em `cases/`
4. Verificar se subpasta `Evidencias` existe; se nao, criar
5. O usuario pode enviar:
   - **Caminho local** de arquivo(s) (ex: `~/Desktop/print1.png`)
   - **Imagem colada/arrastada** no chat
6. Para cada arquivo/imagem recebido:
   a. Ler/analisar o conteudo (extrair metricas, textos, dados visiveis)
   b. Fazer upload pro WorkDrive na pasta `Evidencias` do cliente (usando /workdrive upload)
   c. Anotar resumo do que foi extraido
7. Perguntar ao usuario se quer que as informacoes extraidas sejam adicionadas ao Case Document
8. Se sim: ler o doc atual primeiro (NUNCA sobrescrever), fazer merge adicionando os dados novos
9. Atualizar planilha Cases se algum campo novo foi preenchido

### `/case preencher [cliente]`
Receber dados brutos do usuario e preencher os documentos corretos.

1. Checar dependencias obrigatorias
2. Obter token
3. Perguntar ao usuario quais dados ele tem (metricas, quotes, contexto, prints)
4. Identificar em qual documento cada informacao encaixa:
   - Metricas antes/depois → case doc (secao Resultados)
   - Quotes do cliente → case doc (secao Depoimento) + one-pager
   - Contexto/dor → case doc (secao A Dor)
   - Dados de implementacao → case doc (secao A Solucao + Linha do Tempo)
5. Buscar a pasta do cliente em `cases/`
6. Para cada doc a preencher:
   a. Montar HTML completo com dados reais usando os templates
   b. Atualizar doc existente (nova versao via /doc)
7. Atualizar a planilha Cases com campos resumidos
8. Mostrar o que foi preenchido e o que ainda falta

**Importante:** Se ja existir um doc com dados, perguntar ao usuario se quer sobrescrever ou manter.

### `/case status [cliente]`
Mostrar checklist do que tem vs. o que falta.

1. Buscar a pasta do cliente em `cases/`
2. Listar arquivos na pasta
3. Ler a linha do cliente na planilha Cases
4. Exibir checklist:
   - [ ] Case doc preenchido
   - [ ] Entrevista realizada/transcrita
   - [ ] One-pager gerado
   - [ ] Mapa visual criado (Miro)
   - [ ] Pasta Evidencias criada
   - [ ] Provas coletadas (prints/screenshots na pasta Evidencias)
   - [ ] Depoimento coletado
   - [ ] Nota Prova atribuida (0-10)
   - [ ] Campos da planilha completos

### `/case status` (sem cliente)
Visao geral de todos os cases.

1. Ler a planilha Cases completa
2. Exibir tabela resumida: Cliente | Status | Nota | O que falta

### `/case analisar [cliente]`
Avaliar a forca do case usando criterios Hormozi.

1. Ler o case doc completo do WorkDrive
2. Avaliar cada criterio do Proof Checklist ($100M Leads):
   - In-Person > Virtual
   - Live > Recorded
   - Raw > Processed
   - Show > Tell
   - Other People > You
   - Identical to Them > Opposite
   - Personal > Generic
   - Big Results > Small > None
   - Newer > Older
   - More > Less
   - Third Party Verification > Zero
   - With Numbers > Without
   - Metaphors > Jargon
3. Calcular nota 0-10 baseada nos criterios atendidos
4. Sugerir melhorias especificas para aumentar a nota
5. Atualizar Nota Prova na planilha

### `/case ranking`
Comparar todos os cases publicaveis.

1. Ler planilha Cases, filtrar status `publicavel`
2. Ordenar por Nota Prova (maior → menor)
3. Exibir ranking com: posicao, cliente, nota, impacto principal, claim
4. Destacar qual case e mais forte para cada claim

### `/case claims`
Mostrar cobertura de claims.

1. Ler planilha Cases
2. Cruzar com lista de claims mapeadas:
   - C001: Melhora open rate ao enviar para engajados
   - C002: Reduz spam rate / melhora inbox placement
   - C003: Reduz bounce rate apos limpeza
   - C004: Economiza tempo eliminando segmentacao manual
   - C005: Melhora reputacao no Postmaster
   - C006: Identifica contatos que prejudicam entregabilidade
   - C007: Instala em minutos e atualiza sozinho
   - C008: Aumenta CTR segmentando por engajamento
   - C009: Reduz custo AC ao limpar contatos sem engajamento
3. Exibir: claim | qtd cases | nota media | melhor case

### `/case onepager [cliente]`
Gerar one-pager de vendas.

1. Checar dependencias obrigatorias
2. Obter token
3. Ler case doc completo
4. Extrair: dor, resultado principal (com numeros), quote do cliente, claim
5. Montar HTML do one-pager usando `templates/onepager.html` com dados reais
6. Se ja existir one-pager: atualizar (nova versao via /doc)
7. Se nao existir: criar via /doc com `filename=One-Pager - [Cliente]`
8. Atualizar planilha se necessario

---

## Regras

- Sempre responder em portugues brasileiro
- Ao preencher dados, identificar automaticamente onde cada info encaixa
- Toda acao que muda dados do case deve atualizar a planilha correspondente
- Nota Prova e de 0 a 10, baseada nos criterios Hormozi de forca de prova
- Formato de depoimento aceita: texto, audio, video, imagem
- Nunca usar "EmailAnalytics" — sempre "Email Intelligence"
- Worksheet padrao em planilhas: `"Sheet1"`
- **No duplicates, merge-first** — the /doc skill enforces this: always check if a doc exists before creating, read existing content before updating, never overwrite blindly. Follow /doc's decision flow for all document operations.
