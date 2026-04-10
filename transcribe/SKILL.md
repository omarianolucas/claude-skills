---
name: transcribe
description: Use this skill to transcribe audio/video files using Whisper locally. Also used when user mentions "transcrever", "transcricao", "whisper", "transcribe audio", "transcribe video".
version: 0.1.0
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
argument-hint: <file_path> [options]
---

# Skill: /transcribe — Transcricao local com Whisper

Transcreve arquivos de audio/video usando OpenAI Whisper rodando localmente.

---

## Setup

- **Venv:** `~/whisper-env/`
- **Dependencia:** `ffmpeg` (via brew)
- **Ativar:** `source ~/whisper-env/bin/activate`

---

## Uso basico

```bash
source ~/whisper-env/bin/activate && whisper /tmp/arquivo.mp4 \
  --language pt \
  --model medium \
  --output_dir /tmp/whisper_output \
  --output_format txt
```

---

## Modelos

| Modelo | Tamanho | Velocidade | Qualidade pt-BR |
|--------|---------|------------|-----------------|
| tiny | 39M | Muito rapido | Ruim |
| base | 74M | Rapido | Ok |
| small | 244M | Medio | Bom |
| **medium** | 769M | Lento | **Muito bom** |
| large-v3 | 1.5G | Muito lento | Excelente |

**Padrao:** `medium` — melhor custo-beneficio pra pt-BR.

---

## Formatos de output

- `txt` — texto puro
- `vtt` — WebVTT com timestamps
- `srt` — legendas com timestamps
- `json` — completo com word-level timestamps
- `all` — todos os formatos

---

## Formatos de input aceitos

Qualquer formato que o ffmpeg suporte: mp4, mp3, wav, m4a, webm, ogg, flac, etc.

---

## Dicas

- Rodar em background pra arquivos grandes (`run_in_background`)
- Output vai em `/tmp/whisper_output/`
- Arquivo de 26min leva ~5-15min no Mac com Apple Silicon (modelo medium)
- Pra meetings em pt-BR, sempre usar `--language pt` (evita deteccao automatica errada)
