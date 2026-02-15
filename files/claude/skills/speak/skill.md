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
3. Run the speak script via Bash:
   ```bash
   /usr/local/bin/speak "Your spoken text here"
   ```

That's it. The speak script handles JSON encoding via jq, calls Kokoro, and plays the audio.

IMPORTANT:
- Use double quotes around the text argument
- Escape any double quotes inside the text with backslash
- For long responses (500+ words), split into multiple speak calls
- The permission pattern `Bash(/usr/local/bin/speak *)` auto-approves these calls
- Works in both normal mode and plan mode (no Write tool needed)

## Voice Options

ALWAYS uses `af_sky` (configured in the speak script).

## Troubleshooting

If Kokoro isn't running, fall back to macOS `say`:
```bash
say -v Samantha "spoken text here"
```
