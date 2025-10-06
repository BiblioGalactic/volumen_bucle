#!/opt/homebrew/bin/bash
set -euo pipefail

# === 📂 Bide erlatiboak ===
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_SISTEMA="$DIR/prompbucle.txt"
PROMPT_FILE="$DIR/nexo.txt"
SESSIONS_FOLDER="$DIR/saioak"
LOG_FOLDER="$DIR/logs"

mkdir -p "$SESSIONS_FOLDER" "$LOG_FOLDER"

NOMBRE_SESION="Saioa_$(date +'%Y-%m-%d_%H-%M-%S').md"
SESSION_PATH="$SESSIONS_FOLDER/$NOMBRE_SESION"
LOG_PATH="$LOG_FOLDER/irteera.log"
MODELO_PATH="$DIR/mistral-7b-instruct-v0.1.Q6_K.gguf"
MAIN_BINARY="$DIR/llama-cli"

[[ ! -f "$PROMPT_FILE" ]] && { echo "❌ Ez da sarrera-fitxategia aurkitu: $PROMPT_FILE"; exit 1; }

# === ⚙️ Modeloa exekutatu fitxategiko sarrerarekin eta erantzuna aldi baterako hartu ===
TEMP_OUT=$(mktemp)

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  --ctx-size 31000 \
  --n-predict 500 \
  --color \
  --temp 1.2 \
  --threads 6 \
  --prompt "$(cat "$PROMPT_SISTEMA") $(cat "$PROMPT_FILE")" 2>&1 | grep -v 'llama_' | tee >(tee -a "$LOG_PATH") >> "$TEMP_OUT"

# === ✂️ Irteera filtratu erantzun erabilgarria soilik uzteko (binarioaren izena edo abiarazpen teknikoak dituzten lerroak ezabatzen ditu) ===
sed -n '/\[\[/,/\]\]/p' "$TEMP_OUT" | sed 's/\[\[//;s/\]\]//' > "${TEMP_OUT}.clean"
mv "${TEMP_OUT}.clean" "$TEMP_OUT"

# === 🔄 Jatorrizko fitxategia ordezkatu erantzunik izan bada ===
if [[ -s "$TEMP_OUT" ]]; then
    cp "$TEMP_OUT" "$SESSION_PATH"
    mv "$TEMP_OUT" "$PROMPT_FILE"
    echo "✅ $PROMPT_FILE fitxategia erantzunarekin eguneratuta."
else
    echo "⚠️ Erantzun hutsa. Jatorrizko fitxategia gordetzen da."
    rm "$TEMP_OUT"
fi
