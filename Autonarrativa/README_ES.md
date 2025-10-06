# autoconversacion.sh

**Script de Conversación con Mistral**

Este script permite interactuar con el modelo de lenguaje Mistral mediante `llama-cli` para generar conversaciones empáticas y realistas. Combina la creatividad de la inteligencia artificial con un sistema de generación de frases aleatorias que incorpora sujetos, verbos, acciones, complementos y emociones, logrando diálogos más humanos y variados. Además, el script mantiene un historial de las interacciones y maneja archivos temporales de manera automática, garantizando que el flujo de trabajo sea limpio y seguro.

## Funcionalidad

El script crea frases aleatorias a partir de una combinación de elementos lingüísticos cuidadosamente seleccionados para transmitir emociones y contexto. Cada ejecución produce nuevas frases que se guardan en un archivo de memoria (`MEMORIA`), permitiendo al modelo referirse al historial y generar respuestas coherentes y contextualmente enriquecidas.  

Se realizan dos rondas de interacción por ejecución: la primera genera la frase inicial y obtiene la respuesta del modelo, mientras que la segunda usa el historial de la conversación para crear continuidad y profundidad en el diálogo.  

Todos los archivos temporales generados durante la ejecución se eliminan automáticamente al finalizar, evitando acumulación de datos y manteniendo el entorno limpio (`TEMP_DIR`).

## Uso

Para ejecutar el script, primero hazlo ejecutable con `chmod +x autoconversacion.sh`.  
Luego, lanza el script con `./autoconversacion.sh` desde la terminal.  

Durante la ejecución, se solicitarán las rutas necesarias para el correcto funcionamiento: la ubicación del modelo (`MODELO_PATH`), el binario de ejecución (`MAIN_BINARY`), el archivo donde se almacenará la memoria de la conversación (`MEMORIA`) y el directorio temporal (`TEMP_DIR`).  

Una vez finalizado, podrás consultar la conversación generada directamente en la consola y revisar el historial completo en el archivo de memoria. Esto permite seguir la continuidad de la conversación y reutilizar datos para futuras ejecuciones.

## Requisitos

El script está diseñado para ejecutarse en macOS con Bash 5 o superior.  
Es necesario tener el modelo Mistral en formato `.gguf` y el binario `llama-cli` correctamente compilado y funcional.  
Se recomienda contar con suficientes recursos de CPU y memoria para permitir que el modelo procese los prompts de manera eficiente, especialmente en sesiones prolongadas.

## Consideraciones adicionales

Este script es especialmente útil para experimentos de generación de texto, simulaciones de conversaciones, pruebas de modelos de lenguaje y creación de contenidos interactivos.  
Se recomienda revisar periódicamente el archivo de memoria para evaluar la coherencia y ajustar parámetros de generación en `llama-cli` según sea necesario.  
El diseño modular permite ampliar las funciones de generación de frases, agregar nuevos sujetos, verbos o emociones, y personalizar el comportamiento de la interacción sin modificar la lógica central.


**Eto Demerzel** (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com  
https://github.com/BiblioGalactic