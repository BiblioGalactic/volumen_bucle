#!/usr/bin/env bash
# ============================================================
# === MISTRAL 会话脚本 ======================================
# ============================================================
# ============================================================
# === 作者: Gustavo Silva Da Costa ===========================
# === 脚本: Mistral 会话 ====================================
# === 描述: 使用语言模型生成共情对话，自动保存历史 ====
# ===       并清理临时文件 =================================
# === 日期: 2025 ===========================================
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# 配置
# ============================================================
read -e -p "模型路径: " MODELO_PATH_INPUT
MODELO_PATH="${MODELO_PATH_INPUT:-$HOME/mistral-7b-instruct-v0.1.Q6_K.gguf}"

read -e -p "二进制文件路径: " MAIN_BINARY_INPUT
MAIN_BINARY="${MAIN_BINARY_INPUT:-$HOME/llama.cpp/build/bin/llama-cli}"

read -e -p "内存文件路径: " MEMORIA_INPUT
MEMORIA="${MEMORIA_INPUT:-$HOME/conversacion.txt}"

read -e -p "临时目录路径: " TEMP_DIR_INPUT
TEMP_DIR="${TEMP_DIR_INPUT:-$HOME/temp}"

# ============================================================
# 函数
# ============================================================

generate_sentence() {
  # 主语
  local subjects=(
    "朋友" "伙伴" "同事" "好友" "亲爱的" "爱人" "姐妹" "生命" "宝贝" "女孩" "女士" "女王" "漂亮" "孩子" "可爱"
    "珍贵" "宝物" "太阳" "月亮" "星星" "天使" "公主" "女神" "婴儿" "玩偶" "甜心" "奇迹" "珠宝" "美丽"
  )

  # 动词
  local verbs=(
    "告诉我" "认为" "相信" "希望" "觉得" "希望" "建议" "写信告诉我" "坦白说" "总是说"
    "大声说" "确信" "不理解" "重复说" "坚持" "烦恼" "害怕"
  )

  # 动作/状态
  local actions=(
    "一切都会好" "需要谈谈" "累了" "不再信任" "一切重复" "情况不同" "不再一样" "有点不对劲"
    "我在疏远" "你关闭自己" "可以看出她的表情" "事情不顺" "我们之间有变化" "事情很沉重"
    "一切看起来很勉强" "她笑得不一样" "避免重要话题" "感到迷茫" "找不到位置" "寻求不同" "想要改变"
  )

  # 间接补语
  local comp_ind=(
    "对她母亲" "对我" "对你" "对我们" "对老板" "对前任" "对没人" "对团队" "对她姐妹" "对所有人"
  )

  # 情境补语
  local comp_circ=(
    "在早上" "在家" "一直以来" "小心地" "不假思索" "再次" "最终" "安静地" "无缘无故" "突然"
  )

  # 连接词
  local connectors=(
    "但是" "虽然" "而且" "因为" "然后" "所以" "然而" "最后" "因此"
  )

  # 结尾
  local closures=(
    "我不知道该怎么想。" "也许她是对的。" "我也有同感。" "我不希望这样发生。" "我们拭目以待。"
  )

  # 强调词
  local intensifiers=("" "非常" "真的" "绝对" "完全" "超级" "极度")

  # 额外情感
  local emotions=("" "眼含泪水" "激动地颤抖" "幸福洋溢" "笑到不行")

  # 随机选择
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
# 主程序
# ============================================================
trap cleanup EXIT

mkdir -p "$TEMP_DIR"
mkdir -p "$(dirname "$MEMORIA")"
touch "$MEMORIA"

# ============================================================
# 第一次执行
# ============================================================
sentence="$(generate_sentence)"
echo -e "\n💬 [Gustavo]: $sentence"
echo "$sentence" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt1.txt" << EOF
你是一个有同理心的助手。请用1-2句简短回答。

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
  echo "❌ 没有回应" >&2
fi

# ============================================================
# 第二次执行
# ============================================================
sentence2="$(generate_sentence)"
echo -e "\n💬 [Gustavo]: $sentence2"
echo "$sentence2" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt2.txt" << EOF
你是一个有同理心的助手。请用1-2句简短回答。

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
  echo "❌ 第二次执行没有回应" >&2
fi
