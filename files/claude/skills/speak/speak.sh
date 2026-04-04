#!/bin/bash
VOICE="${1:-af_sky}"
TEXT="$(cat /tmp/claude_speak_${USER}.txt)"
[[ -z "$TEXT" ]] && echo "No text in /tmp/claude_speak_${USER}.txt" && exit 1
curl -s -X POST http://127.0.0.1:8880/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg text "$TEXT" --arg voice "$VOICE" '{model:"kokoro",input:$text,voice:$voice,response_format:"mp3"}')" \
  -o /tmp/claude_speak_${USER}.mp3 && afplay /tmp/claude_speak_${USER}.mp3
