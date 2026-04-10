---
name: doc
description: Use this skill to create or update Zoho Writer documents with HTML content. Also used when user mentions "criar doc", "criar documento", "atualizar doc", "writer", "zoho writer".
version: 0.2.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <operation> [args]
---

# Skill: /doc — Zoho Writer Document Operations

Criar e atualizar documentos no Zoho Writer via API REST.

---

## Scopes

```
ZohoWriter.documentEditor.ALL, ZohoWriter.merge.ALL, ZohoPC.files.ALL
```

Variavel no secrets.env: `ZOHO_REFRESH_TOKEN_WRITER`

---

## OAuth2

```bash
source ~/.claude/secrets.env

TOKEN=$(curl -s -X POST "https://accounts.zoho.com/oauth/v2/token" \
  -d "refresh_token=$ZOHO_REFRESH_TOKEN_WRITER" \
  -d "client_id=$ZOHO_CLIENT_ID" \
  -d "client_secret=$ZOHO_CLIENT_SECRET" \
  -d "grant_type=refresh_token" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['access_token'])")
```

Auth header para Writer: `Authorization: Zoho-oauthtoken $TOKEN` (nao `Bearer`)

---

## Operacoes

### Criar documento
```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html" \
  -F "folder_id=WORKDRIVE_FOLDER_ID" \
  -F "filename=Nome do Documento"
```
- `content` — arquivo HTML (multipart form-data)
- `folder_id` — ID da pasta no WorkDrive (opcional, se omitido vai pra My Folders)
- `filename` — nome do documento (opcional, se omitido usa nome do arquivo)

Retorna `document_id`, `open_url`, `document_name`.

### Atualizar documento (nova versao)
```bash
curl -s -X POST "https://www.zohoapis.com/writer/api/v1/documents/DOC_ID" \
  -H "Authorization: Zoho-oauthtoken $TOKEN" \
  -F "content=@/tmp/arquivo.html"
```
Substitui o conteudo inteiro, mantendo o doc_id e historico de versoes.

---

## HTML no Zoho Writer

O Writer renderiza HTML com estilos inline. Regras:

### Fontes que funcionam no Writer
- `Poppins` — funciona
- `Roboto` — funciona
- `Arial` → renderiza como Arimo
- Fontes precisam de `font-family` em CADA elemento (nao herda do body)

### Estrutura basica de um doc
```html
<html><body style="font-family: Poppins; color: #161616; line-height: 1.7;">

<h1 style="font-family: Poppins; font-size: 28px; font-weight: 700;">Titulo</h1>
<hr style="border: 2px solid #161616;">

<h2 style="font-family: Poppins; font-size: 20px; font-weight: 600;">Secao</h2>
<p style="font-family: Poppins;">Texto</p>

<table style="width:100%; border-collapse:collapse; border: 1px solid #ccc;">
  <tr>
    <td style="font-family: Poppins; padding: 12px; border: 1px solid #ccc;">Dado</td>
  </tr>
</table>

</body></html>
```

### Dicas
- Salvar HTML em `/tmp/` antes de enviar via curl
- O endpoint de criar doc NÃO aceita o param `service`, mas aceita `folder_id` do WorkDrive
- Gradients (`linear-gradient`) nao renderizam — usar `background-color` solido
- Merge fields do Writer so funcionam pela UI — nao usar via API

---

## Limitacoes

- Param `service` nao aceito no endpoint de criacao com file upload
- Fonte heranca do body nao funciona — repetir font-family em cada elemento
- Merge fields nao podem ser inseridos via API
