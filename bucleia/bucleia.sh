#!/opt/homebrew/bin/bash
set -euo pipefail

# === 📂 Rutas relativas ===
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_SISTEMA="$DIR/prompbucle.txt"
PROMPT_FILE="$DIR/nexo.txt"
SESSIONS_FOLDER="$DIR/sesiones"
LOG_FOLDER="$DIR/logs"
mkdir -p "$SESSIONS_FOLDER" "$LOG_FOLDER"

NOMBRE_SESION="Sesion_$(date +'%Y-%m-%d_%H-%M-%S').md"
SESSION_PATH="$SESSIONS_FOLDER/$NOMBRE_SESION"
LOG_PATH="$LOG_FOLDER/salida.log"

MODELO_PATH="$DIR/mistral-7b-instruct-v0.1.Q6_K.gguf"
MAIN_BINARY="$DIR/llama-cli"

[[ ! -f "$PROMPT_FILE" ]] && { echo "❌ No se encontró el archivo de entrada: $PROMPT_FILE"; exit 1; }

# === ⚙️ Ejecutar modelo con input desde archivo y capturar respuesta temporalmente ===
TEMP_OUT=$(mktemp)

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  --ctx-size 31000 \
  --n-predict 500 \
  --color \
  --temp 1.2 \
  --threads 6 \
  --prompt "$(cat "$PROMPT_SISTEMA") $(cat "$PROMPT_FILE")" 2>&1 | grep -v 'llama_' | tee >(tee -a "$LOG_PATH") >> "$TEMP_OUT"

# === ✂️ Filtrar salida para dejar solo la respuesta útil (elimina líneas que contienen el nombre del binario o arranques técnicos) ===
sed -n '/\[\[/,/\]\]/p' "$TEMP_OUT" | sed 's/\[\[//;s/\]\]//' > "${TEMP_OUT}.clean"
mv "${TEMP_OUT}.clean" "$TEMP_OUT"

# === 🔄 Sustituir archivo original si hubo respuesta ===
if [[ -s "$TEMP_OUT" ]]; then
    cp "$TEMP_OUT" "$SESSION_PATH"
    mv "$TEMP_OUT" "$PROMPT_FILE"
    echo "✅ Archivo $PROMPT_FILE actualizado con la respuesta."
else
    echo "⚠️ Respuesta vacía. Se conserva el archivo original."
    rm "$TEMP_OUT"
fi
