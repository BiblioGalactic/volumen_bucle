#!/usr/bin/env bash
# ============================================================
# === MISTRAL CONVERSATION SCRIPT ===========================
# ============================================================
# ============================================================
# === AUTHOR: Gustavo Silva Da Costa ========================
# === SCRIPT: Mistral Conversation =========================
# === DESCRIPTION: Generates empathetic conversations ======
# === with a language model, saving history and cleaning ====
# === temporary files automatically =========================
# === DATE: 2025 ===========================================
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONFIGURATION
# ============================================================
read -e -p "Path to the model: " MODELO_PATH_INPUT
MODELO_PATH="${MODELO_PATH_INPUT:-$HOME/mistral-7b-instruct-v0.1.Q6_K.gguf}"

read -e -p "Path to the binary: " MAIN_BINARY_INPUT
MAIN_BINARY="${MAIN_BINARY_INPUT:-$HOME/llama.cpp/build/bin/llama-cli}"

read -e -p "Path to memory file: " MEMORIA_INPUT
MEMORIA="${MEMORIA_INPUT:-$HOME/conversacion.txt}"

read -e -p "Path to temporary directory: " TEMP_DIR_INPUT
TEMP_DIR="${TEMP_DIR_INPUT:-$HOME/temp}"

# ============================================================
# FUNCTIONS
# ============================================================

generate_sentence() {
# SUBJECTS - Expanded with emotional and cultural variety
  local subjects=(
    "Friend" "Companion" "Colleague" "Buddy" "Sweetheart" "Dear" "Love" "Sister" "Life" "Honey" "Girl" "Lady" "Queen" "Beautiful" "Child"
    "Cute" "Precious" "Treasure" "Sun" "Moon" "Star" "Angel" "Princess" "Goddess" "Baby" "Doll" "Sweetie" "Darling" "Wonder" "Gem"
    "Lovely" "Pretty" "Brunette" "Blonde" "Redhead" "Girl" "Young woman" "Miss" "Lady" "Muse" "Venus" "Aphrodite" "Mermaid" "Fairy" "Witch" "Seer"
    "Godmother" "Sister-in-law" "Cousin" "Niece" "Goddaughter" "Neighbor" "Buddy" "Partner" "Ally" "Confidante" "Advisor"
    "My girl" "My life" "My soul" "My everything" "My world" "My light" "My hope" "My refuge" "My strength" "My weakness" "My downfall" "My salvation"
  )

# VERBS - Expanded forms to communicate and express
  local verbs=(
    "told me" "thinks that" "believes that" "wants" "feels that" "hopes that" "suggests that" "wrote to me that" "confessed that" "keeps saying that"
    "said out loud that" "is sure that" "does not understand that" "repeated that" "insists that" "is annoyed that" "is afraid that"
    "whispered that" "shouted that" "cried saying that" "complained that" "lamented that" "admitted that" "denied that" "swore that"
    "promised that" "threatened that" "pleaded that" "demanded that" "murmured that" "stammered that" "sighed that" "moaned that" "opened up saying that"
    "commented that" "clarified that" "explained that" "told that" "narrated that" "detailed that" "specified that" "confirmed that" "corrected that"
    "intuits that" "foresees that" "suspects that" "imagines that" "assumes that" "deduces that" "concludes that" "interprets that" "understands that" "perceives that"
    "fears that" "is anxious because" "worries that" "is uneasy that" "feels overwhelmed that" "stresses thinking that" "obsesses that" "torments self because"
    "gets emotional because" "is glad that" "gets excited that" "is thrilled thinking that" "cheers because" "enjoys that" "delights in that" "is angry because"
    "is upset that" "is annoyed that" "is irritated because" "is outraged that" "rebels that" "protests because" "claims that"
  )

# ACTIONS - Emotional states and expanded situations
  local actions=(
    "everything will be fine" "we need to talk" "is tired" "doesn't trust anymore" "everything repeats" "this is different" "it's not the same" "something is off"
    "I am drifting away" "you are closing yourself off" "it's visible on her face" "things are not flowing" "something changed between us" "things feel heavy"
    "everything seems forced" "she doesn't laugh the same" "avoids important topics" "feels lost" "can't find her place" "seeks something different" "wants a change"
    "needs time for herself" "is confused" "doesn't know what she wants" "is rediscovering herself" "is afraid of the future" "fears aging" "feels overwhelmed with responsibilities"
    "feels trapped" "wants to escape everything" "needs freedom" "suffers in the routine" "is in love" "found someone" "feels special" "radiates happiness"
    "is in the clouds" "lives a fairy tale" "feels complete" "found her other half" "is jealous" "suspects everyone" "can't help comparing" "feels inferior" "is envious"
    "is hurt" "feels betrayed" "can't forgive" "has trouble forgetting" "lives in the past" "can't move on" "is tormented remembering" "doesn't understand what happened"
    "is strong" "feels invincible" "learned to value herself" "knows her worth" "accepts nothing less than deserved" "matured a lot" "is at her best" "is vulnerable"
    "feels fragile" "needs protection" "seeks refuge" "wants to be cared for" "feels small" "needs affection" "is sensitive" "seeks revenge" "is plotting" "won't stay silent"
    "will defend herself" "no longer lets herself be stepped on" "has awakened" "is not the same as before" "is grateful" "appreciates what she has" "feels lucky" "counts her blessings"
    "enjoys small details" "lives in the present" "enjoys every moment"
  )

# INDIRECT COMPLEMENTS - To whom the action refers
  local comp_ind=(
    "to her mother" "to me" "to you" "to us" "to the boss" "to her ex" "to no one" "to the group" "to her sister" "to everyone" "to each one"
    "to someone" "to whoever wants to hear" "to the teacher" "to her friend" "to that person" "to her father" "to her partner" "to her boyfriend" "to her husband"
    "to her crush" "to her fling" "to the guy she likes" "to her platonic love" "to her mother-in-law" "to her sister-in-law" "to her daughter-in-law" "to her children"
    "to the family" "to relatives" "to her colleagues" "to her confidante" "to the WhatsApp group" "to the gang" "to the girls" "to social media" "to Instagram"
    "to Facebook" "to Twitter" "to the whole world" "to humanity" "to the universe" "to her diary" "to her blog" "to her channel" "to her podcast" "to her audience"
    "to her fans" "to her readers" "to her subscribers" "to the mirror" "to the walls" "to her pillow" "to the stars" "to the moon" "to the wind" "to the sea" "to nature"
  )

# CIRCUMSTANTIAL COMPLEMENTS - When, how, where
  local comp_circ=(
    "in the morning" "at home" "since always" "carefully" "without thinking" "again" "in the end" "in silence" "for no reason" "suddenly" "as before"
    "in a low voice" "instantly" "in a weird way" "last time" "while crying" "when no one was watching" "at night" "at dawn" "at sunset" "in the early morning"
    "during breakfast" "at dinner" "at midnight" "at work" "at the office" "at the gym" "at the spa" "in the bathroom" "in the kitchen" "in the bedroom" "in the living room"
    "on the terrace" "in the garden" "in the car" "on the subway" "on the bus" "walking down the street" "at the cafe" "at the restaurant" "at the bar" "at the club" "at the mall"
    "at the hairdresser" "at the supermarket" "while shopping" "on the phone" "via WhatsApp" "via message" "via video call" "via email" "via letter" "through a friend" "indirectly"
    "crying" "laughing" "shouting" "whispering" "trembling" "blushing" "sighing" "sobbing" "in tears" "with a broken voice"
    "drunk" "smoking" "eating chocolate" "drinking wine" "having coffee" "after yoga" "after meditation" "in therapy" "at the psychologist" "after sex" "in bed" "hugging" "kissing" "caressing"
    "while combing hair" "applying cream" "naked" "in pajamas" "very nervous" "completely relaxed" "super excited" "totally exhausted" "half asleep" "just woke up" "without makeup" "getting ready"
    "during the movie" "watching TV" "reading" "listening to music" "dancing" "cooking" "cleaning" "organizing" "working" "studying" "in the park" "on the beach" "in the mountains" "in the countryside" "traveling"
    "on vacation" "abroad" "far from home" "in her town" "very sincerely" "very seriously" "half joking" "sarcastically" "ironically" "sweetly" "tenderly" "passionately" "angrily"
  )

# CONNECTORS - More variety of transitions
  local connectors=(
    "but" "although" "and" "because" "then" "so" "however" "in the end" "therefore" "anyway" "even so" "as if nothing" "suddenly" "even"
    "also" "too" "neither" "not even" "until" "except that" "unless" "despite" "even though" "however" "on the other hand" "meanwhile" "at the same time" "simultaneously"
    "consequently" "thus" "therefore" "so" "hence" "in other words" "that is" "actually" "in reality" "the truth is" "obviously" "clearly" "logically" "fortunately"
    "unfortunately" "sadly" "happily" "surprisingly" "incredibly" "honestly" "truly" "definitely"
  )

# CLOSURES - Endings with emotional variety
  local closures=(
    "I don't know what to think." "maybe she is right." "I feel it too." "I didn't want this to happen." "we'll have to see." "I find it hard to accept." "maybe it's enough already."
    "I deserve it." "I don't want to argue anymore." "I can't pretend anymore." "she noticed it too." "I kept quiet out of fear." "everything got messy." "I don't know if I would trust again." "I regret not saying it before."
    "It hurts me deeply." "my heart breaks." "I can't take this anymore." "I'm at my limit." "I need a break." "it is killing me inside." "I feel like I am suffocating." "I can't find a way out."
    "It makes me very happy." "I'm on cloud nine." "I can't stop smiling." "I feel complete." "It's the best thing that has happened to me." "thanks to life." "I am very lucky."
    "It makes me very angry." "I'm boiling." "I won't allow it." "we'll see who can do more." "she will find out." "this won't stay like this." "she will pay." "I will make her pay."
    "It makes me sad." "I am deeply sad." "I cry just thinking about it." "it breaks me in two." "it's unfair." "life is cruel." "I didn't deserve this." "it's hard to accept."
    "I am very confused." "I don't know what to do." "I need time to think." "I feel lost." "everything is very confusing." "I have no clear ideas." "I need to put order in my head."
    "I am very scared." "I fear what might happen." "I don't even want to think about it." "I panic." "I tremble just imagining." "I'd rather not know." "better nothing happens."
    "I am very proud." "I feel satisfied." "I made it." "the effort was worth it." "I am where I wanted." "I achieved my dream." "I am very fortunate."
    "I feel guilty." "I should have done more." "it was my fault." "I blame myself." "I can't forgive myself." "I bear this guilt." "my conscience hurts."
    "I am very grateful." "I don't know how to repay." "I owe so much." "I will never forget." "I will always be grateful." "she is an angel in my life." "what would I do without her."
    "we'll see what happens." "time will tell." "we'll have to wait." "everything comes when it should." "if it has to be, it will be." "what will happen, will happen." "fate will decide."
    "I don't care anymore." "let it be what it will be." "I'm tired of fighting." "I don't care." "I don't care about anything." "let them do what they want." "it doesn't affect me anymore."
    "I will fight to the end." "I won't give up." "I will move forward." "I will achieve it." "I have to be strong." "they won't defeat me." "I will get through this."
    "I need to be alone." "I want to disappear." "I will take some time." "I need to find myself." "I will take care of myself." "it's my moment." "I deserve it."
    "everything will change." "something big is coming." "I sense something good is coming." "things will improve." "the best is yet to come." "better times are coming."
  )

# INTENSIFIERS - Add more drama
# Empty spaces to avoid always having an intensifier
  local intensifiers=(
    "" "" "" "" "" "" "" ""
    "really" "truly" "absolutely" "completely" "totally" "super" "ultra" "mega" "hyper" "extremely"
    "incredibly" "tremendously" "enormously" "deeply" "intensely" "passionately" "desperately"
    "very very" "simply" "undoubtedly" "categorically" "absolutely" "clearly"
  )

# ADDITIONAL EMOTIONS - Empty spaces for variety
  local emotions=(
    "" "" "" "" "" ""
    "with tears in the eyes" "trembling with emotion" "radiant with happiness" "dying of laughter" "crazy with joy" "full of love"
    "broken with pain" "devastated" "wrecked" "sunk" "shattered" "inconsolable"
    "furious" "indignant" "mad" "annoyed" "very angry" "fuming" "blind with rage"
    "nervous as a flan" "anxious" "overwhelmed" "very stressed" "worried" "uneasy"
    "extremely excited" "euphoric" "exuberant" "jubilant" "overflowing with happiness" "overjoyed"
  )

# Random selection of elements
  local subject="${subjects[$RANDOM % ${#subjects[@]}]}"
  local verb="${verbs[$RANDOM % ${#verbs[@]}]}"
  local intens="${intensifiers[$RANDOM % ${#intensifiers[@]}]}"
  local action="${actions[$RANDOM % ${#actions[@]}]}"
  local indirect="${comp_ind[$RANDOM % ${#comp_ind[@]}]}"
  local circum="${comp_circ[$RANDOM % ${#comp_circ[@]}]}"
  local emotion="${emotions[$RANDOM % ${#emotions[@]}]}"
  local connector="${connectors[$RANDOM % ${#connectors[@]}]}"
  local closure="${closures[$RANDOM % ${#closures[@]}]}"

# Construct sentence
  local sentence="$subject $verb"

# Add intensifier if present
  if [[ -n "$intens" ]]; then
    sentence="$sentence $intens"
  fi

  sentence="$sentence $action $indirect $circum"

# Add emotion if present
  if [[ -n "$emotion" ]]; then
    sentence="$sentence $emotion"
  fi

  sentence="$sentence, $connector $closure"

  echo "$sentence"
}


cleanup() {
  rm -rf "$TEMP_DIR" 2>/dev/null || true
}

# ============================================================
# MAIN
# ============================================================
trap cleanup EXIT

mkdir -p "$TEMP_DIR"
mkdir -p "$(dirname "$MEMORIA")"
touch "$MEMORIA"

# ============================================================
# FIRST EXECUTION
# ============================================================

sentence="$(generate_sentence)"
echo -e "\n💬 [Gustavo]: $sentence"
echo "$sentence" >> "$MEMORIA"

# Build simple prompt
cat > "$TEMP_DIR/prompt1.txt" << EOF
You are an empathetic assistant. Respond in 1-2 short sentences.

$(tail -8 "$MEMORIA")

EOF

# Run model
"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  -f "$TEMP_DIR/prompt1.txt" \
  --ctx-size 4096 \
  --n-predict 100 \
  --temp 0.8 \
  --threads 12 \
  > "$TEMP_DIR/output1.txt" 2>&1

sleep 1

# Extract response (last 5 lines without technical noise)
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
  echo "❌ No response" >&2
fi

# ============================================================
# SECOND EXECUTION
# ============================================================

sentence2="$(generate_sentence)"
echo -e "\n💬 [Gustavo]: $sentence2"
echo "$sentence2" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt2.txt" << EOF
You are an empathetic assistant. Respond in 1-2 short sentences.

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
  echo "❌ No response in second execution" >&2
fi
