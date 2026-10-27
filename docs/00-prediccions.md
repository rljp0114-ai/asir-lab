# 00. Predicciones iniciales

**Fecha:** completar con la fecha real.

Este documento recoge las predicciones antes de investigar y diseñar el laboratorio. Se revisarán al final.

## 1. Sistemas que podría necesitar

| Función | Predicción inicial | Motivo o duda |
|---|---|---|
| Equipo cliente | Pendiente de decidir | Debe permitir probar acceso a servicios y conectividad |
| Servidor de datos | Debian Server es una opción a investigar | Puede alojar datos y servicios de prueba |
| Comunicaciones / cortafuegos | Pendiente de decidir | Permitiría estudiar reglas y separación de redes |

## 2. Hardware que conviene comprobar

- [ ] Procesador y núcleos/hilos disponibles.
- [x] RAM del anfitrión: 16 GB (dato conocido; confirmar si ha cambiado).
- [ ] Capacidad y espacio libre del SSD.
- [ ] Interfaces de red físicas.
- [ ] Capacidad para ejecutar varias VM simultáneamente.
- [ ] Espacio necesario para discos virtuales y evidencias.

## 3. Qué pasaría si se pierde un disco

Predicción inicial: si los datos solo están en un disco y este falla, podrían perderse. La recuperación dependería de una copia de seguridad válida o de un mecanismo de redundancia. RAID y copias de seguridad no son lo mismo; se investigarán y probarán sus diferencias.

## 4. Revisión final

| Predicción inicial | Resultado observado | ¿Se confirma? | Evidencia |
|---|---|---|---|
| Pendiente de revisar | | | |
