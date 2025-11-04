#!/usr/bin/env bash
# ============================================================
# === SCRIPT DE CONVERSATION AVEC MISTRAL ===================
# ============================================================
# ============================================================
# === AUTEUR : Gustavo Silva Da Costa =======================
# === SCRIPT : Conversation avec Mistral ===================
# === DESCRIPTION : Génère des conversations empathiques avec ==
# === un modèle de langage, en sauvegardant l'historique et ===
# === en nettoyant automatiquement les fichiers temporaires ==
# === DATE : 2025 ==========================================
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONFIGURATION
# ============================================================
read -e -p "Chemin du modèle : " MODELO_PATH_INPUT
MODELO_PATH="${MODELO_PATH_INPUT:-$HOME/mistral-7b-instruct-v0.1.Q6_K.gguf}"

read -e -p "Chemin du binaire : " MAIN_BINARY_INPUT
MAIN_BINARY="${MAIN_BINARY_INPUT:-$HOME/llama.cpp/build/bin/llama-cli}"

read -e -p "Chemin vers le fichier de mémoire : " MEMORIA_INPUT
MEMORIA="${MEMORIA_INPUT:-$HOME/conversacion.txt}"

read -e -p "Chemin du répertoire temporaire : " TEMP_DIR_INPUT
TEMP_DIR="${TEMP_DIR_INPUT:-$HOME/temp}"

# ============================================================
# FONCTIONS
# ============================================================

generar_frase() {
# SUJETS - Étendu avec plus de variété émotionnelle et culturelle
  local sujetos=( 
    "Amie" "Compagne" "Collègue" "Camarade" "Ciel" "Chérie" "Amour" "Sœur" "Vie" "Chérie" "Petite" "Tante" "Belle" "Reine" "Jolie" "Fille" "Charmante" "Cœur"
    "Jolie" "Précieuse" "Trésor" "Soleil" "Lune" "Étoile" "Ange" "Princesse" "Déesse" "Bébé" "Poupée" "Délice" "Douceur" "Bonbon" "Merveille" "Bijou"
    "Magnifique" "Belle" "Brune" "Blonde" "Rousse" "Fille" "Jeune femme" "Demoiselle" "Dame" "Muse" "Vénus" "Aphrodite" "Sirène" "Fée" "Sorcelle" "Voyante"
    "Comparse" "Belle-sœur" "Cousine" "Nièce" "Marraine" "Filleule" "Voisine" "Complice" "Associée" "Partenaire" "Alliée" "Complice" "Confidente" "Conseillère"
    "Ma fille" "Ma vie" "Mon âme" "Mon tout" "Mon monde" "Ma lumière" "Mon espoir" "Mon refuge" "Ma force" "Ma faiblesse" "Ma perdition" "Mon salut"
  )
  
# VERBES - Plus de formes pour communiquer et exprimer
  local verbos=( 
    "m'a dit" "pense que" "croit que" "veut que" "sent que" "espère que" "suggère que" "m'a écrit que" "m'a avoué que" "on dit que" "m'a lâché que" "est sûre que" "ne comprend pas que" "me répète que" "insiste pour que" "ça la gêne que" "ça lui fait peur que"
    "a chuchoté que" "a crié que" "a pleuré en disant que" "s'est plainte que" "regrette que" "a admis que" "a nié que" "a juré que" "a promis que" "a menacé que" "a supplié que" "a exigé que"
    "a murmuré que" "a balbutié que" "a bégayé que" "a soupiré que" "a gémis que" "s'est déchargée en disant que" "s'est confiée que" "s'est ouverte en me racontant que" "s'est effondrée en disant que"
    "m'a commenté que" "m'a précisé que" "m'a expliqué que" "m'a raconté que" "m'a narré que" "m'a détaillé que" "m'a spécifié que" "m'a confirmé que" "m'a corrigé que"
    "devine que" "pressent que" "suspecte que" "imagine que" "suppose que" "présume que" "déduit que" "conclut que" "interprète que" "comprend que" "perçoit que"
    "craint que" "s'angoisse parce que" "s'inquiète que" "est troublée que" "est stressée en pensant que" "s'obsède que" "se tourmente parce que"
    "s'émotionne parce que" "se réjouit que" "s'enthousiasme que" "s'illusionne en pensant que" "s'anime parce que" "célèbre que" "profite que" "jouit que"
    "se fâche parce que" "s'énerve que" "est irritée que" "est contrariée parce que" "s'indigne que" "se rebelle contre que" "proteste parce que" "réclame que"
  )
  
# ACTIONS - États émotionnels et situations étendues
  local acciones=( 
    "tout ira bien" "nous devons parler" "elle est fatiguée" "elle ne fait plus confiance" "tout se répète" "c'est différent" "ce n'est plus pareil" "quelque chose cloche" "je m'éloigne" "tu te refermes" "on le voit sur son visage" "les choses ne coulent pas" "quelque chose a changé entre nous" "les choses pèsent" "tout semble forcé" "elle ne rit plus pareil" "elle évite les sujets importants"
    "elle se sent perdue" "elle ne trouve pas sa place" "elle cherche autre chose" "elle veut changer d'air" "elle a besoin de temps pour elle" "elle est confuse" "elle ne sait pas ce qu'elle veut" "elle se redécouvre"
    "elle a peur du futur" "elle redoute de vieillir" "elle est submergée par les responsabilités" "elle se sent prise au piège" "elle veut tout fuir" "elle a besoin de liberté" "elle s'étouffe dans la routine"
    "elle est amoureuse" "elle a rencontré quelqu'un" "elle se sent spéciale" "elle brille de bonheur" "elle est sur un nuage" "elle vit un conte de fées" "elle se sent complète" "elle a trouvé son âme sœur"
    "elle est jalouse" "elle soupçonne tout le monde" "elle ne peut s'empêcher de se comparer" "elle se sent inférieure" "la jalousie la ronge" "elle vit dans l'insécurité" "elle doute d'elle-même"
    "elle est blessée" "elle se sent trahie" "elle ne peut pardonner" "elle a du mal à oublier" "elle vit dans le passé" "elle n'arrive pas à tourner la page" "elle est tourmentée par des souvenirs" "elle ne comprend pas ce qui s'est passé"
    "elle est forte" "elle se sent invincible" "elle a appris à s'estimer" "elle sait ce qu'elle vaut" "elle n'accepte pas moins que ce qu'elle mérite" "elle a beaucoup mûri" "elle est à son meilleur"
    "elle est vulnérable" "elle se sent fragile" "elle a besoin de protection" "elle cherche un refuge" "elle veut qu'on prenne soin d'elle" "elle se sent petite" "elle a besoin de câlins" "elle est sensible"
    "elle veut se venger" "elle prépare quelque chose" "elle ourdit un plan" "elle ne se tiendra pas tranquille" "elle va se défendre" "elle ne se laisse plus marcher dessus" "elle s'est réveillée" "elle n'est plus la même"
    "elle est reconnaissante" "elle apprécie ce qu'elle a" "elle se sent chanceuse" "elle compte ses bénédictions" "elle savoure les petits détails" "elle vit le présent" "elle profite de chaque instant"
  )
  
# COMPLÉMENTS INDIRECTS - À qui cela se réfère, étendu
  local comp_ind=( 
    "à sa mère" "à moi" "à toi" "à nous" "au patron" "à son ex" "à personne" "au groupe" "à sa sœur" "à tout le monde" "à chacune" "à quelqu'un" "à vous" "à qui veut l'écouter" "au professeur" "à son amie" "à cette personne"
    "à son père" "à son/sa partenaire" "à son petit ami" "à son mari" "à son époux" "à son crush" "à sa conquête" "à sa relation" "au garçon qu'elle aime" "à son amour platonique"
    "à sa belle-mère" "à sa belle-sœur" "à sa belle-fille" "à son beau-fils" "à ses enfants" "à sa fille" "à son fils" "à ses petits-enfants" "à la famille" "aux proches"
    "à ses amies" "à sa meilleure amie" "à sa confidente" "à sa compagne" "au groupe WhatsApp" "aux filles" "à la bande" "à son cercle intime"
    "à sa psychologue" "à sa thérapeute" "à son coach" "à sa mentor" "à sa conseillère" "à son guide spirituel" "à sa cartomancienne" "à sa voyante"
    "à sa cheffe" "à ses collègues" "à son équipe" "à ses subordonnées" "aux ressources humaines" "à l'entreprise" "au syndicat"
    "à sa voisine" "à la concierge" "à la coiffeuse" "à la manucure" "à l'esthéticienne" "à la masseuse" "à sa coach sportive"
    "aux réseaux sociaux" "à Instagram" "à ses abonnés" "à Facebook" "à Twitter" "au monde entier" "à l'humanité" "à l'univers"
    "à son journal" "à son blog" "à sa chaîne" "à son podcast" "à son audience" "à ses fans" "à ses lecteurs" "à ses abonnés"
    "au miroir" "aux murs" "à son oreiller" "aux étoiles" "à la lune" "au vent" "à la mer" "à la nature"
  )
  
# COMPLÉMENTS CIRCONSTANCIELS - Quand, comment, où
  local comp_circ=( 
    "le matin" "à la maison" "depuis toujours" "avec précaution" "sans réfléchir" "à nouveau" "à la fin" "en silence" "sans raison" "d'un coup" "comme avant" "à voix basse" "immédiatement" "d'une manière étrange" "la dernière fois" "en pleurant" "quand personne ne regardait"
    "la nuit" "au lever du jour" "au coucher du soleil" "au petit matin" "pendant le petit-déjeuner" "au dîner" "à minuit" "au travail" "au bureau" "à la salle de sport" "au spa"
    "dans la salle de bain" "dans la cuisine" "dans la chambre" "dans le salon" "sur la terrasse" "dans le jardin" "dans la voiture" "dans le métro" "dans le bus" "en marchant dans la rue"
    "au café" "au restaurant" "au bar" "en boîte" "au centre commercial" "chez la coiffeuse" "au supermarché" "en faisant les courses"
    "au téléphone" "sur WhatsApp" "par message" "en appel vidéo" "par email" "par lettre" "par carte postale" "par l'intermédiaire d'un ami" "indirectement"
    "en pleurant" "en riant" "en criant" "en chuchotant" "tremblante" "en rougissant" "en soupirant" "en sanglotant" "entre larmes" "la voix brisée"
    "ivre" "en fumant" "mangeant du chocolat" "buvant du vin" "prenant un café" "après le yoga" "après la méditation" "en thérapie" "chez le psychologue"
    "après le sexe" "dans le lit" "en m'enlaçant" "en m'embrassant" "en me caressant" "en me coiffant" "en appliquant de la crème" "nue" "en pyjama"
    "très nerveuse" "complètement détendue" "super excitée" "totalement épuisée" "à moitié endormie" "récemment réveillée" "sans maquillage" "en se préparant"
    "pendant le film" "en regardant la télé" "en lisant" "en écoutant de la musique" "en dansant" "en cuisinant" "en nettoyant" "en rangeant" "en travaillant" "en étudiant"
    "au parc" "à la plage" "à la montagne" "à la campagne" "en voyage" "en vacances" "à l'étranger" "loin de chez elle" "dans son village"
    "avec totale sincérité" "très au sérieux" "à moitié en plaisantant" "avec sarcasme" "ironiquement" "avec douceur" "avec tendresse" "avec passion" "avec colère"
  )
  
# CONNECTEURS - Plus de variété de transitions
  local conectores=( 
    "mais" "bien que" "et" "parce que" "alors" "donc" "cependant" "finalement" "c'est pourquoi" "de toute façon" "quand même" "même si" "comme si de rien n'était" "soudain" "même"
    "de plus" "aussi" "non plus" "pas même" "jusqu'à" "seulement que" "sauf que" "à moins que" "sauf si" "malgré que" "alors que" "toutefois"
    "au contraire" "en revanche" "pendant ce temps" "à la fois" "en même temps" "simultanément" "parallèlement" "en parallèle"
    "en conséquence" "par conséquent" "donc" "ainsi" "de ce fait" "de sorte que" "de manière que" "ce qui fait que"
    "c'est-à-dire" "autrement dit" "en d'autres termes" "dit autrement" "plutôt" "en réalité" "la vérité est que" "le fait est que"
    "premièrement" "deuxièmement" "troisièmement" "puis" "ensuite" "plus tard" "auparavant" "préalablement" "finalement" "pour finir"
    "évidemment" "manifestement" "clairement" "bien sûr" "naturellement" "logiquement" "compréhensiblement" "à juste titre"
    "heureusement" "malheureusement" "hélas" "tristement" "joyeusement" "surprenamment" "incroyablement"
    "franchement" "honnêtement" "sincèrement" "vraiment" "véritablement" "effectivement" "certainement" "définitivement"
    "peut-être" "sans doute" "possiblement" "probablement" "sûrement" "apparemment" "prétendument" "présumément"
  )
  
# FERMETURES - Finales étendus avec plus de variété émotionnelle
  local cierres=( 
    "je ne sais pas quoi penser." "peut-être qu'elle a raison." "moi aussi je le ressens." "je ne voulais pas que ça se passe ainsi." "il faudra voir." "j'ai du mal à l'accepter." "peut-être que c'était suffisant." "peut-être que je le mérite." "je ne veux plus me disputer." "je ne peux plus faire semblant." "elle s'en est rendu compte aussi." "je me suis tu par peur." "tout s'est chamboulé." "je ne sais pas si je pourrais à nouveau faire confiance." "ça me pèse de ne pas l'avoir dit plus tôt."
    "ça me fait mal au cœur." "mon cœur se brise." "je n'en peux plus." "je suis à la limite." "j'ai besoin d'un répit." "ça me tue de l'intérieur." "j'ai l'impression de suffoquer." "je ne trouve pas la sortie."
    "ça me rend très heureuse." "je suis sur un nuage." "je n'arrête pas de sourire." "je me sens complète." "c'est la meilleure chose qui me soit arrivée." "merci la vie." "je suis la femme la plus chanceuse."
    "ça me met en rage." "je bouillonne." "je ne l'accepterai pas." "on verra qui est le plus fort." "elle va le savoir." "ça ne restera pas comme ça." "ça va coûter cher." "je vais lui rendre la pareille."
    "ça me rend très triste." "ça me déchire profondément." "je pleure rien qu'en y pensant." "ça me brise." "ce n'est pas juste." "la vie est cruelle." "elle ne méritait pas ça." "c'est dur à accepter."
    "je suis très confuse." "je ne sais pas quoi faire." "j'ai besoin de temps pour y réfléchir." "je me sens perdue." "tout est très confus." "je n'ai pas les idées claires." "j'ai besoin de remettre de l'ordre dans ma tête."
    "j'ai très peur." "ça me terrifie ce qui peut arriver." "je ne veux même pas y penser." "ça me panique." "je tremble rien qu'à l'imaginer." "je préfère ne rien savoir." "mieux vaut que rien n'arrive."
    "je suis très fière." "je me sens très satisfaite." "je l'ai fait." "ça valait l'effort." "je suis où je voulais être." "j'ai réalisé mon rêve." "je suis très chanceuse."
    "je me sens coupable." "j'aurais dû en faire plus." "c'était ma faute." "je me reproche de ne pas avoir agi." "je ne peux pas me pardonner." "je porte cette culpabilité." "ça me ronge la conscience."
    "je suis très reconnaissante." "je ne sais pas comment la remercier." "je lui dois tant." "je ne l'oublierai jamais." "je lui serai toujours reconnaissante." "c'est un ange dans ma vie." "que ferais-je sans elle."
    "on verra ce qui se passe." "le temps dira." "il faudra attendre." "tout arrive en son temps." "si ça doit être, ce sera." "ce qui doit arriver, arrivera." "le destin décidera."
    "je m'en fiche maintenant." "que soit ce que ce doit être." "je suis fatiguée de lutter." "rien ne m'importe." "je m'en moque." "qu'ils fassent ce qu'ils veulent." "ça ne me touche plus."
    "je vais me battre jusqu'au bout." "je ne vais pas abandonner." "j'irai de l'avant." "je vais y arriver." "je dois être forte." "ils ne me vaincront pas." "je sortirai de là."
    "j'ai besoin d'être seule." "je veux disparaître." "je vais prendre du temps." "j'ai besoin de me retrouver." "je vais prendre soin de moi." "c'est mon moment." "je le mérite."
    "tout va changer." "quelque chose de grand arrive." "je sens que du bon arrive." "les choses vont s'améliorer." "le meilleur est à venir." "de meilleurs jours arrivent."
  )
  
# INTENSIFICATEURS - Nouvelle catégorie pour plus de drame
# Espaces vides pour ne pas toujours en mettre un
  local intensificadores=( 
    "" "" "" "" "" "" "" ""
    "vraiment" "véritablement" "absolument" "complètement" "totalement" "super" "ultra" "méga" "hyper" "extrêmement"
    "incroyablement" "terriblement" "énormément" "profondément" "intensément" "passionnément" "désespérément"
    "très très" "purement et simplement" "sans aucun doute" "catégoriquement" "formellement" "nettement" "clairement"
  )
  
# ÉMOTIONS ADDITIONNELLES - Nouvelle catégorie
# Espaces pour que cela n'apparaisse pas toujours
  local emociones=( 
    "" "" "" "" "" ""
    "les yeux en larmes" "tremblante d'émotion" "rayonnante de bonheur" "morte de rire" "folle de joie" "remplie d'amour"
    "brisée de douleur" "déchirée" "anéantie" "écroulée" "dévastée" "inconsolable"
    "furieuse" "indignée" "énervée" "énervée au possible" "en colère noire" "fumante" "hors d'elle"
    "nerveuse comme une feuille" "angoissée" "accablée" "stressée" "très inquiète" "troublée" "agité"
    "très émue" "euphorique" "exultante" "jubilaire" "débordante de joie" "aux anges"
  )
  
# Sélection aléatoire des éléments
  local sujeto="${sujetos[$RANDOM % ${#sujetos[@]}]}"
  local verbo="${verbos[$RANDOM % ${#verbos[@]}]}"
  local intensif="${intensificadores[$RANDOM % ${#intensificadores[@]}]}"
  local accion="${acciones[$RANDOM % ${#acciones[@]}]}"
  local indirecto="${comp_ind[$RANDOM % ${#comp_ind[@]}]}"
  local circunst="${comp_circ[$RANDOM % ${#comp_circ[@]}]}"
  local emocion="${emociones[$RANDOM % ${#emociones[@]}]}"
  local conector="${conectores[$RANDOM % ${#conectores[@]}]}"
  local cierre="${cierres[$RANDOM % ${#cierres[@]}]}"
  
# Construction de la phrase avec logique améliorée
  local frase="$sujeto $verbo"
  
# Ajouter intensificateur si présent
  if [[ -n "$intensif" ]]; then
    frase="$frase $intensif"
  fi
  
  frase="$frase $accion $indirecto $circunst"
  
# Ajouter émotion si présente
  if [[ -n "$emocion" ]]; then
    frase="$frase $emocion"
  fi
  
  frase="$frase, $conector $cierre"
  
  echo "$frase"
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
# PREMIÈRE EXÉCUTION
# ============================================================

frase="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase"
echo "$frase" >> "$MEMORIA"

# Construire un prompt simple
cat > "$TEMP_DIR/prompt1.txt" << EOF
Vous êtes un assistant empathique. Répondez en 1-2 courtes phrases.

$(tail -8 "$MEMORIA")

EOF

# Exécuter le modèle
"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  -f "$TEMP_DIR/prompt1.txt" \
  --ctx-size 4096 \
  --n-predict 100 \
  --temp 0.8 \
  --threads 12 \
  > "$TEMP_DIR/output1.txt" 2>&1

# Attendre
sleep 1

# Extraire la réponse (les dernières 5 lignes sans le bruit technique)
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
  echo "❌ Pas de réponse" >&2
fi

# ============================================================
# DEUXIÈME EXÉCUTION
# ============================================================

frase2="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase2"
echo "$frase2" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt2.txt" << EOF
Vous êtes un assistant empathique. Répondez en 1-2 courtes phrases.

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
  echo "❌ Pas de réponse lors de la deuxième exécution" >&2
fi
