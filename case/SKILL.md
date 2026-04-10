---
name: case
description: This skill should be used when the user asks to "create a new case", "document a case", "fill case data", "check case status", "analyze a case", "generate one-pager", "rank cases", "check claims", "generate case visual". Manages Email Intelligence case studies — creation, documentation, analysis, and artifact generation.
version: 0.3.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, mcp__zoho-sheet__*, mcp__zoho-workdrive__*, mcp__zoho-writer__*]
argument-hint: <subcommand> [cliente]
---

# Skill: /case — Gestao de Cases do Email Intelligence

Orquestra o ciclo completo de cases. Usa as skills `/workdrive`, `/doc` e `/brand` para operacoes especificas.

---

## Skills relacionadas

- `/workdrive` — criar pasta, listar arquivos, mover, trash, OAuth2
- `/doc` — criar/atualizar docs Writer com HTML branded, templates
- `/brand` — cores, fontes, estilo visual da Inbox

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

1. Obter token via `/workdrive` (`source ~/.claude/secrets.env` + OAuth2)
2. Listar arquivos em `cases/` para verificar se ja existe pasta do cliente
3. Se nao existir pasta:
   a. Criar pasta do cliente em `cases/` via `/workdrive`
   b. Criar 3 docs na pasta via `/doc`:
      - `Case Document - [Cliente]` usando `templates/case-document.html`
      - `Transcription - [Cliente]` usando `templates/transcription.html`
      - `One-Pager - [Cliente]` usando `templates/onepager.html`
   c. Substituir "ACME" pelo nome real do cliente nos HTMLs antes de enviar
4. Se ja existir pasta: pular criacao, informar que pasta ja existe
5. Ler planilha Cases para descobrir proximo ID sequencial (CASE-XXX)
6. Adicionar linha na planilha Cases com:
   - ID sequencial
   - Nome do cliente
   - Status: `em coleta`
   - Link da pasta: `https://workdrive.inbox.ac/folder/<folder_id>`
   - Demais campos vazios
7. Lembrar o usuario de:
   - Criar o mapa visual no Miro e colar o link no case doc
   - Coletar provas (prints, screenshots, gravacoes) e fazer upload na pasta
8. Confirmar criacao ao usuario com checklist do que foi criado

### `/case preencher [cliente]`
Receber dados brutos do usuario e preencher os documentos corretos.

1. Obter token via `/workdrive`
2. Perguntar ao usuario quais dados ele tem (metricas, quotes, contexto, prints)
3. Identificar em qual documento cada informacao encaixa:
   - Metricas antes/depois → case doc (secao Resultados)
   - Quotes do cliente → case doc (secao Depoimento) + one-pager
   - Contexto/dor → case doc (secao A Dor)
   - Dados de implementacao → case doc (secao A Solucao + Linha do Tempo)
4. Buscar a pasta do cliente em `cases/` via `/workdrive`
5. Para cada doc a preencher:
   a. Montar HTML completo com dados reais usando os templates
   b. Atualizar doc existente via `/doc` (nova versao)
6. Atualizar a planilha Cases com campos resumidos (Dor Resolvida, Impacto Principal, etc.)
7. Mostrar o que foi preenchido e o que ainda falta

**Importante:** Se ja existir um doc com dados na pasta do cliente, perguntar ao usuario se quer sobrescrever ou manter o existente.

### `/case status [cliente]`
Mostrar checklist do que tem vs. o que falta para um case especifico.

1. Buscar a pasta do cliente em `cases/` via `/workdrive`
2. Listar arquivos na pasta
3. Ler a linha do cliente na planilha Cases
4. Exibir checklist:
   - [ ] Case doc preenchido
   - [ ] Entrevista realizada/transcrita
   - [ ] One-pager gerado
   - [ ] Mapa visual criado (Miro)
   - [ ] Provas coletadas
   - [ ] Depoimento coletado
   - [ ] Nota Prova atribuida (0-10)
   - [ ] Campos da planilha completos

### `/case status` (sem cliente)
Visao geral de todos os cases.

1. Ler a planilha Cases completa
2. Exibir tabela resumida: Cliente | Status | Nota | O que falta

### `/case analisar [cliente]`
Avaliar a forca do case usando criterios Hormozi.

1. Ler o case doc completo do WorkDrive via `/workdrive`
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

1. Obter token via `/workdrive`
2. Ler case doc completo via `/workdrive`
3. Extrair: dor, resultado principal (com numeros), quote do cliente, claim
4. Montar HTML do one-pager usando `templates/onepager.html` com dados reais via `/doc`
5. Se ja existir one-pager: atualizar (nova versao) via `/doc`
6. Se nao existir: criar via `/doc` com `filename=One-Pager - [Cliente]`
7. Atualizar planilha se necessario

---

## Regras

- Sempre responder em portugues brasileiro
- Ao preencher dados, identificar automaticamente onde cada info encaixa
- Toda acao que muda dados do case deve atualizar a planilha correspondente
- Nota Prova e de 0 a 10, baseada nos criterios Hormozi de forca de prova
- Formato de depoimento aceita: texto, audio, video, imagem
- Nunca usar "EmailAnalytics" — sempre "Email Intelligence"
- Worksheet padrao em planilhas: `"Sheet1"`
