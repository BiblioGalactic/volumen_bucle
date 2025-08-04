#!/bin/bash
set -euo pipefail

# === 📂 Relative paths ===
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_SISTEMA="$DIR/loop_prompt.txt"
PROMPT_FILE="$DIR/nexus.txt"
SESSIONS_FOLDER="$DIR/sesiones"
LOG_FOLDER="$DIR/logs"
mkdir -p "$SESSIONS_FOLDER" "$LOG_FOLDER"

NOMBRE_SESION="Sesion_$(date +'%Y-%m-%d_%H-%M-%S').md"
SESSION_PATH="$SESSIONS_FOLDER/$NOMBRE_SESION"
LOG_PATH="$LOG_FOLDER/salida.log"

MODELO_PATH="$DIR/mistral-7b-instruct-v0.1.Q6_K.gguf"
MAIN_BINARY="$DIR/llama-cli"

[[ ! -f "$PROMPT_FILE" ]] && { echo "❌ Input file not found: $PROMPT_FILE"; exit 1; }

# === ⚙️ Run model with input from file and capture response temporarily ===
TEMP_OUT=$(mktemp)

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  --ctx-size 31000 \
  --n-predict 500 \
  --color \
  --temp 1.2 \
  --threads 6 \
  --prompt "$(cat "$PROMPT_SISTEMA") $(cat "$PROMPT_FILE")" 2>&1 | grep -v 'llama_' | tee >(tee -a "$LOG_PATH") >> "$TEMP_OUT"

# === ✂️ Filter output to leave only the useful response (removes lines that contain the binary name or technical output) ===
sed -n '/\[\[/,/\]\]/p' "$TEMP_OUT" | sed 's/\[\[//;s/\]\]//' > "${TEMP_OUT}.clean"
mv "${TEMP_OUT}.clean" "$TEMP_OUT"

# === 🔄 Replace original file if there was a response ===
if [[ -s "$TEMP_OUT" ]]; then
    cp "$TEMP_OUT" "$SESSION_PATH"
    mv "$TEMP_OUT" "$PROMPT_FILE"
    echo "✅ File $PROMPT_FILE updated with the response."
else
    echo "⚠️ Empty response. Original file preserved."
    rm "$TEMP_OUT"
fi
