# ASIR ThinkLab — Laboratorio doméstico de virtualización

## Descripción
Repositorio para documentar la preparación y evolución de un entorno de pruebas doméstico para ASIR. El laboratorio se adapta a los recursos disponibles y permite practicar virtualización, redes, servicios, almacenamiento, recuperación y monitorización.

> **Estado:** en construcción. Los datos marcados como pendientes deben comprobarse antes de considerarlos definitivos.

## Objetivos
- Documentar el hardware y los recursos asignados a cada máquina virtual.
- Diseñar y comprobar una red virtual.
- Investigar y probar sistemas operativos, almacenamiento, copias de seguridad y monitorización.
- Registrar incidencias, soluciones, evidencias y resultados.

## Estado actual conocido

| Elemento | Estado |
|---|---|
| Equipo anfitrión | AMD Ryzen 5 3400G, 16 GB de RAM |
| Virtualizador | VirtualBox |
| VM inicial | Debian 13 Server, sin entorno gráfico |
| Adaptador NAT | Se observó `enp0s3` con `10.0.2.15/24` |
| Red interna de VirtualBox | Nombre configurado: `asir_lab` |
| Segundo adaptador detectado en Debian | Pendiente de comprobar |
| IP de la red interna | Pendiente |
| Espacio libre del SSD | Pendiente |
| Recursos exactos de la VM | Pendiente de verificar en VirtualBox |
| Conectividad entre VM | Pendiente de probar |

## Estructura
- `docs/00-prediccions.md`: predicciones iniciales.
- `docs/01-requisits.md`: necesidades y requisitos.
- `docs/02-inventari.md`: inventario y diagnóstico del equipo.
- `docs/03-sistemes.md`: comparación de sistemas.
- `docs/04-entorn-virtualitzacio.md`: máquinas virtuales y recursos.
- `docs/05-xarxa.md`: diseño y pruebas de red.
- `docs/06-proves-incidencies.md`: pruebas e incidencias.
- `diagramas/`: diagramas de arquitectura y red.
- `evidencies/`: capturas y salidas de comandos.

## Flujo de trabajo
1. Completar los documentos conforme se realicen las prácticas.
2. No marcar una prueba como realizada hasta ejecutarla y comprobarla.
3. Añadir evidencias cuando aporten información útil.
4. Registrar fecha, resultado, problema y solución.
5. Actualizar este README cuando cambie el estado real del laboratorio.

## Comandos Git
Desde la carpeta del proyecto:

```bash
git status
git add README.md docs/ diagramas/ evidencies/ .gitignore
git commit -m "docs: documentar el laboratorio inicial"
```

## Seguridad
No subir contraseñas, claves privadas, tokens, archivos `.env`, discos virtuales ni imágenes ISO pesadas. El repositorio debe contener documentación y evidencias seleccionadas, no copias completas de las máquinas virtuales.
