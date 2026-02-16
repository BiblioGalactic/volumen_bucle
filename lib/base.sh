#!/usr/bin/env bash
# ============================================================
# 🔄 VOLUMEN BUCLE — Motor Base Compartido
# ============================================================
# Lógica común para todos los loop scripts (bucleia, loopai,
# rodaia, birakaia, ループAI, 循环AI).
#
# Uso desde un script variante:
#   LOOP_LANG="es"                            # idioma i18n
#   LOOP_PROMPT_SISTEMA="prompbucle.txt"      # nombre del prompt sistema
#   LOOP_PROMPT_FILE="nexo.txt"               # nombre del archivo de diálogo
#   LOOP_SESSIONS_DIR="sesiones"              # nombre del directorio de sesiones
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/base.sh"
# ============================================================
set -euo pipefail

# === 📍 Resolver raíz del proyecto ===
LOOP_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
VOLUMEN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_ROOT="$(cd "$VOLUMEN_ROOT/.." && pwd)"
EXPUESTO_ROOT="${WORKSPACE_ROOT}/Expuesto"

# === 📦 Cargar librería común si existe ===
if [[ -f "$EXPUESTO_ROOT/lib/bash-common.sh" ]]; then
    source "$EXPUESTO_ROOT/lib/bash-common.sh"
    load_config
fi

# --help para scripts que sourcean base.sh
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<'HELP'
Uso: ./<variante>.sh [--help]

Descripción:
  Motor base del sistema volumen_bucle. Carga i18n, configura rutas,
  rota logs y ejecuta run_loop() para inferencia con llama-cli.

Variables requeridas (definidas por el wrapper):
  LOOP_LANG           Idioma (es|en|cat|eus|jp|zh|fr)
  LOOP_PROMPT_SISTEMA Nombre del archivo de prompt del sistema
  LOOP_PROMPT_FILE    Nombre del archivo de diálogo
  LOOP_SESSIONS_DIR   Nombre del directorio de sesiones

Variables de entorno opcionales:
  LLAMA_CLI           Ruta al binario llama-cli
  MODELO              Ruta al modelo GGUF
  LLAMA_CTX_SIZE      Tamaño de contexto (default: 31000)
  LLAMA_N_PREDICT     Tokens a predecir (default: 500)
  LLAMA_TEMP          Temperatura (default: 1.2)
  LLAMA_THREADS       Hilos de CPU (default: 6)
  LOG_MAX_LINES       Máximo líneas de log antes de rotar (default: 10000)

Retorno:
  0  Éxito
  1  Archivo de prompt no encontrado
HELP
    exit 0
fi

# === 🌐 Cargar strings i18n ===
LOOP_LANG="${LOOP_LANG:-es}"
STRINGS_FILE="$VOLUMEN_ROOT/lib/strings/${LOOP_LANG}.sh"
if [[ -f "$STRINGS_FILE" ]]; then
    source "$STRINGS_FILE"
else
    # Fallback español
    MSG_NOT_FOUND="No se encontró el archivo de entrada"
    MSG_UPDATED="Archivo %s actualizado con la respuesta."
    MSG_EMPTY="Respuesta vacía. Se conserva el archivo original."
    SESSION_PREFIX="Sesion"
    LOG_FILENAME="salida.log"
fi

# === 📂 Rutas (con defaults configurables) ===
PROMPT_SISTEMA="${LOOP_DIR}/${LOOP_PROMPT_SISTEMA:-prompbucle.txt}"
PROMPT_FILE="${LOOP_DIR}/${LOOP_PROMPT_FILE:-nexo.txt}"
SESSIONS_FOLDER="${LOOP_DIR}/${LOOP_SESSIONS_DIR:-sesiones}"
LOG_FOLDER="${LOOP_DIR}/logs"

mkdir -p "$SESSIONS_FOLDER" "$LOG_FOLDER"

NOMBRE_SESION="${SESSION_PREFIX}_$(date +'%Y-%m-%d_%H-%M-%S').md"
SESSION_PATH="$SESSIONS_FOLDER/$NOMBRE_SESION"
LOG_PATH="$LOG_FOLDER/$LOG_FILENAME"

# === 🧠 Modelo (usa config centralizada o local) ===
MODELO_PATH="${MODELO:-${LOOP_DIR}/mistral-7b-instruct-v0.1.Q6_K.gguf}"
MAIN_BINARY="${LLAMA_CLI:-${LOOP_DIR}/llama-cli}"

# ============================================================
# 📊 ROTACIÓN DE LOGS (antes de ejecutar)
# ============================================================
loop_rotate_log() {
    if type -t rotate_log &>/dev/null; then
        rotate_log "$LOG_PATH"
    else
        # Fallback inline si bash-common.sh no está disponible
        local max_lines="${LOG_MAX_LINES:-10000}"
        if [[ -f "$LOG_PATH" ]]; then
            local current
            current=$(wc -l < "$LOG_PATH" 2>/dev/null || echo 0)
            if [[ "$current" -gt "$max_lines" ]]; then
                mv "$LOG_PATH" "${LOG_PATH}.1"
                touch "$LOG_PATH"
            fi
        fi
    fi
}
loop_rotate_log

# ============================================================
# ✅ VALIDACIONES
# ============================================================
[[ ! -f "$PROMPT_FILE" ]] && { echo "❌ ${MSG_NOT_FOUND}: $PROMPT_FILE"; exit 1; }

# ============================================================
# 🚀 EJECUTAR LOOP (función principal)
# ============================================================
run_loop() {
    local temp_out
    temp_out=$(mktemp)

    "$MAIN_BINARY" \
      -m "$MODELO_PATH" \
      --ctx-size "${LLAMA_CTX_SIZE:-31000}" \
      --n-predict "${LLAMA_N_PREDICT:-500}" \
      --color \
      --temp "${LLAMA_TEMP:-1.2}" \
      --threads "${LLAMA_THREADS:-6}" \
      --prompt "$(cat "$PROMPT_SISTEMA") $(cat "$PROMPT_FILE")" \
      2>&1 | grep -v 'llama_' | tee >(tee -a "$LOG_PATH") >> "$temp_out"

    # Filtrar salida: extraer solo contenido entre [[ y ]]
    sed -n '/\[\[/,/\]\]/p' "$temp_out" | sed 's/\[\[//;s/\]\]//' > "${temp_out}.clean"
    mv "${temp_out}.clean" "$temp_out"

    # Reemplazar archivo original si hubo respuesta
    if [[ -s "$temp_out" ]]; then
        cp "$temp_out" "$SESSION_PATH"
        mv "$temp_out" "$PROMPT_FILE"
        # shellcheck disable=SC2059
        printf "✅ ${MSG_UPDATED}\n" "$PROMPT_FILE"
    else
        echo "⚠️ ${MSG_EMPTY}"
        rm -f "$temp_out"
    fi
}

# Ejecutar si se invoca directamente (no solo sourced)
if [[ "${BASH_SOURCE[0]}" != "${BASH_SOURCE[1]:-}" ]] || [[ "${_LOOP_AUTO_RUN:-1}" == "1" ]]; then
    run_loop
fi
