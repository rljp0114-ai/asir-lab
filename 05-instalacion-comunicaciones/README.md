# Tarea 5 — Instalación y comunicaciones

Sistemas instalados y configurados en la red `192.168.34.0/24`. Los routers se prueban de uno en uno (comparten red e IP). El servidor de copias es TrueNAS (`192.168.34.20`, usuario `nasbackup`). Todas las pruebas de salida a Internet se hacen por TCP, porque la red del aula filtra ICMP (ver [incidencias](../08-final-incidencias/06-proves-incidencies.md)).

## Routers y firewalls

| Sistema | Documento | Incluye | Estado |
|---|---|---|---|
| Ubuntu Server + nftables (LAN `.3`) | [`configuracion/ubuntunftables.md`](configuracion/ubuntunftables.md) | Instalación, reglas y NAT, bloqueo con registro, copia en TrueNAS, fallo y recuperación, persistencia | 🟡 faltan algunas capturas de reglas |
| MikroTik RouterOS 7.24.5 (LAN `.3`) | [`configuracion/mikrotik.md`](configuracion/mikrotik.md) | Versión, red, regla de bloqueo con registro, pruebas desde Debian | ✅ |
| OPNsense 26.7.9 (LAN `.2`) | [`configuracion/opnsense.md`](configuracion/opnsense.md) | Versión, usuarios, red, bloqueo y permitido, registro, copia y recuperación | ✅ |

## Servidor de copias

TrueNAS 13.0-U5.3 (`192.168.34.20`). Su instalación, la creación de usuario y las copias por SFTP de los routers están en [`../evidencies/Comandos.md`](../evidencies/Comandos.md); no tiene documento propio todavía. **Pendiente:** captura del disco adicional dedicado a copias y poner la zona horaria en `Europe/Madrid`.

## Servidores y clientes

| Sistema | Documento | IP | Estado |
|---|---|---|---|
| Windows Server 2025 Standard Evaluation | [`configuracion/windows-server-2025.md`](configuracion/windows-server-2025.md) | `192.168.34.21` | ✅ (incluye explicación de dominio) |
| Windows 11 Home (cliente) | [`configuracion/windows-11.md`](configuracion/windows-11.md) | `192.168.34.100` | ✅ |
| Debian 13 (cliente GNU/Linux) | [`configuracion/debian-cliente.md`](configuracion/debian-cliente.md) | `192.168.34.4` | ✅ |
| Servidores GNU/Linux de infraestructura (`Linux-Servicios`, `Linux-Datos`) | [`configuracion/linux-infraestructura.md`](configuracion/linux-infraestructura.md) | `.22` y `.23` | ✅ |

## Proxmox

Plan: clúster de tres nodos sobre VirtualBox, con creación de un contenedor y migración de un contenedor y de una VM Debian sin entorno gráfico entre nodos, midiendo tiempo y espacio. Previsto en el portátil. Detalle y riesgos en [`../00-entorno-pruebas/04-entorn-virtualitzacio.md`](../00-entorno-pruebas/04-entorn-virtualitzacio.md) (apartado 8). **Estado: teoría redactada en [`configuracion/proxmox.md`](configuracion/proxmox.md); instalación, clúster y migración pendientes** (las tres VM están creadas; falta instalar).

## Otros documentos

[`03-sistemes.md`](03-sistemes.md): comparación de sistemas candidatos antes de decidir qué instalar (🟡 revisar). Evidencias: [`evidencies/`](evidencies/).
