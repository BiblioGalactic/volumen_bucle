#!/usr/bin/env bash
# ============================================================
# === MISTRAL 会話スクリプト =================================
# ============================================================
# ============================================================
# === 作者: Gustavo Silva Da Costa ===========================
# === スクリプト: Mistral 会話 ==============================
# === 説明: 言語モデルを使用して共感的な会話を生成し、 ===
# ===       履歴を自動保存、テンポラリファイルを自動で削除 ===
# === 日付: 2025 ============================================
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# 設定
# ============================================================
read -e -p "モデルのパス: " MODELO_PATH_INPUT
MODELO_PATH="${MODELO_PATH_INPUT:-$HOME/mistral-7b-instruct-v0.1.Q6_K.gguf}"

read -e -p "バイナリのパス: " MAIN_BINARY_INPUT
MAIN_BINARY="${MAIN_BINARY_INPUT:-$HOME/llama.cpp/build/bin/llama-cli}"

read -e -p "メモリファイルのパス: " MEMORIA_INPUT
MEMORIA="${MEMORIA_INPUT:-$HOME/conversacion.txt}"

read -e -p "一時ディレクトリのパス: " TEMP_DIR_INPUT
TEMP_DIR="${TEMP_DIR_INPUT:-$HOME/temp}"

# ============================================================
# 関数
# ============================================================

generate_sentence() {
  # 主語
  local subjects=(
    "友達" "仲間" "同僚" "親友" "愛しい人" "恋人" "姉妹" "人生" "ベイビー" "少女" "女性" "女王" "美しい" "子供" "可愛い"
    "貴重" "宝物" "太陽" "月" "星" "天使" "プリンセス" "女神" "赤ちゃん" "人形" "スイート" "奇跡" "宝石" "美麗"
  )

  # 動詞
  local verbs=(
    "教えてくれた" "考えている" "信じている" "望んでいる" "感じている" "提案した" "書いてくれた" "告白した" "いつも言っている"
    "大声で言った" "確信している" "理解できない" "繰り返している" "主張した" "困っている" "怖がっている"
  )

  # 行動／状態
  local actions=(
    "すべてうまくいく" "話す必要がある" "疲れた" "もう信じない" "繰り返される" "状況が違う" "以前と同じではない" "何かおかしい"
    "距離を置いている" "閉じこもっている" "表情に出ている" "物事がうまくいかない" "私たちの間で変化があった" "重い感じ"
    "すべてぎこちない" "笑い方が違う" "重要な話題を避ける" "迷っている" "居場所が見つからない" "違うものを探している" "変わりたい"
  )

  # 間接目的語
  local comp_ind=(
    "母に" "私に" "あなたに" "私たちに" "上司に" "元恋人に" "誰にも" "チームに" "姉妹に" "みんなに"
  )

  # 状況補語
  local comp_circ=(
    "朝に" "家で" "ずっと" "慎重に" "考えずに" "再び" "結局" "静かに" "理由もなく" "突然"
  )

  # 接続詞
  local connectors=(
    "しかし" "けれども" "そして" "だから" "その後" "それで" "ただし" "最終的に" "したがって"
  )

  # 結末
  local closures=(
    "どう思えばいいかわからない。" "多分彼女が正しい。" "私もそう感じる。" "こうなるとは思わなかった。" "様子を見よう。"
  )

  # 強調詞
  local intensifiers=("" "とても" "本当に" "絶対に" "完全に" "スーパー" "極めて")

  # 追加の感情
  local emotions=("" "涙目で" "感動して震える" "幸福に満ちて" "笑い転げる")

  # ランダム選択
  local subject="${subjects[$RANDOM % ${#subjects[@]}]}"
  local verb="${verbs[$RANDOM % ${#verbs[@]}]}"
  local intens="${intensifiers[$RANDOM % ${#intensifiers[@]}]}"
  local action="${actions[$RANDOM % ${#actions[@]}]}"
  local indirect="${comp_ind[$RANDOM % ${#comp_ind[@]}]}"
  local circum="${comp_circ[$RANDOM % ${#comp_circ[@]}]}"
  local emotion="${emotions[$RANDOM % ${#emotions[@]}]}"
  local connector="${connectors[$RANDOM % ${#connectors[@]}]}"
  local closure="${closures[$RANDOM % ${#closures[@]}]}"

  local sentence="$subject $verb"
  [[ -n "$intens" ]] && sentence="$sentence $intens"
  sentence="$sentence $action $indirect $circum"
  [[ -n "$emotion" ]] && sentence="$sentence $emotion"
  sentence="$sentence, $connector $closure"

  echo "$sentence"
}

cleanup() {
  rm -rf "$TEMP_DIR" 2>/dev/null || true
}

# ============================================================
# メイン処理
# ============================================================
trap cleanup EXIT

mkdir -p "$TEMP_DIR"
mkdir -p "$(dirname "$MEMORIA")"
touch "$MEMORIA"

# ============================================================
# 1回目の実行
# ============================================================
sentence="$(generate_sentence)"
echo -e "\n💬 [Gustavo]: $sentence"
echo "$sentence" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt1.txt" << EOF
あなたは共感的なアシスタントです。1〜2文で簡潔に答えてください。

$(tail -8 "$MEMORIA")

EOF

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  -f "$TEMP_DIR/prompt1.txt" \
  --ctx-size 4096 \
  --n-predict 100 \
  --temp 0.8 \
  --threads 12 \
  > "$TEMP_DIR/output1.txt" 2>&1

sleep 1

grep -v "llama_\|print_\|system_\|sampler\|generate\|load\|init:\|build:\|ggml_\|common_\|repeat_\|top_k\|mirostat\|warming\|Press\|==\|\.\.\.\.\.\.\." "$TEMP_DIR/output1.txt" \
  | sed 's/\[end of text\]//g' \
  | sed 's/^ASSISTANT: //g' \
  | tail -3 \
  | head -1 \
  > "$TEMP_DIR/clean1.txt"

if [[ -s "$TEMP_DIR/clean1.txt" ]]; then
  echo -n -e "\n🤖 [Mistral]: "
  cat "$TEMP_DIR/clean1.txt" | tr '\n' ' '
  echo -e "\n"
  echo "$(cat "$TEMP_DIR/clean1.txt" | tr '\n' ' ')" >> "$MEMORIA"
else
  echo "❌ 返答なし" >&2
fi

# ============================================================
# 2回目の実行
# ============================================================
sentence2="$(generate_sentence)"
echo -e "\n💬 [Gustavo]: $sentence2"
echo "$sentence2" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt2.txt" << EOF
あなたは共感的なアシスタントです。1〜2文で簡潔に答えてください。

$(tail -8 "$MEMORIA")

EOF

"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  -f "$TEMP_DIR/prompt2.txt" \
  --ctx-size 4096 \
  --n-predict 100 \
  --temp 0.8 \
  --threads 12 \
  > "$TEMP_DIR/output2.txt" 2>&1

sleep 1

grep -v "llama_\|print_\|system_\|sampler\|generate\|load\|init:\|build:\|ggml_\|common_\|repeat_\|top_k\|mirostat\|warming\|Press\|==\|\.\.\.\.\.\.\." "$TEMP_DIR/output2.txt" \
  | sed 's/\[end of text\]//g' \
  | sed 's/^ASSISTANT: //g' \
  | tail -3 \
  | head -1 \
  > "$TEMP_DIR/clean2.txt"

if [[ -s "$TEMP_DIR/clean2.txt" ]]; then
  echo -n -e "\n🤖 [Mistral]: "
  cat "$TEMP_DIR/clean2.txt" | tr '\n' ' '
  echo -e "\n"
  echo "$(cat "$TEMP_DIR/clean2.txt" | tr '\n' ' ')" >> "$MEMORIA"
else
  echo "❌ 2回目の実行で返答なし" >&2
fi
