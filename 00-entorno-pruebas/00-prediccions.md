# 00. Predicciones iniciales

**Fecha de las predicciones:** inicio del proyecto. **Revisión final:** 17/11/2026.

Este documento recoge las predicciones antes de investigar y diseñar el laboratorio. Se revisarán al final.

## 1. Sistemas que podría necesitar

| Función | Predicción inicial | Motivo o duda |
|---|---|---|
| Equipo cliente | Sin decidir al inicio | Debe permitir probar acceso a servicios y conectividad |
| Servidor de datos | Debian Server es una opción a investigar | Puede alojar datos y servicios de prueba |
| Comunicaciones / cortafuegos | Sin decidir al inicio | Permitiría estudiar reglas y separación de redes |

## 2. Hardware que conviene comprobar

El laboratorio doméstico utilizará dos equipos anfitriones:

- **PC doméstico:** AMD Ryzen 5 3400G (4 núcleos/8 hilos), 16 GB de RAM, Linux Mint y el mismo SanDisk Portable SSD de 931,5 GB que usa el portátil.
- **Portátil ASUS ExpertBook B3605CCA:** Intel Core Ultra 5 125H (14 núcleos/18 hilos), 32 GB de RAM, Linux Mint 22.3 y SanDisk Portable SSD de 931,5 GB conectado por USB 3.2. Tiene unos 89 GB libres en `/` y 613 GB en `/home`.
- El SSD Samsung interno de 1 TB del portátil queda excluido del laboratorio.

- [x] Procesador y núcleos/hilos disponibles.
- [x] RAM de ambos anfitriones.
- [x] Almacenamiento del portátil y espacio libre.
- [x] Confirmar capacidad y espacio libre del SSD: el laboratorio entero está en un único SanDisk Portable SSD de 931,5 GB (`/home` de 795 GB con 559 GB libres) que se conecta al PC o al portátil.
- [x] Revisar interfaces de red físicas de ambos equipos: `enp8s0` en el PC y `eno1` en el portátil.
- [x] Comprobar cuántas VM pueden ejecutarse simultáneamente sin saturar los anfitriones: medido en el PC en la tarea 7 ([`informe-rendimiento.md`](../07-rendimiento-diagnostico/informe-rendimiento.md)).
- [x] Identificar la plataforma de virtualización: VirtualBox.

## 3. Qué pasaría si se pierde un disco

Predicción inicial: si los datos solo están en un disco y este falla, podrían perderse. La recuperación dependería de una copia de seguridad válida o de un mecanismo de redundancia. RAID y copias de seguridad no son lo mismo; se investigarán y probarán sus diferencias.

## 4. Revisión final

| Predicción inicial | Resultado observado | ¿Se confirma? | Evidencia |
|---|---|---|---|
| El cliente se decidiría más adelante | Se usan clientes Windows 11 y Debian | Sí, con dos clientes en lugar de uno | [`05-.../configuracion/`](../05-instalacion-comunicaciones/configuracion/) |
| Debian Server podría alojar datos y servicios | Hay además Linux-Servicios y Linux-Datos, Windows Server 2025 y TrueNAS como servidor de copias | Parcial: se repartió en más sistemas | [`04-entorn-virtualitzacio.md`](04-entorn-virtualitzacio.md) |
| Un cortafuegos permitiría estudiar reglas y separación de redes | Hay routers MikroTik y OPNsense y un Ubuntu Server con nftables, con pruebas de bloqueo y registros | Sí | [`ubuntunftables.md`](../05-instalacion-comunicaciones/configuracion/ubuntunftables.md) |
| Si se pierde un disco, los datos podrían perderse | La protección depende de la copia de seguridad o de la redundancia; RAID y copia no son lo mismo | Sí | [`../06-almacenamiento-recuperacion/`](../06-almacenamiento-recuperacion/) |
| Las VM cabrían en los equipos | En el PC de 16 GB caben 5 VM del proyecto a la vez, o el router y el clúster Proxmox; no ambos | Parcial: la memoria es el límite | [`informe-rendimiento.md`](../07-rendimiento-diagnostico/informe-rendimiento.md) |
| Los dos equipos repartirían la carga | Todo el laboratorio vive en un solo SSD que se conecta a un equipo cada vez | No: se usa un equipo cada vez | [`04-entorn-virtualitzacio.md`](04-entorn-virtualitzacio.md) |
