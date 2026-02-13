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

## Instructions

1. Compose a natural spoken version of your response. Strip markdown, code blocks, bullet points - write it as you'd say it conversationally. Keep it concise.
2. Type the response normally so the user has it in the terminal.
3. Run curl to generate the audio:
   ```bash
   curl -s -X POST http://127.0.0.1:8880/v1/audio/speech -H "Content-Type: application/json" -d '{"model":"kokoro","input":"<spoken text here>","voice":"af_sky","response_format":"mp3"}' -o /tmp/claude_speak.mp3
   ```
4. Run afplay as a SEPARATE Bash call:
   ```bash
   afplay /tmp/claude_speak.mp3
   ```

IMPORTANT — follow these EXACTLY or permissions will break:
- Output to `/tmp/claude_speak.mp3` (system temp dir, always exists — do NOT use project `tmp/`)

## Voice Options

ALWAYS use `af_sky`

## Troubleshooting

If Kokoro isn't running, fall back to macOS `say`:
```bash
say -v Samantha "<spoken text here>"
```
