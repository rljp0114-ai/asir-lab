# ASIR ThinkLab — Parte individual

Laboratorio individual del proyecto **ASIX ThinkLab** (enunciado V2.0, 19/10/2026), montado en VirtualBox sobre hardware doméstico. El repositorio está organizado **por tareas del enunciado**: cada carpeta lleva el número y el título de su tarea, un `README.md` con lo que contiene y su estado, y su propia carpeta `evidencies/` con las capturas.

Leyenda: ✅ hecho y comprobado · 🟡 parcial o con puntos pendientes · ⬜ pendiente

| Tarea | Título del enunciado | Carpeta | Estado |
|---|---|---|---|
| 0 | Montaje del entorno de pruebas | [`00-entorno-pruebas/`](00-entorno-pruebas/) | 🟡 |
| 2 | Equipos y periféricos | [`02-equipos-perifericos/`](02-equipos-perifericos/) | 🟡 |
| 4 | Diseño físico y lógico | [`04-diseno-red/`](04-diseno-red/) | ✅ |
| 5 | Instalación y comunicaciones | [`05-instalacion-comunicaciones/`](05-instalacion-comunicaciones/) | ✅ |
| 6 | Almacenamiento y recuperación | [`06-almacenamiento-recuperacion/`](06-almacenamiento-recuperacion/) | 🟡 |
| 7 | Rendimiento y diagnóstico | [`07-rendimiento-diagnostico/`](07-rendimiento-diagnostico/) | ✅ (sin ampliación) |
| 8 | Final | [`08-final-incidencias/`](08-final-incidencias/) | ⬜ (caso final el 25/11/2026) |

Las tareas 1 (necesidades y sistemas) y 3 (rack e interconexión) aparecen en el enunciado, pero no en la rúbrica de autoevaluación individual, por lo que no tienen carpeta propia.

## Cómo está organizado cada apartado

- `README.md` de cada tarea: qué documentos y evidencias contiene y qué está hecho o pendiente.
- Documentos `.md`: explicación de lo realizado, con tablas de configuración y resultados de las pruebas.
- `evidencies/` dentro de cada tarea: capturas, con nombre `fecha-sistema-prueba.png`. Cada documento cita sus capturas por su ruta.
- [`evidencies/Comandos.md`](evidencies/Comandos.md): registro general de comandos utilizados durante el laboratorio (se conserva íntegro).

## Entorno

Linux Mint y VirtualBox 7.0.20 instalados en un SSD externo SanDisk que se conecta al PC doméstico (Ryzen 5 3400G, 16 GB) o al portátil ASUS (Core Ultra 5 125H, 32 GB); las máquinas virtuales están en ese mismo disco, por lo que el laboratorio se ejecuta en un equipo cada vez. Detalle en [`00-entorno-pruebas/04-entorn-virtualitzacio.md`](00-entorno-pruebas/04-entorn-virtualitzacio.md).

La red interna del laboratorio es `192.168.34.0/24` (puesto 34 del aula).

## Forma de trabajo

1. Avanzar siguiendo el orden y los criterios de la rúbrica individual.
2. No marcar una tarea como completada si no se ha probado.
3. Registrar las incidencias relevantes y las soluciones que han funcionado.
4. No subir contraseñas, claves privadas, tokens, discos virtuales ni imágenes ISO.
