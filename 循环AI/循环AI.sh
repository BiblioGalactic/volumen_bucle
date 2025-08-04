#!/bin/bash
set -euo pipefail

# === 📂 相对路径 ===
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_SISTEMA="$DIR/循环提示.txt"
PROMPT_FILE="$DIR/连接.txt"
SESSIONS_FOLDER="$DIR/sesiones"
LOG_FOLDER="$DIR/logs"
mkdir -p "$SESSIONS_FOLDER" "$LOG_FOLDER"

NOMBRE_SESION="Sesion_$(date +'%Y-%m-%d_%H-%M-%S').md"
SESSION_PATH="$SESSIONS_FOLDER/$NOMBRE_SESION"
LOG_PATH="$LOG_FOLDER/salida.log"

MODELO_PATH="$DIR/mistral-7b-instruct-v0.1.Q6_K.gguf"
MAIN_BINARY="$DIR/llama-cli"

[[ ! -f "$PROMPT_FILE" ]] && { echo "❌ 未找到输入文件: $PROMPT_FILE"; exit 1; }

# === ⚙️ 使用文件输入运行模型并临时捕获响应 ===
TEMP_OUT=$(mktemp)

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  --ctx-size 31000 \
  --n-predict 500 \
  --color \
  --temp 1.2 \
  --threads 6 \
  --prompt "$(cat "$PROMPT_SISTEMA") $(cat "$PROMPT_FILE")" 2>&1 | grep -v 'llama_' | tee >(tee -a "$LOG_PATH") >> "$TEMP_OUT"

# === ✂️ 过滤输出，只保留有用的响应（删除包含二进制名称或技术启动的行） ===
sed -n '/\[\[/,/\]\]/p' "$TEMP_OUT" | sed 's/\[\[//;s/\]\]//' > "${TEMP_OUT}.clean"
mv "${TEMP_OUT}.clean" "$TEMP_OUT"

# === 🔄 如果有响应，替换原始文件 ===
if [[ -s "$TEMP_OUT" ]]; then
    cp "$TEMP_OUT" "$SESSION_PATH"
    mv "$TEMP_OUT" "$PROMPT_FILE"
    echo "✅ 文件 $PROMPT_FILE 已用响应更新。"
else
    echo "⚠️ 响应为空。保留原始文件。"
    rm "$TEMP_OUT"
fi
