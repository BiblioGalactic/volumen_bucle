# autoconversacion.sh

**Script de Conversa amb Mistral**

Aquest script permet interactuar amb el model de llenguatge Mistral mitjançant `llama-cli` per generar converses empàtiques i realistes. Combina la creativitat de la intel·ligència artificial amb un sistema de generació de frases aleatòries que incorpora subjectes, verbs, accions, complements i emocions, aconseguint diàlegs més humans i variats. A més, l'script manté un historial de les interaccions i gestiona arxius temporals de manera automàtica, garantint que el flux de treball sigui net i segur.

## Funcionalitat

L'script crea frases aleatòries a partir d'una combinació d'elements lingüístics acuradament seleccionats per transmetre emocions i context. Cada execució produeix noves frases que es desen en un arxiu de memòria (`MEMORIA`), permetent al model referir-se a l'historial i generar respostes coherents i contextualment enriquides.

Es realitzen dues rondes d'interacció per execució: la primera genera la frase inicial i obté la resposta del model, mentre que la segona usa l'historial de la conversa per crear continuïtat i profunditat en el diàleg.

Tots els arxius temporals generats durant l'execució s'eliminen automàticament en finalitzar, evitant acumulació de dades i mantenint l'entorn net (`TEMP_DIR`).

## Ús

Per executar l'script, primer fes-lo executable amb `chmod +x autoconversacion.sh`.

Després, llança l'script amb `./autoconversacion.sh` des del terminal.

Durant l'execució, se sol·licitaran les rutes necessàries per al correcte funcionament: la ubicació del model (`MODELO_PATH`), el binari d'execució (`MAIN_BINARY`), l'arxiu on s'emmagatzemarà la memòria de la conversa (`MEMORIA`) i el directori temporal (`TEMP_DIR`).

Un cop finalitzat, podràs consultar la conversa generada directament a la consola i revisar l'historial complet a l'arxiu de memòria. Això permet seguir la continuïtat de la conversa i reutilitzar dades per futures execucions.

## Requisits

L'script està dissenyat per executar-se en macOS amb Bash 5 o superior.

És necessari tenir el model Mistral en format `.gguf` i el binari `llama-cli` correctament compilat i funcional.

Es recomana comptar amb suficients recursos de CPU i memòria per permetre que el model processi els prompts de manera eficient, especialment en sessions prolongades.

## Consideracions addicionals

Aquest script és especialment útil per experiments de generació de text, simulacions de converses, proves de models de llenguatge i creació de continguts interactius.

Es recomana revisar periòdicament l'arxiu de memòria per avaluar la coherència i ajustar paràmetres de generació en `llama-cli` segons sigui necessari.

El disseny modular permet ampliar les funcions de generació de frases, afegir nous subjectes, verbs o emocions, i personalitzar el comportament de la interacció sense modificar la lògica central.

**Eto Demerzel** (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com  
https://github.com/BiblioGalactic