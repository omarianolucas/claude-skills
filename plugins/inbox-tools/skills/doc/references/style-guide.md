# Inbox Brand Style Guide for Zoho Writer Documents

This file contains the complete visual style for all documents generated via the /doc skill. Read this before generating any HTML.

---

## Colors

| Role | Color | Usage |
|------|-------|-------|
| Primary text | `#161616` | Headings, body text, table labels |
| Secondary text | `#A9ABB0` | Notes, captions, internal sections |
| Positive accent | `#00D0B7` | Evolution indicators, winner highlights |
| Link/CTA accent | `#004CFF` | Links, call-to-action elements |
| Table header bg | `#f5f5f5` | Light gray background for thead |
| Borders | `#A9ABB0` | Table borders, horizontal rules |
| Quote text | `#666` | Testimonials, cited text |

---

## Font

Always use `Poppins`. Zoho Writer does not inherit font-family from the body element, so you need to explicitly set `font-family: Poppins;` on every single element — body, h1, h2, h3, p, td, th, li, **span**, ul, etc. This includes `<span>` tags used inside lists or paragraphs for bold labels — every `<span>` must have `style="font-family: Poppins; ..."` even if it's inside an element that already has Poppins.

This is the single most common rendering bug. If you skip it on one element, that element renders in Writer's default font and looks inconsistent.

---

## Typography Scale

| Element | font-size | font-weight | Extra styles |
|---------|-----------|-------------|--------------|
| h1 | 21pt | 700 | `margin: 0 0 5px 0` |
| h2 | 16pt | 600 | `border-bottom: 1px solid #A9ABB0; padding-bottom: 5px; margin-top: 28px; margin-bottom: 0px` |
| h3 | 13pt | 600 | `margin-top: 20px; margin-bottom: 10px` |
| p | 12pt | 400 | `line-height: 1.7` |
| td/th | 11pt | — | `padding: 10px 14px` |
| li | 12pt | — | `line-height: 1.9; margin-bottom: 10px` |
| notes | 10pt | — | `color: #A9ABB0` |

---

## Templates

### Document skeleton

```html
<html><body style="font-family: Poppins; color: #161616; line-height: 1.7;">

<h1 style="font-family: Poppins; color: #161616; margin: 0 0 5px 0; font-size: 21pt; font-weight: 700;">Title</h1>
<hr style="border-top: 1px solid #161616; margin-top: 0; margin-bottom: 20px;">

<h2 style="font-family: Poppins; color: #161616; margin-top: 28px; margin-bottom: 0px; font-size: 16pt; font-weight: 600; border-bottom: 1px solid #A9ABB0; padding-bottom: 5px;">Section</h2>
<p style="font-family: Poppins; font-size: 12pt; line-height: 1.7;">Paragraph text goes here.</p>

<h3 style="font-family: Poppins; font-size: 13pt; font-weight: 600; color: #161616; margin-top: 20px; margin-bottom: 10px;">Subsection</h3>

</body></html>
```

### Data table

```html
<table style="width: 100%; border-collapse: collapse; margin: 16px 0 24px 0;">
<thead>
<tr>
  <th style="font-family: Poppins; font-size: 11pt; font-weight: 700; color: #161616; background-color: #f5f5f5; border: 1px solid #A9ABB0; padding: 10px 14px; text-align: left;">Label</th>
  <th style="font-family: Poppins; font-size: 11pt; font-weight: 700; color: #161616; background-color: #f5f5f5; border: 1px solid #A9ABB0; padding: 10px 14px; text-align: center;">Value</th>
</tr>
</thead>
<tbody>
<tr>
  <td style="font-family: Poppins; font-size: 11pt; font-weight: 600; border: 1px solid #A9ABB0; padding: 10px 14px;">Metric name</td>
  <td style="font-family: Poppins; font-size: 11pt; border: 1px solid #A9ABB0; padding: 10px 14px; text-align: center;">123</td>
</tr>
</tbody>
</table>
```

Table conventions:
- First column (labels): `text-align: left; font-weight: 600`
- Numeric columns: `text-align: center`
- Evolution/variation column: `font-weight: 700; color: #00D0B7`
- Header: background `#f5f5f5`, text `#161616` (never dark background with white text)

### Key-value table (ficha)

```html
<table style="width: 100%; border-collapse: collapse; margin-bottom: 24px;">
<colgroup><col style="width: 35%;"><col style="width: 65%;"></colgroup>
<tr>
  <td style="font-family: Poppins; font-size: 12pt; font-weight: 700; color: #161616; background-color: #f5f5f5; border: 1px solid #A9ABB0; padding: 12px 16px; vertical-align: middle;">Field</td>
  <td style="font-family: Poppins; font-size: 12pt; border: 1px solid #A9ABB0; padding: 12px 16px; vertical-align: middle;">Value</td>
</tr>
</table>
```

### Bullet list

```html
<ul style="font-family: Poppins; font-size: 12pt; line-height: 1.9; padding-left: 24px; margin-top: 8px;">
  <li style="font-family: Poppins; margin-bottom: 10px;"><span style="font-family: Poppins; font-weight: 600;">Item title:</span> Item description.</li>
</ul>
```

### Quote / testimonial

```html
<p style="font-family: Poppins; font-size: 12pt; line-height: 1.7; font-style: italic; color: #666;">"Quote text goes here" &mdash; Name, Role</p>
```

### Internal notes section (always at the end)

```html
<h2 style="font-family: Poppins; color: #A9ABB0; margin-top: 28px; margin-bottom: 0px; font-size: 16pt; font-weight: 600; border-bottom: 1px solid #A9ABB0; padding-bottom: 5px;">Notas Internas</h2>
<ul style="font-family: Poppins; font-size: 10pt; line-height: 1.9; color: #A9ABB0; padding-left: 24px;">
  <li style="font-family: Poppins; margin-bottom: 4px;">Note item</li>
</ul>
```
