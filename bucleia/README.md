# 🧠 bucleia – IA Autogenerativa en Bucle Local

Este script permite lanzar un modelo local (basado en `llama.cpp`) con un comportamiento **autosintético**:  
la IA parte de una única instrucción inicial (`prompbucle.txt`) y evoluciona de forma autónoma, reescribiendo su propio input (`nexo.txt`) tras cada ejecución.

## ⚙️ ¿Qué hace?

- Ejecuta un modelo `.gguf` usando un prompt combinado del sistema y del último input generado.
- Filtra la salida para capturar únicamente el bloque útil generado por la IA (entre `[[` y `]]`).
- Reescribe automáticamente el archivo de entrada (`nexo.txt`) con la respuesta generada.
- Guarda una copia completa de cada sesión en `sesiones/` y los logs completos en `logs/`.

> Cada vez que se ejecuta, el sistema se retroalimenta: **la IA se instruye a sí misma** a partir de su propia salida anterior.

## 📁 Estructura esperada

Dentro del mismo directorio del script `bucleia.sh` deben encontrarse los siguientes archivos:

- `llama-cli` → binario de `llama.cpp`
- `mistral-7b-instruct-v0.1.Q6_K.gguf` → modelo local
- `prompbucle.txt` → prompt inicial del sistema
- `nexo.txt` → primer input, se sobreescribe con cada respuesta

Y se generarán automáticamente:

- `sesiones/` → copias .md de cada sesión generada
- `logs/` → registros completos de ejecución

## 🧪 Requisitos

- Bash (macOS / Linux)
- `llama.cpp` compilado
- Un modelo `.gguf` compatible

## 🚀 Ejecución

```bash
chmod +x bucleia.sh
./bucleia.sh
```

## 💡 Uso creativo

Ideal para simulaciones en bucle, agentes autónomos narrativos o pruebas de IA que deben evolucionar sin intervención externa.  
Diseñado para entornos offline, reproducibles y totalmente locales.

---

Creado por **Eto Demerzel**

**Eto Demerzel** (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com  
https://github.com/BiblioGalactic
