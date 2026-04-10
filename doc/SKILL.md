---
name: doc
description: Use this skill to create or update Zoho Writer documents with branded HTML content. Handles HTML generation from templates, document creation via Writer API, and version updates. Works with /brand for styling and /workdrive for file operations.
version: 0.1.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /doc — Zoho Writer Document Operations

Criar e atualizar documentos no Zoho Writer com conteudo HTML branded. Usa templates HTML com estilos inline seguindo a skill `/brand`.

---

## Criar documento

```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html" \
  -F "folder_id=WORKDRIVE_FOLDER_ID" \
  -F "filename=Nome do Documento"
```

**Importante:** auth header e `Zoho-oauthtoken` (nao `Bearer`). O `folder_id` aceita IDs do WorkDrive direto. O param `service` NAO e aceito nesse endpoint.

Retorna `document_id`, `open_url`, `document_name`.

## Atualizar documento (nova versao)

```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html"
```

Substitui o conteudo inteiro, mantendo o doc_id e historico de versoes.

---

## Fluxo para criar doc branded

1. Ler template HTML de `~/.claude/skills/case/templates/` (ou criar HTML do zero seguindo `/brand`)
2. Substituir placeholders (nome do cliente, dados, etc.)
3. Salvar em `/tmp/nome.html`
4. Obter token via OAuth2 (ver skill `/workdrive`)
5. Criar doc via `POST /writer/api/v1/documents` com `content`, `folder_id`, `filename`

---

## Estilo HTML para Zoho Writer

O Writer renderiza HTML com estilos inline. Seguir a skill `/brand` para cores e fontes. Regras especificas do Writer:

### Fonte
- Usar `font-family: Poppins` em todos os elementos (funciona no Writer)
- Roboto tambem funciona como alternativa
- Axiforma (fonte oficial) NAO esta disponivel no Writer
- Fontes precisam de `font-family` em CADA elemento (nao herda do body no Writer)

### Estrutura padrao de um doc
```html
<html><body style="font-family: Poppins; color: #161616; line-height: 1.7;">

<!-- H1 titulo -->
<h1 style="font-family: Poppins; color: #161616; margin: 0 0 5px 0; font-size: 28px; font-weight: 700;">Titulo — Cliente</h1>
<hr style="border: 2px solid #161616; margin-bottom: 25px;">

<!-- Tabela de dados -->
<table style="width:100%; border-collapse:collapse; border: 1px solid #A9ABB0;">
  <tr>
    <td style="font-family: Poppins; padding: 12px 16px; border: 1px solid #A9ABB0; font-weight: 600; width: 35%; color: #161616; background-color: #f5f5f5;">Label</td>
    <td style="font-family: Poppins; padding: 12px 16px; border: 1px solid #A9ABB0;">Valor</td>
  </tr>
</table>

<!-- H2 secao -->
<h2 style="font-family: Poppins; color: #161616; margin-top: 35px; font-size: 20px; font-weight: 600; border-bottom: 1px solid #A9ABB0; padding-bottom: 8px;">Secao</h2>
<p style="font-family: Poppins; color: #161616;">Texto</p>

<!-- Destaque com borda turquesa -->
<p style="font-family: Poppins; background: #f5f5f5; padding: 16px 20px; border-left: 4px solid #00D0B7; color: #161616;">Texto destacado</p>

<!-- Blockquote -->
<blockquote style="font-family: Poppins; border-left: 4px solid #00D0B7; padding: 20px 24px; margin: 20px 0; background: #f5f5f5; font-style: italic; font-size: 15px; color: #161616;">
"Quote"
<br><br>
<strong style="font-style: normal; color: #161616;">— Nome, Cargo</strong>
</blockquote>

<!-- Tabela com header escuro -->
<table style="width:100%; border-collapse: collapse; border: 1px solid #A9ABB0;">
  <tr style="background-color: #161616; color: #FFFFFF;">
    <th style="font-family: Poppins; padding: 12px 16px; text-align: left; font-weight: 600; border: 1px solid #A9ABB0;">Col</th>
  </tr>
  <tr>
    <td style="font-family: Poppins; padding: 12px 16px; border: 1px solid #A9ABB0;">Dado</td>
  </tr>
</table>

<!-- Notas internas (cinza) -->
<h2 style="font-family: Poppins; color: #A9ABB0; margin-top: 35px; font-size: 18px; font-weight: 600; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px;">Notas Internas</h2>
<p style="font-family: Poppins; font-size: 13px; color: #A9ABB0; background: #f8f9fa; padding: 16px;">Notas</p>

</body></html>
```

---

## Templates disponiveis

Salvos em `~/.claude/skills/case/templates/`:
- `case-document.html` — Case Study completo
- `transcription.html` — Transcricao de entrevista
- `onepager.html` — One-pager de vendas

Para criar novos templates, seguir a mesma estrutura e cores da skill `/brand`.
