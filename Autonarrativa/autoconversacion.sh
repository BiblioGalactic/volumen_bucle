#!/usr/bin/env bash
# ============================================================
# === SCRIPT DE CONVERSACIÓN CON MISTRAL ===
# ============================================================
# ============================================================
# === AUTOR: Gustavo Silva Da Costa =========================
# === SCRIPT: Conversación con Mistral =====================
# === DESCRIPCIÓN: Genera conversaciones empáticas con un ===
# === modelo de lenguaje, guardando historial y limpiando ==
# === temporales automáticamente ===========================
# === FECHA: 2025 ===========================================
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================
# CONFIGURACIÓN
# ============================================================
read -e -p "Ruta al modelo: " MODELO_PATH_INPUT
MODELO_PATH="${MODELO_PATH_INPUT:-$HOME/mistral-7b-instruct-v0.1.Q6_K.gguf}"

read -e -p "Ruta al binario: " MAIN_BINARY_INPUT
MAIN_BINARY="${MAIN_BINARY_INPUT:-$HOME/llama.cpp/build/bin/llama-cli}"

read -e -p "Ruta al archivo de memoria: " MEMORIA_INPUT
MEMORIA="${MEMORIA_INPUT:-$HOME/conversacion.txt}"

read -e -p "Ruta al directorio temporal: " TEMP_DIR_INPUT
TEMP_DIR="${TEMP_DIR_INPUT:-$HOME/temp}"

# ============================================================
# FUNCIONES
# ============================================================

generar_frase() {
# SUJETOS - Expandidos con más variedad emocional y cultural
  local sujetos=( 
    "Amiga" "Compañera" "Colega" "Camarada" "Cielo" "Cariño" "Amor" "Hermana" "Vida" "Churri" "Nena" "Tía" "Guapa" "Reina" "Linda" "Niña" "Maja" "Corazón"
    "Bonita" "Preciosa" "Tesoro" "Sol" "Luna" "Estrella" "Ángel" "Princesa" "Diosa" "Bebé" "Muñeca" "Ricura" "Dulzura" "Bombón" "Maravilla" "Joya"
    "Hermosa" "Bella" "Morena" "Rubia" "Pelirroja" "Chica" "Muchacha" "Señorita" "Dama" "Musa" "Venus" "Afrodita" "Sirena" "Hada" "Bruja" "Pitonisa"
    "Comadre" "Cuñada" "Prima" "Sobrina" "Madrina" "Ahijada" "Vecina" "Compinche" "Socia" "Partner" "Aliada" "Cómplice" "Confidenta" "Consejera"
    "Mi niña" "Mi vida" "Mi alma" "Mi todo" "Mi mundo" "Mi luz" "Mi esperanza" "Mi refugio" "Mi fortaleza" "Mi debilidad" "Mi perdición" "Mi salvación"
  )
  
# VERBOS - Más formas de comunicar y expresar
  local verbos=( 
    "me dijo" "piensa que" "cree que" "quiere que" "siente que" "espera que" "sugiere que" "me escribió que" "me confesó que" "anda diciendo que" "me soltó que" "está segura de que" "no entiende que" "me repite que" "insiste en que" "le molesta que" "le da miedo que"
    "susurró que" "gritó que" "lloró diciendo que" "se quejó de que" "se lamentó que" "admitió que" "negó que" "juró que" "prometió que" "amenazó con que" "rogó que" "suplicó que" "exigió que"
    "murmuró que" "balbuceó que" "tartamudeó que" "suspiró que" "gimió que" "se desahogó diciendo que" "se sinceró que" "se abrió contándome que" "se desplomó diciendo que"
    "me comentó que" "me aclaró que" "me explicó que" "me contó que" "me narró que" "me detalló que" "me especificó que" "me precisó que" "me confirmó que" "me corrigió que"
    "intuye que" "presiente que" "sospecha que" "imagina que" "supone que" "asume que" "deduce que" "concluye que" "interpreta que" "entiende que" "percibe que"
    "teme que" "se angustia porque" "se preocupa de que" "se inquieta que" "se agobia con que" "se estresa pensando que" "se obsesiona con que" "se martiriza porque"
    "se emociona porque" "se alegra de que" "se entusiasma con que" "se ilusiona pensando que" "se anima porque" "celebra que" "disfruta que" "goza con que"
    "se enfada porque" "se cabrea con que" "se molesta de que" "se irrita porque" "se indigna con que" "se rebela ante que" "protesta porque" "reclama que"
  )
  
# ACCIONES - Estados emocionales y situaciones expandidas
  local acciones=( 
    "todo irá bien" "necesitamos hablar" "está cansada" "ya no confía" "todo se repite" "esto es distinto" "ya no es lo mismo" "algo no cuadra" "me estoy alejando" "te estás cerrando" "se le nota en la cara" "la cosa no fluye" "algo cambió entre nosotras" "las cosas pesan" "todo parece forzado" "ya no ríe igual" "evita los temas importantes"
    "se siente perdida" "no encuentra su lugar" "busca algo diferente" "quiere cambiar de aire" "necesita tiempo para ella" "está confundida" "no sabe qué quiere" "se está redescubriendo"
    "tiene miedo al futuro" "le aterra envejecer" "se agobia con las responsabilidades" "se siente atrapada" "quiere escapar de todo" "necesita libertad" "se ahoga en la rutina"
    "está enamorada" "ha encontrado a alguien" "se siente especial" "brilla de felicidad" "está en las nubes" "vive un cuento de hadas" "se siente completa" "ha encontrado su media naranja"
    "está celosa" "sospecha de todo el mundo" "no puede evitar compararse" "se siente inferior" "le carcome la envidia" "vive con inseguridad" "duda de sí misma"
    "está dolida" "se siente traicionada" "no puede perdonar" "le cuesta olvidar" "vive en el pasado" "no logra pasar página" "se atormenta recordando" "no entiende qué pasó"
    "está fuerte" "se siente invencible" "ha aprendido a valorarse" "sabe lo que vale" "no acepta menos de lo que merece" "ha madurado mucho" "está en su mejor momento"
    "está vulnerable" "se siente frágil" "necesita protección" "busca refugio" "quiere que la cuiden" "se siente pequeña" "necesita mimos" "está sensible"
    "quiere venganza" "planea algo" "está tramando" "no va a quedarse callada" "va a defenderse" "ya no se deja pisar" "ha despertado" "ya no es la misma de antes"
    "está agradecida" "valora lo que tiene" "se siente afortunada" "cuenta sus bendiciones" "aprecia los pequeños detalles" "vive el presente" "disfruta cada momento"
  )
  
# COMPLEMENTOS INDIRECTOS - A quién se refiere, expandido
  local comp_ind=( 
    "a su madre" "a mí" "a ti" "a nosotras" "al jefe" "a su ex" "a nadie" "al grupo" "a su hermana" "a todos" "a cada una" "a alguien" "a vosotras" "a quien quiera escucharla" "al profesor" "a su amiga" "a esa persona"
    "a su padre" "a su pareja" "a su novio" "a su marido" "a su esposo" "a su crush" "a su ligue" "a su rollo" "al chico que le gusta" "a su amor platónico"
    "a su suegra" "a su cuñada" "a su nuera" "a su yerno" "a sus hijos" "a su hija" "a su hijo" "a sus nietos" "a la familia" "a los parientes"
    "a sus amigas" "a su mejor amiga" "a su confidente" "a su comadre" "al grupo de WhatsApp" "a las chicas" "a la pandilla" "a su círculo íntimo"
    "a su psicóloga" "a su terapeuta" "a su coach" "a su mentora" "a su consejera" "a su guía espiritual" "a su tarotista" "a su vidente"
    "a su jefa" "a sus compañeras de trabajo" "a su equipo" "a sus subordinadas" "a recursos humanos" "a la empresa" "al sindicato"
    "a su vecina" "a la portera" "a la peluquera" "a la manicurista" "a la esteticista" "a la masajista" "a su entrenadora personal"
    "a las redes sociales" "a Instagram" "a sus seguidores" "a Facebook" "a Twitter" "al mundo entero" "a la humanidad" "al universo"
    "a su diario" "a su blog" "a su canal" "a su podcast" "a su audiencia" "a sus fans" "a sus lectores" "a sus suscriptores"
    "al espejo" "a las paredes" "a su almohada" "a las estrellas" "a la luna" "al viento" "al mar" "a la naturaleza"
  )
  
# COMPLEMENTOS CIRCUNSTANCIALES - Cuándo, cómo, dónde
  local comp_circ=( 
    "por la mañana" "en casa" "desde siempre" "con cuidado" "sin pensar" "de nuevo" "al final" "en silencio" "sin razón" "de golpe" "como antes" "en voz baja" "al instante" "de forma rara" "en la última vez" "mientras lloraba" "cuando nadie miraba"
    "por la noche" "al amanecer" "al atardecer" "en la madrugada" "durante el desayuno" "en la cena" "a medianoche" "en el trabajo" "en la oficina" "en el gimnasio" "en el spa"
    "en el baño" "en la cocina" "en el dormitorio" "en el salón" "en la terraza" "en el jardín" "en el coche" "en el metro" "en el autobús" "caminando por la calle"
    "en el café" "en el restaurante" "en el bar" "en la discoteca" "en el centro comercial" "en la peluquería" "en el supermercado" "haciendo la compra"
    "por teléfono" "por WhatsApp" "por mensaje" "por videollamada" "por email" "por carta" "por postal" "a través de un amigo" "indirectamente"
    "llorando" "riendo" "gritando" "susurrando" "temblando" "sonrojándose" "suspirando" "sollozando" "entre lágrimas" "con la voz quebrada"
    "borracha" "fumando" "comiendo chocolate" "bebiendo vino" "tomando café" "después de yoga" "tras la meditación" "en terapia" "en el psicólogo"
    "después del sexo" "en la cama" "abrazándome" "besándome" "acariciándome" "mientras me peinaba" "poniéndose crema" "desnuda" "en pijama"
    "muy nerviosa" "completamente relajada" "súper emocionada" "totalmente agotada" "medio dormida" "recién despierta" "sin maquillaje" "arreglándose"
    "durante la película" "viendo la tele" "leyendo" "escuchando música" "bailando" "cocinando" "limpiando" "ordenando" "trabajando" "estudiando"
    "en el parque" "en la playa" "en la montaña" "en el campo" "viajando" "de vacaciones" "en el extranjero" "lejos de casa" "en su pueblo"
    "con total sinceridad" "muy en serio" "medio en broma" "con sarcasmo" "irónicamente" "con dulzura" "con ternura" "con pasión" "con rabia"
  )
  
# CONECTORES - Más variedad de transiciones
  local conectores=( 
    "pero" "aunque" "y" "porque" "entonces" "así que" "sin embargo" "al final" "por eso" "de todos modos" "igual" "por más que" "como si nada" "de repente" "incluso"
    "además" "también" "tampoco" "ni siquiera" "hasta" "solo que" "salvo que" "excepto que" "a pesar de que" "pese a que" "no obstante"
    "en cambio" "por el contrario" "mientras tanto" "a la vez" "al mismo tiempo" "simultáneamente" "paralelamente" "en paralelo"
    "en consecuencia" "por consiguiente" "por tanto" "por lo tanto" "así pues" "de ahí que" "de modo que" "de manera que" "con lo cual"
    "es decir" "o sea" "en otras palabras" "dicho de otro modo" "mejor dicho" "más bien" "en realidad" "la verdad es que" "lo cierto es que"
    "primero" "segundo" "tercero" "luego" "después" "más tarde" "anteriormente" "previamente" "finalmente" "por último" "para terminar"
    "obviamente" "evidentemente" "claramente" "por supuesto" "naturalmente" "lógicamente" "comprensiblemente" "justificadamente"
    "afortunadamente" "desafortunadamente" "lamentablemente" "tristemente" "alegremente" "sorprendentemente" "increíblemente"
    "francamente" "honestamente" "sinceramente" "realmente" "verdaderamente" "efectivamente" "ciertamente" "definitivamente"
    "quizás" "tal vez" "posiblemente" "probablemente" "seguramente" "aparentemente" "supuestamente" "presumiblemente"
  )
  
# CIERRES - Finales expandidos con más variedad emocional
  local cierres=( 
    "no sé qué pensar." "quizá tenga razón." "yo también lo siento." "no quise que pasara así." "habrá que verlo." "me cuesta aceptarlo." "quizá ya fue suficiente." "igual me lo merezco." "no quiero discutir más." "ya no puedo fingir." "ella también se dio cuenta." "me lo callé por miedo." "todo se desordenó." "no sé si volvería a confiar." "me pesa no decirlo antes."
    "me duele en el alma." "se me parte el corazón." "no puedo más con esto." "estoy al límite." "necesito un respiro." "me está matando por dentro." "siento que me ahogo." "no encuentro la salida."
    "me hace muy feliz." "estoy en una nube." "no puedo parar de sonreír." "me siento completa." "es lo mejor que me ha pasado." "gracias a la vida." "soy la mujer más afortunada."
    "me da mucha rabia." "estoy que ardo." "no lo voy a permitir." "ya veremos quién puede más." "se va a enterar." "esto no se queda así." "va a pagar caro." "le voy a dar su merecido."
    "me da mucha pena." "me entristece profundamente." "lloro solo de pensarlo." "me parte en dos." "no es justo." "la vida es muy cruel." "no merecía esto." "es muy duro de aceptar."
    "estoy muy confundida." "no sé qué hacer." "necesito tiempo para pensarlo." "me siento perdida." "todo está muy confuso." "no tengo las ideas claras." "necesito poner orden en mi cabeza."
    "tengo mucho miedo." "me aterra lo que pueda pasar." "no quiero ni pensarlo." "me da pánico." "tiemblo solo de imaginarlo." "prefiero no saber nada." "mejor que no pase nada."
    "estoy muy orgullosa." "me siento muy satisfecha." "lo he conseguido." "valió la pena el esfuerzo." "estoy donde quería estar." "he cumplido mi sueño." "soy muy afortunada."
    "me siento culpable." "debería haber hecho más." "fue culpa mía." "me reprocho no haber actuado." "no me puedo perdonar." "cargó con esa culpa." "me remuerde la conciencia."
    "estoy muy agradecida." "no sé cómo pagárselo." "le debo tanto." "nunca lo olvidaré." "siempre le estaré agradecida." "es un ángel en mi vida." "qué haría sin ella."
    "ya veremos qué pasa." "el tiempo dirá." "habrá que esperar." "todo llega cuando tiene que llegar." "si tiene que ser, será." "lo que tenga que pasar, pasará." "el destino decidirá."
    "me da igual ya." "que sea lo que tenga que ser." "estoy cansada de luchar." "no me importa nada." "paso de todo." "que hagan lo que quieran." "ya no me afecta."
    "voy a luchar hasta el final." "no me voy a rendir." "seguiré adelante." "lo voy a conseguir." "tengo que ser fuerte." "no me van a vencer." "saldré de esta."
    "necesito estar sola." "quiero desaparecer." "me voy a tomar un tiempo." "necesito encontrarme." "voy a cuidar de mí." "es mi momento." "me lo merezco."
    "todo va a cambiar." "se acerca algo grande." "presiento que viene algo bueno." "las cosas van a mejorar." "lo mejor está por llegar." "vienen tiempos mejores."
  )
  
# INTENSIFICADORES - Nueva categoría para dar más dramatismo
# Espacios vacíos para que no siempre haya intensificador
  local intensificadores=( 
    "" "" "" "" "" "" "" ""
    "realmente" "verdaderamente" "absolutamente" "completamente" "totalmente" "súper" "ultra" "mega" "hiper" "extremadamente"
    "increíblemente" "tremendamente" "enormemente" "profundamente" "intensamente" "apasionadamente" "desesperadamente"
    "muy muy" "pura y simplemente" "sin lugar a dudas" "categóricamente" "rotundamente" "tajantemente" "clarísimamente"
  )
  
# EMOCIONES ADICIONALES - Nueva categoría 
# Espacios para que no siempre aparezca
  local emociones=( 
    "" "" "" "" "" ""
    "con lágrimas en los ojos" "temblando de emoción" "radiante de felicidad" "muerta de risa" "loca de alegría" "llena de amor"
    "rota de dolor" "destrozada" "hecha polvo" "hundida" "devastada" "desconsolada" "inconsolable"
    "furiosa" "indignada" "cabreada" "mosqueda" "enfadadísima" "que echaba humo" "que no veía ni tortas"
    "nerviosa como un flan" "angustiada" "agobiada" "estresada" "preocupadísima" "inquieta" "intranquila"
    "emocionadísima" "eufórica" "exultante" "jubilosa" "rebosante de felicidad" "que no cabía en sí de gozo"
  )
  
# Selección aleatoria de elementos
  local sujeto="${sujetos[$RANDOM % ${#sujetos[@]}]}"
  local verbo="${verbos[$RANDOM % ${#verbos[@]}]}"
  local intensif="${intensificadores[$RANDOM % ${#intensificadores[@]}]}"
  local accion="${acciones[$RANDOM % ${#acciones[@]}]}"
  local indirecto="${comp_ind[$RANDOM % ${#comp_ind[@]}]}"
  local circunst="${comp_circ[$RANDOM % ${#comp_circ[@]}]}"
  local emocion="${emociones[$RANDOM % ${#emociones[@]}]}"
  local conector="${conectores[$RANDOM % ${#conectores[@]}]}"
  local cierre="${cierres[$RANDOM % ${#cierres[@]}]}"
  
# Construcción de la frase con lógica mejorada
  local frase="$sujeto $verbo"
  
# Añadir intensificador si existe
  if [[ -n "$intensif" ]]; then
    frase="$frase $intensif"
  fi
  
  frase="$frase $accion $indirecto $circunst"
  
# Añadir emoción si existe
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
# PRIMERA EJECUCIÓN
# ============================================================

frase="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase"
echo "$frase" >> "$MEMORIA"

# Construir prompt simple
cat > "$TEMP_DIR/prompt1.txt" << EOF
Eres un asistente empático. Responde en 1-2 frases cortas.

$(tail -8 "$MEMORIA")

EOF

# Ejecutar modelo
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

# Extraer respuesta (últimas 5 líneas sin basura técnica)
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
  echo "❌ Sin respuesta" >&2
fi

# ============================================================
# SEGUNDA EJECUCIÓN
# ============================================================

frase2="$(generar_frase)"
echo -e "\n💬 [Gustavo]: $frase2"
echo "$frase2" >> "$MEMORIA"

cat > "$TEMP_DIR/prompt2.txt" << EOF
Eres un asistente empático. Responde en 1-2 frases cortas.

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
  echo "❌ Sin respuesta en segunda ejecución" >&2
fi
