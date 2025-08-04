#!/bin/bash
set -euo pipefail

# === 📂 相対パス ===
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_SISTEMA="$DIR/ループプロンプト.txt"
PROMPT_FILE="$DIR/ネクサス.txt"
SESSIONS_FOLDER="$DIR/sesiones"
LOG_FOLDER="$DIR/logs"
mkdir -p "$SESSIONS_FOLDER" "$LOG_FOLDER"

NOMBRE_SESION="Sesion_$(date +'%Y-%m-%d_%H-%M-%S').md"
SESSION_PATH="$SESSIONS_FOLDER/$NOMBRE_SESION"
LOG_PATH="$LOG_FOLDER/salida.log"

MODELO_PATH="$DIR/mistral-7b-instruct-v0.1.Q6_K.gguf"
MAIN_BINARY="$DIR/llama-cli"

[[ ! -f "$PROMPT_FILE" ]] && { echo "❌ 入力ファイルが見つかりません: $PROMPT_FILE"; exit 1; }

# === ⚙️ ファイルから入力を読みモデルを実行し、一時的に応答をキャプチャ ===
TEMP_OUT=$(mktemp)

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  --ctx-size 31000 \
  --n-predict 500 \
  --color \
  --temp 1.2 \
  --threads 6 \
  --prompt "$(cat "$PROMPT_SISTEMA") $(cat "$PROMPT_FILE")" 2>&1 | grep -v 'llama_' | tee >(tee -a "$LOG_PATH") >> "$TEMP_OUT"

# === ✂️ 出力をフィルタし、役立つ応答のみを残す（バイナリ名や技術的な行を削除） ===
sed -n '/\[\[/,/\]\]/p' "$TEMP_OUT" | sed 's/\[\[//;s/\]\]//' > "${TEMP_OUT}.clean"
mv "${TEMP_OUT}.clean" "$TEMP_OUT"

# === 🔄 応答がある場合、元のファイルを置き換え ===
if [[ -s "$TEMP_OUT" ]]; then
    cp "$TEMP_OUT" "$SESSION_PATH"
    mv "$TEMP_OUT" "$PROMPT_FILE"
    echo "✅ ファイル $PROMPT_FILE が応答で更新されました。"
else
    echo "⚠️ 応答が空です。元のファイルを保持します。"
    rm "$TEMP_OUT"
fi
