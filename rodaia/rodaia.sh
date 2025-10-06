#!/opt/homebrew/bin/bash
set -euo pipefail

# === 📂 Rutes relatives ===
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_SISTEMA="$DIR/prompbucle.txt"
PROMPT_FILE="$DIR/nexo.txt"
SESSIONS_FOLDER="$DIR/sesiones"
LOG_FOLDER="$DIR/logs"

mkdir -p "$SESSIONS_FOLDER" "$LOG_FOLDER"

NOMBRE_SESION="Sessio_$(date +'%Y-%m-%d_%H-%M-%S').md"
SESSION_PATH="$SESSIONS_FOLDER/$NOMBRE_SESION"
LOG_PATH="$LOG_FOLDER/sortida.log"
MODELO_PATH="$DIR/mistral-7b-instruct-v0.1.Q6_K.gguf"
MAIN_BINARY="$DIR/llama-cli"

[[ ! -f "$PROMPT_FILE" ]] && { echo "❌ No s'ha trobat l'arxiu d'entrada: $PROMPT_FILE"; exit 1; }

# === ⚙️ Executar model amb input des d'arxiu i capturar resposta temporalment ===
TEMP_OUT=$(mktemp)

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  --ctx-size 31000 \
  --n-predict 500 \
  --color \
  --temp 1.2 \
  --threads 6 \
  --prompt "$(cat "$PROMPT_SISTEMA") $(cat "$PROMPT_FILE")" 2>&1 | grep -v 'llama_' | tee >(tee -a "$LOG_PATH") >> "$TEMP_OUT"

# === ✂️ Filtrar sortida per deixar només la resposta útil (elimina línies que contenen el nom del binari o arrencades tècniques) ===
sed -n '/\[\[/,/\]\]/p' "$TEMP_OUT" | sed 's/\[\[//;s/\]\]//' > "${TEMP_OUT}.clean"
mv "${TEMP_OUT}.clean" "$TEMP_OUT"

# === 🔄 Substituir arxiu original si hi ha hagut resposta ===
if [[ -s "$TEMP_OUT" ]]; then
    cp "$TEMP_OUT" "$SESSION_PATH"
    mv "$TEMP_OUT" "$PROMPT_FILE"
    echo "✅ Arxiu $PROMPT_FILE actualitzat amb la resposta."
else
    echo "⚠️ Resposta buida. Es conserva l'arxiu original."
    rm "$TEMP_OUT"
fi