---
name: brand
description: Inbox brand guidelines — colors, fonts, visual style. Use when the user asks about brand colors, fonts, visual identity, "what color should I use", "what font", "brand guide", "brandbook", "identidade visual", "paleta de cores", or when deciding visual direction for any asset. Also use when creating presentations, landing pages, social media, or any visual that needs Inbox branding (but NOT for Zoho Writer documents — those use the /doc skill which has its own style guide). Do NOT use for creating/editing docs in Writer (that's /doc) or file operations (that's /workdrive).
version: 0.2.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
argument-hint: [question or context]
---

# Skill: /brand — Inbox Brand Guidelines

Quick reference for Inbox brand identity. Use for presentations, landing pages, social assets, email templates, or any visual that needs brand consistency.

For **Zoho Writer documents**, the /doc skill has its own style guide at `~/.claude/skills/doc/references/style-guide.md` with Writer-specific adaptations already baked in. Don't duplicate that work here — this skill covers the broader brand system.

---

## Colors

### Core

| Name | Hex | Usage |
|------|-----|-------|
| **Night** | `#161616` | Primary background (dark mode), text on light backgrounds, logos |
| **White** | `#FFFFFF` | Light backgrounds, text on dark backgrounds |
| **French Gray** | `#A9ABB0` | Secondary text, borders, notes, placeholders, dividers |

### Submarca Accents

Each Inbox sub-brand has a signature color. Use these as primary accents when the context is clearly tied to one sub-brand:

| Submarca | Color | Hex | When to use |
|----------|-------|-----|-------------|
| InboxAcademy | **Turquesa** | `#00D0B7` | Courses, learning, educational content, growth metrics |
| InboxUniversity | **Electric Blue** | `#004CFF` | Certifications, formal programs, institutional content |
| InboxCommunity | **Rose** | `#FF1F7D` | Community events, networking, collaboration, social |

When the context doesn't belong to a specific sub-brand (general Inbox content), default to **Turquesa** `#00D0B7` as the primary accent.

### Complementary Palette

Use these for data visualization, charts, illustrations, and decorative elements — not for text or primary UI:

| Name | Dark | Light | Mood |
|------|------|-------|------|
| **Menta** | `#90FFC3` | `#B4FFD6` | Growth, ethics, energy |
| **Turquesa** | `#00D0B7` | `#49E9D6` | Growth, agility, learning |
| **Jasmine** | `#FFE37F` | `#FFECAA` | Energy, optimization, intelligence |
| **Atomic Tangerine** | `#FFB190` | `#FFC4AC` | Creativity, enthusiasm, innovation |
| **Rose** | `#FF1F7D` | `#FF6CAA` | Collaboration, empathy, connection |
| **Electric Purple** | `#A54AFF` | `#B76FFF` | Technology, creativity, innovation |
| **Electric Blue** | `#004CFF` | `#336FFF` | Qualification, stability, trust |

**For charts:** pick 3-4 colors max from this palette. Start with the sub-brand accent, then add complementary colors that contrast well. Avoid using all 7 at once.

---

## Typography

### Fonts

| Font | Type | Where to use |
|------|------|--------------|
| **Axiforma** | Geometric Sans (paid license) | Official branding, logo, print materials, decks |
| **Poppins** | Geometric Sans (Google Fonts, free) | Zoho Writer, web, email templates, anything Axiforma isn't available |
| **Roboto** | Sans-serif (fallback) | When neither Axiforma nor Poppins is available |

### Hierarchy by context

**Presentations / Landing Pages (dark background):**

| Element | Weight | Relative size |
|---------|--------|---------------|
| Section label | Book | Small (caption) |
| Title | **Bold** | Extra large |
| Subtitle | Light | Large |
| Body | Book | Base |

**Documents / Reports (light background):**

| Element | Size | Weight |
|---------|------|--------|
| H1 | 21pt | Bold (700) |
| H2 | 16pt | Semibold (600) |
| H3 | 13pt | Semibold (600) |
| Body | 12pt | Regular (400) |
| Table cells | 11pt | Regular |
| Notes | 10pt | Regular |

*For Zoho Writer specifics (inline styles, font-family repetition, etc), see the /doc skill's style guide.*

---

## Visual Style

### Dark Mode (default brand context)
- Background: `#161616`
- **Glassmorphism** cards: semi-transparent background + blur
- **Glow effects**: complementary color blurs behind elements
- **Subtle grid**: thin lines in background
- **Lowercase** titles (brandbook convention)
- Rounded corners on all elements
- Modern, minimalist, tech-forward, premium B2B SaaS feel

### Light Mode (docs, emails, reports)
- Background: `#FFFFFF`
- Text: `#161616`
- Accents: `#00D0B7` or `#004CFF`
- Borders: `#A9ABB0`
- Header backgrounds: `#f5f5f5`
- No glassmorphism (doesn't translate well to light mode)

### What to avoid
- Colors outside the palette
- Serif fonts
- Heavy gradients (keep it clean and minimal)
- Emojis in professional document titles
- Dark background with white table headers in Writer (use `#f5f5f5` bg with `#161616` text)
- `<blockquote>` in Writer (renders poorly — use `<p>` with border-left instead)
