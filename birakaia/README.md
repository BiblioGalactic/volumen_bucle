# 🧠 bucleia – IA Autosortze Begizte Lokalean

Script honek modelo lokal bat (llama.cpp-n oinarritua) portaera **autosintetikoarekin** abiaraztea ahalbidetzen du:
IAk hasierako instrukzio bakar batetik (prompbucle.txt) abiatzen da eta modu autonomoan eboluzionatzen du, bere sarrera propioaren (`nexo.txt`) berridatziz exekuzio bakoitzaren ondoren.

## ⚙️ Zer egiten du?

- `.gguf` modelo bat exekutatzen du sistemaren prompt-a eta sortutako azken sarrera konbinatua erabiliz.
- Irteera filtratzen du IAk sortutako bloke erabilgarria soilik hartzeko (`[[` eta `]]` artean).
- Sarrera-fitxategia (`nexo.txt`) automatikoki berridazten du sortutako erantzunarekin.
- Saio bakoitzaren kopia osoa gordetzen du `sesiones/`-en eta log osoak `logs/`-en.

> Exekutatzen den bakoitzean, sistema autoelimentatzen da: **IAk bere buruari instrukzioak ematen dizkio** bere aurreko irteeratik abiatuta.

## 📁 Espero den egitura

`bucleia.sh` script-aren direktorio berean fitxategi hauek egon behar dira:

- `llama-cli` → `llama.cpp`-ren binarioa
- `mistral-7b-instruct-v0.1.Q6_K.gguf` → modelo lokala
- `prompbucle.txt` → sistemaren hasierako prompt-a
- `nexo.txt` → lehenengo sarrera, erantzun bakoitzarekin gainidazten da

Eta automatikoki sortuko dira:

- `sesiones/` → sortutako saio bakoitzaren .md kopiak
- `logs/` → exekuzioaren erregistro osoak

## 🧪 Eskakizunak

- Bash (macOS / Linux)
- `llama.cpp` konpilatua
- `.gguf` modelo bateragarri bat

## 🚀 Exekuzioa


chmod +x bucleia.sh
./bucleia.sh


## 💡 Erabilera sortzailea

Ideala begizteko simulazioentzat, agente autonomo narratiboentzat edo kanpoko esku-hartzerik gabe eboluzionatu behar duten IAren probetarako.
Offline inguruneetarako diseinatua, erreproduzitu daitezkeenak eta guztiz lokalak.

---

**Eto Demerzel**-ek sortua

**Eto Demerzel** (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com  
https://github.com/BiblioGalactic
```