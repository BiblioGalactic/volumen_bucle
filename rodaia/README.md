# 🧠 bucleia – IA Autogenerativa en Bucle Local

Aquest script permet llançar un model local (basat en `llama.cpp`) amb un comportament **autosintètic**:  
la IA parteix d'una única instrucció inicial (`prompbucle.txt`) i evoluciona de forma autònoma, reescrivint el seu propi input (`nexo.txt`) després de cada execució.

## ⚙️ Què fa?

- Executa un model `.gguf` utilitzant un prompt combinat del sistema i de l'últim input generat.
- Filtra la sortida per capturar únicament el bloc útil generat per la IA (entre `[[` i `]]`).
- Reescriu automàticament l'arxiu d'entrada (`nexo.txt`) amb la resposta generada.
- Desa una còpia completa de cada sessió a `sesiones/` i els logs complets a `logs/`.

> Cada vegada que s'executa, el sistema es retroalimenta: **la IA s'instrueix a si mateixa** a partir de la seva pròpia sortida anterior.

## 📁 Estructura esperada

Dins del mateix directori de l'script `bucleia.sh` han de trobar-se els següents arxius:

- `llama-cli` → binari de `llama.cpp`
- `mistral-7b-instruct-v0.1.Q6_K.gguf` → model local
- `prompbucle.txt` → prompt inicial del sistema
- `nexo.txt` → primer input, se sobreescriu amb cada resposta

I es generaran automàticament:

- `sesiones/` → còpies .md de cada sessió generada
- `logs/` → registres complets d'execució

## 🧪 Requisits

- Bash (macOS / Linux)
- `llama.cpp` compilat
- Un model `.gguf` compatible

## 🚀 Execució


chmod +x bucleia.sh
./bucleia.sh


## 💡 Ús creatiu

Ideal per simulacions en bucle, agents autònoms narratius o proves d'IA que han d'evolucionar sense intervenció externa.  
Dissenyat per entorns offline, reproduïbles i totalment locals.

---

Creat per **Eto Demerzel**

**Eto Demerzel** (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com  
https://github.com/BiblioGalactic