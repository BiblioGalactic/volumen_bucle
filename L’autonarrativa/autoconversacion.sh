#!/usr/bin/env bash
# ============================================================
# === SCRIPT DE CONVERSA AMB MISTRAL ===
# ============================================================
# ============================================================
# === AUTOR: Gustavo Silva Da Costa =========================
# === SCRIPT: Conversa amb Mistral ==========================
# === DESCRIPCIÓ: Genera converses empàtiques amb un ========
# === model de llenguatge, desant historial i netejant ======
# === temporals automàticament ==============================
# === DATA: 2025 ============================================
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# 🔒 SANITITZACIÓ D'INPUT
# ============================================================
sanitize_path() {
    local input="$1"
    local label="$2"
    if [[ "$input" =~ [\"\\$\`\;|\&\>\<\!\(\)\{\}\[\]] ]]; then
        echo "❌ Ruta invàlida per $label: caràcters prohibits" >&2
        exit 1
    fi
    if [[ -z "$input" ]]; then
        echo "❌ Ruta buida per $label" >&2
        exit 1
    fi
    echo "$input"
}

# ============================================================
# CONFIGURACIÓ
# ============================================================
read -e -p "Ruta al model: " MODELO_PATH_INPUT
MODELO_PATH="${MODELO_PATH_INPUT:-$HOME/mistral-7b-instruct-v0.1.Q6_K.gguf}"
MODELO_PATH=$(sanitize_path "$MODELO_PATH" "model")
[[ ! -f "$MODELO_PATH" ]] && echo "❌ Model no trobat: $MODELO_PATH" && exit 1

read -e -p "Ruta al binari: " MAIN_BINARY_INPUT
MAIN_BINARY="${MAIN_BINARY_INPUT:-$HOME/llama.cpp/build/bin/llama-cli}"
MAIN_BINARY=$(sanitize_path "$MAIN_BINARY" "binari")
[[ ! -x "$MAIN_BINARY" ]] && echo "❌ Binari no trobat o sense permisos: $MAIN_BINARY" && exit 1

read -e -p "Ruta a l'arxiu de memòria: " MEMORIA_INPUT
MEMORIA="${MEMORIA_INPUT:-$HOME/conversacio.txt}"
MEMORIA=$(sanitize_path "$MEMORIA" "memòria")

read -e -p "Ruta al directori temporal: " TEMP_DIR_INPUT
TEMP_DIR="${TEMP_DIR_INPUT:-$HOME/temp}"
TEMP_DIR=$(sanitize_path "$TEMP_DIR" "directori temporal")

# ============================================================
# FUNCIONS
# ============================================================

generar_frase() {
# SUBJECTES - Ampliats amb més varietat emocional i cultural
  local sujetos=( 
    "Amiga" "Companya" "Col·lega" "Camarada" "Cel" "Carinyo" "Amor" "Germana" "Vida" "Estimada" "Nena" "Tia" "Guapa" "Reina" "Bonica" "Nena" "Maca" "Cor"
    "Preciosa" "Tresor" "Sol" "Lluna" "Estrella" "Àngel" "Princesa" "Deessa" "Bebè" "Nina" "Dolçor" "Bombó" "Meravella" "Joia"
    "Bonica" "Bella" "Morena" "Rossa" "Pèl-roja" "Noia" "Mossa" "Senyoreta" "Dama" "Musa" "Venus" "Afrodita" "Sirena" "Fada" "Bruixa" "Pitonisa"
    "Comadre" "Cunyada" "Prima" "Neboda" "Padrina" "Fillola" "Veïna" "Compinxe" "Sòcia" "Partner" "Aliada" "Còmplice" "Confident" "Consellera"
    "La meva nena" "La meva vida" "La meva ànima" "El meu tot" "El meu món" "La meva llum" "La meva esperança" "El meu refugi" "La meva fortalesa" "La meva debilitat" "La meva perdició" "La meva salvació"
  )
  
# VERBS - Més formes de comunicar i expressar
  local verbos=( 
    "em va dir" "pensa que" "creu que" "vol que" "sent que" "espera que" "suggereix que" "m'va escriure que" "em va confessar que" "anda dient que" "em va soltar que" "està segura que" "no entén que" "em repeteix que" "insisteix que" "li molesta que" "li fa por que"
    "va xiuxiuejar que" "va cridar que" "va plorar dient que" "es va queixar que" "es va lamentar que" "va admetre que" "va negar que" "va jurar que" "va prometre que" "va amenaçar que" "va pregar que" "va suplicar que" "va exigir que"
    "va murmurar que" "va balbucejar que" "va titubejar que" "va sospirar que" "va gemegar que" "es va desfogar dient que" "es va sincerar que" "es va obrir explicant-me que" "es va ensorrar dient que"
    "em va comentar que" "em va aclarir que" "em va explicar que" "em va explicar que" "em va narrar que" "em va detallar que" "em va especificar que" "em va precisar que" "em va confirmar que" "em va corregir que"
    "intueix que" "pressent que" "sospita que" "imagina que" "suposa que" "assumeix que" "dedueix que" "conclou que" "interpreta que" "entén que" "percep que"
    "tem que" "s'angoixa perquè" "es preocupa que" "s'inquieta que" "s'agobia amb que" "s'estresa pensant que" "s'obsessiona amb que" "es martiritza perquè"
    "s'emociona perquè" "s'alegra que" "s'entusiasma amb que" "es fa il·lusions pensant que" "s'anima perquè" "celebra que" "gaudeix que" "gosa amb que"
    "s'enfada perquè" "s'empipa amb que" "es molesta que" "s'irrita perquè" "s'indigna amb que" "es rebel·la davant que" "protesta perquè" "reclama que"
  )
  
# ACCIONS - Estats emocionals i situacions ampliades
  local acciones=( 
    "tot anirà bé" "necessitem parlar" "està cansada" "ja no confia" "tot es repeteix" "això és diferent" "ja no és el mateix" "alguna cosa no quadra" "m'estic allunyant" "t'estàs tancant" "se li nota a la cara" "la cosa no flueix" "alguna cosa va canviar entre nosaltres" "les coses pesen" "tot sembla forçat" "ja no riu igual" "evita els temes importants"
    "se sent perduda" "no troba el seu lloc" "busca alguna cosa diferent" "vol canviar d'aires" "necessita temps per ella" "està confosa" "no sap què vol" "s'està redescobrInt"
    "té por del futur" "li aterra envellir" "s'agobia amb les responsabilitats" "se sent atrapada" "vol escapar de tot" "necessita llibertat" "s'ofega en la rutina"
    "està enamorada" "ha trobat algú" "se sent especial" "brilla de felicitat" "està als núvols" "viu un conte de fades" "se sent completa" "ha trobat la seva meitat de taronja"
    "està gelosa" "sospita de tothom" "no pot evitar comparar-se" "se sent inferior" "li rosega l'enveja" "viu amb inseguretat" "dubta d'ella mateixa"
    "està dolguda" "se sent traïda" "no pot perdonar" "li costa oblidar" "viu en el passat" "no aconsegueix passar pàgina" "es turmenta recordant" "no entén què va passar"
    "està fort" "se sent invencible" "ha après a valorar-se" "sap el que val" "no accepta menys del que es mereix" "ha madurat molt" "està al seu millor moment"
    "està vulnerable" "se sent fràgil" "necessita protecció" "busca refugi" "vol que la cuidin" "se sent petita" "necessita mims" "està sensible"
    "vol venjança" "planeja alguna cosa" "està tramant" "no es quedarà callada" "es defensarà" "ja no es deixa trepitjar" "s'ha despertat" "ja no és la mateixa d'abans"
    "està agraïda" "valora el que té" "se sent afortunada" "compta les seves benediccions" "aprecia els petits detalls" "viu el present" "gaudeix cada moment"
  )
  
# COMPLEMENTS INDIRECTES - A qui es refereix, ampliat
  local comp_ind=( 
    "a la seva mare" "a mi" "a tu" "a nosaltres" "al cap" "al seu ex" "a ningú" "al grup" "a la seva germana" "a totes" "a cadascuna" "a algú" "a vosaltres" "a qui vulgui escoltar-la" "al professor" "a la seva amiga" "a aquesta persona"
    "al seu pare" "a la seva parella" "al seu nòvio" "al seu marit" "al seu espòs" "al seu crush" "al seu rotllo" "al noi que li agrada" "al seu amor platònic"
    "a la seva sogra" "a la seva cunyada" "a la seva nora" "al seu gendre" "als seus fills" "a la seva filla" "al seu fill" "als seus néts" "a la família" "als parents"
    "a les seves amigues" "a la seva millor amiga" "a la seva confident" "a la seva comadre" "al grup de WhatsApp" "a les noies" "a la colla" "al seu cercle íntim"
    "a la seva psicòloga" "a la seva terapeuta" "a la seva coach" "a la seva mentora" "a la seva consellera" "a la seva guia espiritual" "a la seva tarotista" "a la seva vident"
    "a la seva cap" "a les seves companyes de feina" "al seu equip" "a les seves subordinades" "a recursos humans" "a l'empresa" "al sindicat"
    "a la seva veïna" "a la portera" "a la perruquera" "a la manicurista" "a l'esteticista" "a la massatgista" "a la seva entrenadora personal"
    "a les xarxes socials" "a Instagram" "als seus seguidors" "a Facebook" "a Twitter" "a tot el món" "a la humanitat" "a l'univers"
    "al seu diari" "al seu blog" "al seu canal" "al seu podcast" "a la seva audiència" "als seus fans" "als seus lectors" "als seus subscriptors"
    "al mirall" "a les parets" "al seu coixí" "a les estrelles" "a la lluna" "al vent" "al mar" "a la natura"
  )
  
# COMPLEMENTS CIRCUMSTANCIALS - Quan, com, on
  local comp_circ=( 
    "al matí" "a casa" "de sempre" "amb cura" "sense pensar" "de nou" "al final" "en silenci" "sense raó" "de cop" "com abans" "en veu baixa" "a l'instant" "de forma rara" "a l'última vegada" "mentre plorava" "quan ningú mirava"
    "a la nit" "a l'alba" "a la posta de sol" "de matinada" "durant l'esmorzar" "al sopar" "a mitjanit" "a la feina" "a l'oficina" "al gimnàs" "a l'spa"
    "al bany" "a la cuina" "al dormitori" "al saló" "a la terrassa" "al jardí" "al cotxe" "al metro" "a l'autobús" "passejant pel carrer"
    "al cafè" "al restaurant" "al bar" "a la discoteca" "al centre comercial" "a la perruqueria" "al supermercat" "fent la compra"
    "per telèfon" "per WhatsApp" "per missatge" "per videotrucada" "per email" "per carta" "per postal" "a través d'un amic" "indirectament"
    "plorant" "rient" "cridant" "xiuxiuejant" "tremolant" "envermellint-se" "sospirant" "plorinyant" "entre llàgrimes" "amb la veu trencada"
    "borratxa" "fumant" "menjant xocolata" "bevent vi" "prenent cafè" "després de ioga" "després de la meditació" "en teràpia" "al psicòleg"
    "després del sexe" "al llit" "abraçant-me" "petoneant-me" "acariciant-me" "mentre em pentinava" "posant-se crema" "despullada" "en pijama"
    "molt nerviosa" "completament relaxada" "súper emocionada" "totalment exhausta" "mig adormida" "acabada de despertar" "sense maquillatge" "arranjant-se"
    "durant la pel·lícula" "veient la tele" "llegint" "escoltant música" "ballant" "cuinant" "netejant" "endreçant" "treballant" "estudiant"
    "al parc" "a la platja" "a la muntanya" "al camp" "viatjant" "de vacances" "a l'estranger" "lluny de casa" "al seu poble"
    "amb total sinceritat" "molt seriosament" "mig de broma" "amb sarcasme" "irònicament" "amb dolçor" "amb tendresa" "amb passió" "amb ràbia"
  )
  
# CONNECTORS - Més varietat de transicions
  local conectores=( 
    "però" "tot i que" "i" "perquè" "aleshores" "així que" "tanmateix" "al final" "per això" "de totes maneres" "igualment" "per més que" "com si res" "de sobte" "fins i tot"
    "a més" "també" "tampoc" "ni tan sols" "fins" "només que" "excepte que" "malgrat que" "tot i que" "nogensmenys"
    "en canvi" "al contrari" "mentrestant" "alhora" "al mateix temps" "simultàniament" "paral·lelament" "en paral·lel"
    "en conseqüència" "per consegüent" "per tant" "així doncs" "d'aquí que" "de manera que" "amb la qual cosa"
    "és a dir" "o sigui" "amb altres paraules" "dit d'una altra manera" "més ben dit" "més aviat" "en realitat" "la veritat és que" "el cert és que"
    "primer" "segon" "tercer" "després" "més tard" "anteriorment" "prèviament" "finalment" "per últim" "per acabar"
    "òbviament" "evidentment" "clarament" "per descomptat" "naturalment" "lògicament" "comprensiblement" "justificadament"
    "afortunadament" "desafortunadament" "lamentablement" "tristament" "alegrement" "sorprenentment" "increïblement"
    "francament" "honestament" "sincerament" "realment" "veritablement" "efectivament" "certament" "definitivament"
    "potser" "tal vegada" "possiblement" "probablement" "segurament" "aparentment" "suposadament" "presumiblement"
  )
  
# TANCAMENTS - Finals ampliats amb més varietat emocional
  local cierres=( 
    "no sé què pensar." "potser té raó." "jo també ho sento." "no volia que passés així." "caldrà veure-ho." "em costa acceptar-ho." "potser ja n'hi ha prou." "igual m'ho mereixo." "no vull discutir més." "ja no puc fingir." "ella també se n'ha adonat." "m'ho vaig callar per por." "tot s'ha desendreçat." "no sé si tornaria a confiar." "em pesa no dir-ho abans."
    "em fa mal a l'ànima." "se'm parteix el cor." "no puc més amb això." "estic al límit." "necessito un respir." "m'està matant per dins." "sento que m'ofego." "no trobo la sortida."
    "em fa molt feliç." "estic en un núvol." "no puc parar de somriure." "em sento completa." "és el millor que m'ha passat." "gràcies a la vida." "sóc la dona més afortunada."
    "em fa molta ràbia." "estic que cremo." "no ho permetre." "ja veurem qui pot més." "se n'assabentarà." "això no es queda així." "ho pagarà car." "li donaré el seu merescut."
    "em fa molta pena." "m'entristeix profundament." "ploro només de pensar-ho." "em parteix en dos." "no és just." "la vida és molt cruel." "no es mereixia això." "és molt dur d'acceptar."
    "estic molt confosa." "no sé què fer." "necessito temps per pensar-ho." "em sento perduda." "tot està molt confús." "no tinc les idees clares." "necessito posar ordre al cap."
    "tinc molta por." "m'aterra el que pugui passar." "no vull ni pensar-ho." "em fa pànic." "tremolo només d'imaginar-ho." "prefereixo no saber res." "millor que no passi res."
    "estic molt orgullosa." "em sento molt satisfeta." "ho he aconseguit." "ha valgut la pena l'esforç." "estic on volia estar." "he complert el meu somni." "sóc molt afortunada."
    "em sento culpable." "hauria d'haver fet més." "va ser culpa meva." "em retrec no haver actuat." "no em puc perdonar." "carrega amb aquesta culpa." "em remordeix la consciència."
    "estic molt agraïda." "no sé com pagar-li-ho." "li dec tant." "mai ho oblidaré." "sempre li estaré agraïda." "és un àngel a la meva vida." "què faria sense ella."
    "ja veurem què passa." "el temps dirà." "caldrà esperar." "tot arriba quan ha d'arribar." "si ha de ser, serà." "el que hagi de passar, passarà." "el destí decidirà."
    "m'és igual ja." "que sigui el que hagi de ser." "estic cansada de lluitar." "no m'importa res." "passo de tot." "que facin el que vulguin." "ja no m'afecta."
    "lluitaré fins al final." "no em rendiré." "seguiré endavant." "ho aconseguiré." "he de ser forta." "no em venceran." "sortiré d'aquesta."
    "necessito estar sola." "vull desaparèixer." "em prendré un temps." "necessito trobar-me." "cuidaré de mi." "és el meu moment." "m'ho mereixo."
    "tot canviarà." "s'acosta alguna cosa gran." "pressento que ve alguna cosa bona." "les coses milloraran." "el millor està per arribar." "venen temps millors."
  )
  
# INTENSIFICADORS - Nova categoria per donar més dramatisme
# Espais buits perquè no sempre hi hagi intensificador
  local intensificadores=( 
    "" "" "" "" "" "" "" ""
    "realment" "veritablement" "absolutament" "completament" "totalment" "súper" "ultra" "mega" "hiper" "extremadament"
    "increïblement" "tremendament" "enormement" "profundament" "intensament" "apassionadament" "desesperadament"
    "molt molt" "pura i simplement" "sense cap mena de dubte" "categòricament" "rotundament" "tajantment" "claríssimament"
  )
  
# EMOCIONS ADDICIONALS - Nova categoria 
# Espais perquè no sempre aparegui
  local emociones=( 
    "" "" "" "" "" ""
    "amb llàgrimes als ulls" "tremolant d'emoció" "radiant de felicitat" "morta de riure" "boja d'alegria" "plena d'amor"
    "trencada de dolor" "destrossada" "feta pols" "enfonsada" "devastada" "desconsolada" "inconsolable"
    "furiosa" "indignada" "empipadíssima" "mosquejada" "enfadadíssima" "que feia fum" "que no veia ni tres en un burro"
    "nerviosa com un flam" "angoixada" "agobiada" "estressada" "preocupadíssima" "inquieta" "intranquil·la"
    "emocionadíssima" "eufòrica" "exultant" "jubilosa" "rebosant de felicitat" "que no cabia en si de goig"
  )
  
# Selecció aleatòria d'elements
  local sujeto="${sujetos[$RANDOM % ${#sujetos[@]}]}"
  local verbo="${verbos[$RANDOM % ${#verbos[@]}]}"
  local intensif="${intensificadores[$RANDOM % ${#intensificadores[@]}]}"
  local accion="${acciones[$RANDOM % ${#acciones[@]}]}"
  local indirecto="${comp_ind[$RANDOM % ${#comp_ind[@]}]}"
  local circunst="${comp_circ[$RANDOM % ${#comp_circ[@]}]}"
  local emocion="${emociones[$RANDOM % ${#emociones[@]}]}"
  local conector="${conectores[$RANDOM % ${#conectores[@]}]}"
  local cierre="${cierres[$RANDOM % ${#cierres[@]}]}"
  
# Construcció de la frase amb lògica millorada
  local frase="$sujeto $verbo"
  
# Afegir intensificador si existeix
  if [[ -n "$intensif" ]]; then
    frase="$frase $intensif"
  fi
  
  frase="$frase $accion $indirecto $circunst"
  
# Afegir emoció si existeix
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
# PRIMERA EXECUCIÓ
# ============================================================

frase="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase"
echo "$frase" >> "$MEMORIA"

# Construir prompt simple
cat > "$TEMP_DIR/prompt1.txt" << EOF
Ets un assistent empàtic. Respon en 1-2 frases curtes.

$(tail -8 "$MEMORIA")

EOF

# Executar model
"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  -f "$TEMP_DIR/prompt1.txt" \
  --ctx-size 4096 \
  --n-predict 100 \
  --temp 0.8 \
  --threads 12 \
  > "$TEMP_DIR/output1.txt" 2>&1

# Esperar
sleep 1

# Extreure resposta (últimes 5 línies sense escombraries tècniques)
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
  echo "❌ Sense resposta" >&2
fi

# ============================================================
# SEGONA EXECUCIÓ
# ============================================================

frase2="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase2"
echo "$frase2" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt2.txt" << EOF
Ets un assistent empàtic. Respon en 1-2 frases curtes.

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
  echo "❌ Sense resposta en segona execució" >&2
fi
