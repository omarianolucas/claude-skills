---
name: brand
description: Use this skill when the user asks about brand colors, fonts, visual style, brand guidelines, "what color should I use", "what font", "brand guide", "brandbook", or when creating any visual asset (HTML templates, docs, presentations) that needs to follow Inbox brand identity.
version: 0.1.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
argument-hint: [question or context]
---

# Skill: /brand — Inbox Brand Guidelines

Referencia rapida do branding da Inbox. Usar sempre que criar templates HTML, docs no Writer, materiais visuais ou qualquer asset que precise seguir a identidade visual.

---

## Cores

### Primarias
| Nome | Hex | RGB | Uso |
|------|-----|-----|-----|
| **Night** | `#161616` | R22 G22 B22 | Fundo principal, texto em fundo claro, logos |
| **White** | `#FFFFFF` | R255 G255 B255 | Fundo claro, texto em fundo escuro |

### Secundaria
| Nome | Hex | RGB | Uso |
|------|-----|-----|-----|
| **French Gray** | `#A9ABB0` | R169 G171 B176 | Texto secundario, bordas, notas, placeholders |

### Cores das Submarcas
| Submarca | Nome | Hex | RGB |
|----------|------|-----|-----|
| InboxAcademy | **Turquesa** | `#00D0B7` | R0 G208 B183 |
| InboxUniversity | **Electric Blue** | `#004CFF` | R0 G76 B255 |
| InboxCommunity | **Rose** | `#FF1F7D` | R255 G31 B125 |

### Paleta Complementar (3 tons: escuro, medio, claro)
| Nome | Hex 1 | Hex 2 | Hex 3 | Significado |
|------|-------|-------|-------|-------------|
| **Menta** | `#90FFC3` | `#B4FFD6` | — | Crescimento, etica, energia |
| **Turquesa** | `#00D0B7` | `#49E9D6` | — | Crescimento, agilidade, aprendizado |
| **Jasmine** | `#FFE37F` | `#FFECAA` | — | Energia, otimizacao, inteligencia |
| **Atomic Tangerine** | `#FFB190` | `#FFC4AC` | — | Criatividade, entusiasmo, inovacao |
| **Rose** | `#FF1F7D` | `#FF6CAA` | — | Colaboracao, empatia, conexao |
| **Electric Purple** | `#A54AFF` | `#B76FFF` | — | Tecnologia, criatividade, inovacao |
| **Electric Blue** | `#004CFF` | `#336FFF` | — | Qualificacao, estabilidade, confianca |

---

## Tipografia

### Fonte Principal: Axiforma
- Tipo: Geometric Sans (licenca paga)
- Pesos: Light, Book, Medium, Semibold, Bold, Extrabold
- Uso: branding oficial, logo, materiais impressos

### Fonte Secundaria: Poppins
- Tipo: Geometric Sans (Google Fonts, gratuita)
- Substitui Axiforma onde nao esta disponivel
- **Usar Poppins no Zoho Writer** (disponivel nativamente)
- Roboto tambem funciona como alternativa no Writer

### Hierarquia Tipografica
| Elemento | Peso | Tamanho ref (ppt) |
|----------|------|--------------------|
| Nome de secao/assunto | Book | 48px |
| Titulos | **Bold** | 128px |
| Subtitulos | Light | 64px |
| Corpo | Book | 24px |

*Tamanhos variam conforme a peca, mas manter proporcoes e hierarquia.*

---

## Estilo Visual

### Tom Geral
- **Dark mode dominante** (fundo `#161616`)
- Moderno, minimalista, tech-forward, premium B2B SaaS
- Cantos arredondados em todos os elementos

### Efeitos
- **Glassmorphism**: cards com fundo semi-transparente + blur
- **Glows**: manchas de cor complementar com blur no fundo
- **Grid sutil**: linhas finas no background
- **Lowercase**: titulos em caixa baixa (estilo do brandbook)

### Elementos Visuais
- Icones com linhas uniformes (24px de espessura no logo)
- Cards com borda sutil semi-transparente (glassmorphism)
- Numeracao em cor de accent (turquesa `#00D0B7`)

---

## Adaptacao para Docs Writer (fundo branco)

Como os docs do Zoho Writer tem fundo branco, adaptar assim:

| Elemento | Estilo |
|----------|--------|
| H1 (titulo principal) | Poppins Bold, cor `#161616`, border-bottom `#161616` |
| H2 (secoes) | Poppins Semibold, cor `#161616`, border-bottom `#A9ABB0` |
| Texto corpo | Poppins Regular, cor `#161616` |
| Texto secundario/notas | Poppins Regular, cor `#A9ABB0` |
| Labels de tabela (coluna esquerda) | Poppins Semibold, cor `#161616` |
| Borders de tabela | `#A9ABB0` ou `#e2e8f0` |
| Background de destaque | `#f5f5f5` (cinza muito claro) |
| Cards de metricas | Fundo `#161616`, texto `#FFFFFF` |
| Blockquotes | border-left `#00D0B7` (turquesa), background `#f5f5f5` |
| Accent para highlights | `#00D0B7` (turquesa) ou `#004CFF` (electric blue) |
| Notas internas | Cor `#A9ABB0`, fundo `#f8f9fa` |

### Nao usar
- Cores fora da paleta
- Fontes serifadas
- Gradients excessivos (manter o estilo limpo e minimalista)
- Emojis nos titulos de docs profissionais
