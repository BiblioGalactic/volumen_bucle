# volumen_bucle

No hice este repo para demostrar que Bash es elegante. Lo hice para ver hasta donde podia empujar un bucle local con el minimo de piezas posibles: `llama.cpp`, archivos de memoria, prompts y paciencia.

## Que contiene

Hoy el repo agrupa 13 directorios de variante o idioma y un nucleo compartido en `lib/`. Lo importante no es la cantidad de carpetas, sino la idea repetida: una instruccion inicial, una memoria en archivo y un sistema que sigue iterando sin que yo lo empuje cada vez.

## Por que me quede en Bash

Porque queria ver el mecanismo entero. En Bash todo queda a la vista: rutas, temporales, logs, prompts, rotacion y puntos de fallo. El coste es obvio:

- menos ergonomia,
- mas fragilidad en quoting y rutas,
- y bastante repeticion entre variantes.

## Lo que si me dio este enfoque

- wrappers pequenos por idioma,
- loops faciles de inspeccionar,
- y la posibilidad de cambiar una pieza sin perder el resto del flujo.

## Deuda honesta

- no todo aqui es bonito ni uniforme,
- varias carpetas existen porque preferi conservar el experimento antes que limpiar su historia,
- estos bucles sirven para explorar continuidad y autorregulacion, no para vender "autonomia" como eslogan.
