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

El laboratorio doméstico utilizará dos equipos anfitriones:

- **PC doméstico:** AMD Ryzen 5 3400G (4 núcleos/8 hilos), 16 GB de RAM, Linux Mint y SSD con unos 700 GB según estimación; falta confirmar el espacio libre exacto.
- **Portátil ASUS ExpertBook B3605CCA:** Intel Core Ultra 5 125H (14 núcleos/18 hilos), 32 GB de RAM, Linux Mint 22.3 y SanDisk Portable SSD de 931,5 GB conectado por USB 3.2. Tiene unos 89 GB libres en `/` y 613 GB en `/home`.
- El SSD Samsung interno de 1 TB del portátil queda excluido del laboratorio.

- [x] Procesador y núcleos/hilos disponibles.
- [x] RAM de ambos anfitriones.
- [x] Almacenamiento del portátil y espacio libre.
- [ ] Confirmar capacidad y espacio libre exactos del SSD del PC doméstico.
- [ ] Revisar interfaces de red físicas de ambos equipos.
- [ ] Comprobar cuántas VM pueden ejecutarse simultáneamente sin saturar los anfitriones.
- [x] Identificar la plataforma de virtualización: VirtualBox.

## 3. Qué pasaría si se pierde un disco

Predicción inicial: si los datos solo están en un disco y este falla, podrían perderse. La recuperación dependería de una copia de seguridad válida o de un mecanismo de redundancia. RAID y copias de seguridad no son lo mismo; se investigarán y probarán sus diferencias.

## 4. Revisión final

| Predicción inicial | Resultado observado | ¿Se confirma? | Evidencia |
|---|---|---|---|
| Pendiente de revisar | | | |
