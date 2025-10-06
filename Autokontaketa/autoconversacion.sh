#!/usr/bin/env bash
# ============================================================
# === MISTRAL-EKIN ELKARRIZKETA SCRIPT-A ===
# ============================================================
# ============================================================
# === EGILEA: Gustavo Silva Da Costa ======================
# === SCRIPT-A: Mistral-ekin Elkarrizketa ==================
# === DESKRIBAPENA: Elkarrizketa enpatikoak sortzen ditu ==
# === hizkuntza-modelo batekin, historiala gordez eta ======
# === temporalak automatikoki garbitzen ====================
# === DATA: 2025 ============================================
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# KONFIGURAZIOA
# ============================================================
read -e -p "Modeloaren bidea: " MODELO_PATH_INPUT
MODELO_PATH="${MODELO_PATH_INPUT:-$HOME/mistral-7b-instruct-v0.1.Q6_K.gguf}"

read -e -p "Binarioaren bidea: " MAIN_BINARY_INPUT
MAIN_BINARY="${MAIN_BINARY_INPUT:-$HOME/llama.cpp/build/bin/llama-cli}"

read -e -p "Memoria-fitxategiaren bidea: " MEMORIA_INPUT
MEMORIA="${MEMORIA_INPUT:-$HOME/elkarrizketa.txt}"

read -e -p "Direktorio temporalaren bidea: " TEMP_DIR_INPUT
TEMP_DIR="${TEMP_DIR_INPUT:-$HOME/temp}"

# ============================================================
# FUNTZIOAK
# ============================================================

generar_frase() {
# SUBJEKTUAK - Zabalduak emoziozko eta kulturazko aniztasun handiagoarekin
  local sujetos=( 
    "Laguna" "Laguntzailea" "Lankidea" "Kamarada" "Zerua" "Maitea" "Maitasuna" "Ahizpa" "Bizia" "Polita" "Neska" "Ederra" "Erregina" "Printzesa" "Bihotza"
    "Ederra" "Polita" "Altxorra" "Eguzkia" "Ilargia" "Izarra" "Aingerua" "Printzesa" "Jainkosa" "Kumea" "Panpina" "Goxotasuna" "Bonboia" "Miraria" "Bitxia"
    "Ederrena" "Ederra" "Ilehoria" "Gorrizta" "Neska" "Andereñoa" "Anderea" "Musa" "Venus" "Afrodita" "Sirena" "Sorgin" "Pitonisa"
    "Komadrona" "Koinata" "Lehengusina" "Iloba" "Izeba" "Auzokoa" "Bazkidea" "Aliatu" "Konfidentea" "Aholkularia"
    "Nire neska" "Nire bizia" "Nire arima" "Nire guztia" "Nire mundua" "Nire argia" "Nire itxaropena" "Nire babeslekua" "Nire indarra" "Nire ahultasuna" "Nire salbamena"
  )
  
# ADITZAK - Komunikatu eta adierazteko modu gehiago
  local verbos=( 
    "esan zidan" "uste du" "sinesten du" "nahi du" "sentitzen du" "espero du" "iradokitzen du" "idatzi zidan" "aitortu zidan" "dabil esaten" "bota zidan" "ziur dago" "ez du ulertzen" "errepikatzen dit" "diotsa" "gogaitzen zaio" "beldurtzen zaio"
    "xuxurlatu zuen" "oihukatu zuen" "negar egin zuen esanez" "kexatu zen" "damu hartu zuen" "onartu zuen" "ukatu zuen" "zin egin zuen" "zin egin zuen" "mehatxatu zuen" "erregutu zuen" "eskatu zuen" "exijitu zuen"
    "murmuratu zuen" "marmar egin zuen" "tarteka esan zuen" "suspiratu zuen" "marmar egin zuen" "askaatu zen esanez" "zintzotu zen" "zabaldu zitzaidan esanez" "porrotu zen esanez"
    "iruzkindu zidan" "argitu zidan" "azaldu zidan" "kontatu zidan" "narratu zidan" "xehetasundu zidan" "zehaztu zidan" "berretsi zidan" "zuzendu zidan"
    "nabari du" "aurreikusten du" "susmatzen du" "imajinatzen du" "suposatzen du" "onartu du" "ondorioztatzen du" "interpretatzen du" "ulertzen du" "hautematen du"
    "beldur da" "larrituta dago" "kezkatzen da" "larrituta dago" "larrituta dago" "estresatuta dago pentsatuz" "obsesionatuta dago" "martirizatzen da"
    "emozionatzen da" "pozten da" "ilusioa egiten zaio pentsatuz" "animatzen da" "ospatzen du" "gozatzen du" "pozten da"
    "haserretzen da" "haserre dago" "molestatu egiten da" "irritatzen da" "indignatu egiten da" "matxinatzen da" "protesta egiten du" "erreklamatzen du"
  )
  
# EKINTZAK - Egoera emozionalak eta egoera zabalduak
  local acciones=( 
    "dena ondo joango da" "hitz egin behar dugu" "nekatuta dago" "ez du konfiantzarik" "dena errepikatzen da" "hau desberdina da" "ez da berdina" "zerbait ez dator bat" "urrun uzten ari naiz" "itxitzen ari zara" "aurpegian nabaritzen zaio" "kontua ez da jartzen" "zerbait aldatu zen gure artean" "gauzek pisatzen dute" "dena behartua dirudi" "ez du orain berdin barregin egiten" "gai garrantzitsuak saihesten ditu"
    "galdurik sentitzen da" "ez du bere tokia aurkitzen" "zerbait desberdin bilatzen du" "aire aldaketa nahi du" "berarentzat denbora behar du" "nahasita dago" "ez daki zer nahi duen" "berraurkitzen ari da"
    "etorkizunaren beldur da" "izugarri beldurtzen zaio zahartzen" "erantzukizunekin agobiatzen da" "harrapatuta sentitzen da" "guztitik ihes egin nahi du" "askatasuna behar du" "errutinarekin ito egiten da"
    "maitemindurik dago" "norbait aurkitu du" "berezi sentitzen da" "zoriontasunez distira egiten du" "hodeitan dago" "ipuin bat bizitzen ari da" "oso sentitzen da" "bere erdia aurkitu du"
    "jeloskorra dago" "mundu guztia susmatzen du" "ezin du konparatzea saihestu" "inferioragoa sentitzen da" "inbidiak jan egiten du" "segurtasun gabezia du" "bere buruaz zalantzan du"
    "mindurik dago" "traizionatua sentitzen da" "ezin du barkatu" "zaila da ahaztea" "iraganean bizi da" "ezin du orria pasa" "torturatzen du gogoratuz" "ez du ulertzen zer gertatu zen"
    "sendoa dago" "garaiezina sentitzen da" "baloratzea ikasi du" "badaki zer balio duen" "ez du merezi ez duena onartzen" "asko heldu da" "bere une onenean dago"
    "ahula dago" "ahula sentitzen da" "babesa behar du" "babeslekua bilatzen du" "zainduak izan nahi du" "txikia sentitzen da" "mimoak behar ditu" "sentibera dago"
    "mendekua nahi du" "zerbait plangintzan ari da" "traman ari da" "ez da isilik geratuko" "defendatuko da" "ez da jada zapaldurik uzten" "esnatu da" "ez da lehengo bera"
    "eskertua dago" "daukana baloratzen du" "zorionekoa sentitzen da" "bere bedeinkapenak kontatzen ditu" "xehetasun txikiak baloratzen ditu" "oraina bizi du" "une oro gozatzen du"
  )
  
# ZEHARKAKO OSAGARRIAK - Nori buruz ari den, zabaldua
  local comp_ind=( 
    "bere amari" "niri" "zuri" "guri" "buruari" "bere exari" "inori ez" "taldeari" "bere ahizpari" "denei" "bakoitzari" "norbaiti" "zuei" "entzun nahi duenari" "irakasleari" "bere lagunari" "pertsona horri"
    "bere aitari" "bere bikoteari" "bere mutilari" "bere senarari" "bere senarari" "gustatzen zaion mutilari" "bere maitasun platonikora"
    "bere amaginarrebari" "bere koinatari" "bere errainarrebari" "bere suhiarrebari" "bere seme-alabei" "bere alabari" "bere semeari" "bere bilobeei" "familiari" "senideei"
    "bere laguneei" "bere lagun minenari" "bere konfidenteari" "bere komadroneari" "WhatsApp taldeari" "neskeei" "pandillari" "bere zirkulu intimore"
    "bere psikologoari" "bere terapeutari" "bere coach-ari" "bere mentoreari" "bere aholkulariiari" "bere gida espiritualari" "bere tarotistari" "bere ikusleari"
    "bere buruari" "bere lan-kideei" "bere taldeari" "bere menpekoenari" "giza baliabideei" "enpresari" "sindikatureri"
    "bere auzokori" "atezainari" "ilepaingileari" "manikuritsari" "estetizientzari" "masajistarari" "bere entrenatzaile pertsonalari"
    "sare sozialei" "Instagrami" "bere jarraitzaileei" "Facebook-ari" "Twitter-ri" "mundu osoari" "gizadiari" "unibertsoari"
    "bere egunkariarii" "bere blogeari" "bere kanalari" "bere podcast-ari" "bere publikoari" "bere zaleei" "bere irakurleei" "bere harpideduneei"
    "ispilari" "hormetei" "bere burukoi" "izarrei" "ilargiari" "haizeari" "itsasoari" "naturari"
  )
  
# INGURUABARRAZKO OSAGARRIAK - Noiz, nola, non
  local comp_circ=( 
    "goizean" "etxean" "betidanik" "kontuz" "pentsatu gabe" "berriz ere" "azkenean" "isilik" "arrazoirik gabe" "bat-batean" "lehen bezala" "ahots baxuan" "berehala" "modu bitxian" "azken aldian" "negar egiten zuen bitartean" "inork begiratu ez zuenean"
    "gauean" "egunsentiean" "iluntzean" "goizaldean" "gosarian zehar" "afarirako" "gauerdi" "lanean" "bulegoan" "gimnasioan" "spa-an"
    "bainugelan" "sukaldean" "logelan" "egongelan" "terrazan" "lorategian" "autoan" "metroan" "autobus" "kalean paseoan"
    "kafetegian" "jatetxean" "taberna" "diskotekan" "merkataritza-zentroan" "ilepaingintzan" "supermerkatuan" "erosketa egiten"
    "telefonoz" "WhatsApp-ez" "mezuz" "bideodeiez" "email-ez" "gutunez" "postalaz" "lagun baten bidez" "zeharka"
    "negarrez" "barrez" "oihuka" "xuxurlatuz" "dardarka" "gorrituz" "suspiratuz" "sinistatuz" "negar artean" "ahotsaz apurtua"
    "hordita" "erretzen" "txokolatea jaten" "arnoa edaten" "kafea hartzen" "yoga ondoren" "meditazio ondoren" "terapian" "psikologoarekin"
    "sexu ondoren" "ohean" "besarkatzean" "musu egiten" "laztantzen" "orrazten ninduen bitartean" "krema jartzen" "biluzik" "pijaman"
    "oso nerbiosa" "guztiz lasaituta" "super emozionatua" "guztiz nekatua" "erdi lotan" "oraintxe esnatua" "makillaje gabe" "konpontzen"
    "filmaren zehar" "telebista ikusten" "irakurtzen" "musika entzuten" "dantzan" "sukaldaritzan" "garbitzen" "ordenatzen" "lanean" "ikasrean"
    "parkean" "hondartzan" "mendian" "baserrian" "bidaiatzen" "oporretan" "atzerrian" "etxetik urrun" "bere herrian"
    "zintzotasun osoarekin" "oso benetan" "broma erdian" "sarkasmoz" "ironikoki" "goxotasunarekin" "goxotasunarekin" "pasioz" "haserrearekin"
  )
  
# LOTURAK - Trantsiziozko aniztasun gehiago
  local conectores=( 
    "baina" "nahiz eta" "eta" "delako" "orduan" "beraz" "hala ere" "azkenean" "horregatik" "dena den" "berdin" "nahiz eta gehiago" "ezer ez balitz bezala" "bat-batean" "baita ere"
    "gainera" "ere" "ere ez" "ere ez" "arte" "bakarrik" "izan ezik" "izan ezik" "nahiz eta" "hala ere"
    "aldiz" "aitzitik" "bitartean" "aldi berean" "aldi berean" "aldi berean" "paraleloki" "paraleloan"
    "ondorioz" "ondorioz" "beraz" "beraz" "beraz" "horregatik" "era horretan" "era horretan" "horrekin"
    "hau da" "alegia" "beste hitz batzuetan" "beste era batera esanda" "hobeto esanda" "gehiago" "egiatan" "egia da" "ziurra da"
    "lehenik" "bigarrenik" "hirugarrenik" "gero" "gero" "beranduago" "aurretik" "aurretik" "azkenik" "azkenik" "amaitzeko"
    "nabarmen" "nabarmen" "argi" "jakina" "naturalki" "logikoki" "ulergarriro" "justifikatuta"
    "zorionez" "zoritxarrez" "tamalgarria" "tristeki" "pozik" "harrigarriro" "sinistezina"
    "zintzoki" "zintzoki" "zintzoki" "benetan" "egiaz" "eraginkortasunez" "ziur" "erabakigarriro"
    "agian" "beharbada" "posibleki" "ziurrenik" "ziurrenik" "antza denez" "ustez" "susmoz"
  )
  
# ITXIERAK - Amaiera zabalduak emoziozko aniztasun gehiagorekin
  local cierres=( 
    "ez dakit zer pentsatu." "agian arrazoia du." "nik ere sentitzen dut." "ez nuen horrela gertatzea nahi." "ikusi beharko dugu." "zaila zait onartzea." "agian nahikoa izan da jada." "agian merezi dut." "ez dut gehiago eztabaidatu nahi." "ezin dut jada itxurak egin." "hark ere konturatu zen." "beldurrak esan zidan." "dena nahastu zen." "ez dakit berriro konfiantzako nukeen." "aurrean ez esateak pisatzen dit."
    "arimari min egiten dit." "bihotza apurtzen zait." "ezin dut gehiago honekin." "mugan nago." "arnasa behar dut." "barruan hiltzen nau." "ito egiten nauela sentitzen dut." "ez dut irteerarik aurkitzen."
    "oso pozik jartzen nau." "hodei batean nago." "ezin dut barregin gelditu." "oso sentitzen naiz." "gertatu zaidan onena da." "biziari eskerrak." "emakume zoriontsuenak naiz."
    "haserre handia ematen dit." "sutan nago." "ez dut uzten." "ikusiko dugu nork gehiago." "enteratu egingo da." "ez da horrela geratzen." "garestiro ordainduko du." "emango diot merezi duena."
    "pena handia ematen dit." "guztiz atsekabetzen nau." "pentsatzean bakarrik negarrez nago." "bitan apurtzen nau." "ez da zuzena." "bizia oso krudelez da." "ez zuen merezi." "oso gogorra da onartzea."
    "oso nahasita nago." "ez dakit zer egin." "denbora behar dut pentsatzeko." "galduta sentitzen naiz." "dena oso nahasia dago." "ez ditut ideiak argi." "nire buruan ordena jarri behar dut."
    "beldur handia daukat." "izugarri beldurtzen zait gertatuko dena." "ez dut pentsatu ere nahi." "paniko ematen dit." "iruditzeak bakarrik dardar jartzen nau." "hobeto ez jakitea." "hobeto ez gertatzea."
    "oso harro nago." "oso pozik nago." "lortu dut." "merezi izan du." "nahi nuen tokian nago." "nire ametsa bete dut." "oso zorionekoa naiz."
    "errudun sentitzen naiz." "gehiago egin behar nuen." "nire errua izan zen." "erreprochatzen diot ez jardutea." "ezin dut barkatu nire buruari." "erru horrekin zama du." "kontzientziak erremorditzen dit."
    "oso eskertua nago." "ez dakit nola ordaindu." "horrenbeste zor diot." "inoiz ez dut ahaztuko." "beti eskertua egongo naizaio." "aingeru bat da nire bizitzan." "zer egingo nuke hura gabe."
    "ikusiko dugu zer gertatzen den." "denborak esango du." "itxaron beharko dugu." "dena iristen da gertatu behar denean." "izan behar bada, izango da." "gertatu behar dena, gertatuko da." "patuak erabakiko du."
    "berdin zait jada." "izan bedi izan behar dena." "nekatuta nago borrokatzeko." "ez zait ezer axola." "guztitik pasatzen naiz." "egin dezatela nahi dutena." "ez dit jada eragiten."
    "azkenera arte borrokatuko dut." "ez naiz amore emango." "aurrera jarraituko dut." "lortuko dut." "sendo izan behar dut." "ez naute garaitu." "honetatik aterako naiz."
    "bakarrik egon behar dut." "desagertu nahi dut." "denbora bat hartuko dut." "nire burua aurkitu behar dut." "neure arduratuko naiz." "nire unea da." "merezi dut."
    "dena aldatuko da." "zerbait handia hurbiltzen ari da." "aurreikusten dut zerbait ona datorrela." "gauzak hobetuko dira." "onena etortzeko dago." "denbora hobeak datoz."
  )
  
# INDARGAILUAK - Kategoria berria dramatismo gehiago emateko
# Espazio hutsak beti indargailua ez izateko
  local intensificadores=( 
    "" "" "" "" "" "" "" ""
    "benetan" "egiaz" "erabat" "guztiz" "guztiz" "super" "ultra" "mega" "hiper" "gehiegizko"
    "sinestezina" "izugarri" "izugarri" "sakonki" "intentsu" "pasioz" "desesperatuki"
    "oso oso" "huts eta soilik" "zalantzarik gabe" "kategorikoki" "errotundoki" "zuzen-zuzenean" "argi-argi"
  )
  
# EMOZIOAK GEHIGARRIAK - Kategoria berria 
# Espazioak beti agertu ez dadin
  local emociones=( 
    "" "" "" "" "" ""
    "begietako malkoekin" "emozioaz dardarka" "zoriontasunez distira eginez" "barrezko hila" "alaitasunez zoroa" "maitasunez betea"
    "minak apurtuta" "suntsitua" "hautsa" "hondatua" "hondatua" "kontsolagaitza" "kontsolagaitza"
    "haserre" "indignatua" "haserre" "haserre" "haserretua" "ke egiten zuena" "ez ikustea ere"
    "flan bezain nerbiosa" "antsiatuta" "agobiatua" "estresatua" "kezkatua" "inquietua" "intranquila"
    "emozioz betea" "euforikoa" "pozik" "pozik" "zoriontasunez betea" "poz guztiz beteta"
  )
  
# Elementuen hautaketa ausazkoa
  local sujeto="${sujetos[$RANDOM % ${#sujetos[@]}]}"
  local verbo="${verbos[$RANDOM % ${#verbos[@]}]}"
  local intensif="${intensificadores[$RANDOM % ${#intensificadores[@]}]}"
  local accion="${acciones[$RANDOM % ${#acciones[@]}]}"
  local indirecto="${comp_ind[$RANDOM % ${#comp_ind[@]}]}"
  local circunst="${comp_circ[$RANDOM % ${#comp_circ[@]}]}"
  local emocion="${emociones[$RANDOM % ${#emociones[@]}]}"
  local conector="${conectores[$RANDOM % ${#conectores[@]}]}"
  local cierre="${cierres[$RANDOM % ${#cierres[@]}]}"
  
# Esaldiaren eraikuntza logika hobetua
  local frase="$sujeto $verbo"
  
# Gehitu indargailua badago
  if [[ -n "$intensif" ]]; then
    frase="$frase $intensif"
  fi
  
  frase="$frase $accion $indirecto $circunst"
  
# Gehitu emozioa badago
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
# LEHENENGO EXEKUZIOA
# ============================================================

frase="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase"
echo "$frase" >> "$MEMORIA"

# Prompt sinplea eraiki
cat > "$TEMP_DIR/prompt1.txt" << EOF
Laguntzaile enpatikoa zara. Erantzun 1-2 esaldi laburetan.

$(tail -8 "$MEMORIA")

EOF

# Modeloa exekutatu
"$MAIN_BINARY" \
  -m "$MODELO_PATH" \
  -f "$TEMP_DIR/prompt1.txt" \
  --ctx-size 4096 \
  --n-predict 100 \
  --temp 0.8 \
  --threads 12 \
  > "$TEMP_DIR/output1.txt" 2>&1

# Itxaron
sleep 1

# Erantzuna atera (azken 5 lerroak zabor teknikorik gabe)
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
  echo "❌ Erantzunik ez" >&2
fi

# ============================================================
# BIGARREN EXEKUZIOA
# ============================================================

frase2="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase2"
echo "$frase2" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt2.txt" << EOF
Laguntzaile enpatikoa zara. Erantzun 1-2 esaldi laburetan.

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
  echo "❌ Erantzunik ez bigarren exekuzioan" >&2
fi