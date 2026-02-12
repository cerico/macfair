---
name: speak
description: Speak a response aloud using Kokoro TTS. Use when the user asks you to say something out loud or wants voice output.
user_invocable: true
---

# Speak

Speak text aloud using the local Kokoro TTS service on port 8880.

## When to Use

- User says "speak", "say that", "read that aloud", "tell me out loud"
- User asks for voice/audio output

## How It Works

Run this bash command to speak text (safe for quotes/newlines):

```bash
TEXT="$(cat <<'EOF'
Replace this with your spoken text.
EOF
)"
curl -s -X POST http://127.0.0.1:8880/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg text "$TEXT" '{model:"kokoro",input:$text,voice:"af_sky",response_format:"mp3"}')" \
  -o /tmp/claude_speak.mp3 && afplay /tmp/claude_speak.mp3
```

## Instructions

1. Compose a natural spoken version of your response. Strip markdown, code blocks, bullet points - write it as you'd say it conversationally. Keep it concise.
2. Use the bash command above, replacing the heredoc content with the spoken text.
3. Also type the response normally so the user has it in the terminal.

## Voice Options

Default: `af_sky`. User can request others:
- `af_bella`, `af_heart`, `af_nicole` (American female)
- `am_adam`, `am_michael`, `am_eric` (American male)
- `bf_emma`, `bf_lily` (British female)
- `bm_george`, `bm_daniel` (British male)

Change voice by replacing the `voice` value in the curl command.

## Troubleshooting

If Kokoro isn't running, fall back to macOS `say`:
```bash
say -v Samantha "the text"
```
