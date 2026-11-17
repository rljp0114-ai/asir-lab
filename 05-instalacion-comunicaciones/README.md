# Tarea 5 — Instalación y comunicaciones

Sistemas instalados y configurados en la red `192.168.34.0/24`. Los routers se prueban de uno en uno (comparten red e IP). El servidor de copias es TrueNAS (`192.168.34.20`, usuario `nasbackup`). Todas las pruebas de salida a Internet se hacen por TCP, porque la red del aula filtra ICMP (ver [incidencias](../incidencias/incidencias.md)).

## Routers y firewalls

| Sistema | Documento | Incluye | Estado |
|---|---|---|---|
| Ubuntu Server + nftables (LAN `.3`) | [`configuracion/ubuntunftables.md`](configuracion/ubuntunftables.md) | Instalación, reglas y NAT, bloqueo con registro, copia en TrueNAS, fallo y recuperación, persistencia | 🟡 ✅ |
| MikroTik RouterOS 7.24.5 (LAN `.3`) | [`configuracion/mikrotik.md`](configuracion/mikrotik.md) | Versión, red, regla de bloqueo con registro, pruebas desde Debian | ✅ |
| OPNsense 26.7.9 (LAN `.2`) | [`configuracion/opnsense.md`](configuracion/opnsense.md) | Versión, usuarios, red, bloqueo y permitido, registro, copia y recuperación | ✅ |

## Servidor de copias

| Sistema | Documento | IP | Estado |
|---|---|---|---|
| TrueNAS 13.0-U5.3 | [`configuracion/truenas.md`](configuracion/truenas.md) | `192.168.34.20` | ✅ |

## Servidores y clientes

| Sistema | Documento | IP | Estado |
|---|---|---|---|
| Windows Server 2025 Standard Evaluation | [`configuracion/windows-server-2025.md`](configuracion/windows-server-2025.md) | `192.168.34.21` | ✅ (incluye explicación de dominio) |
| Windows 11 Home (cliente) | [`configuracion/windows-11.md`](configuracion/windows-11.md) | `192.168.34.100` | ✅ |
| Debian 13 (cliente GNU/Linux) | [`configuracion/debian-cliente.md`](configuracion/debian-cliente.md) | `192.168.34.4` | ✅ |
| Servidores GNU/Linux de infraestructura (`Linux-Servicios`, `Linux-Datos`) | [`configuracion/linux-infraestructura.md`](configuracion/linux-infraestructura.md) | `.22` y `.23` | ✅ |

## Proxmox

Clúster `asirlab` de tres nodos (`pve1`, `pve2`, `pve3`) sobre VirtualBox en el PC de 16 GB, con un contenedor y una VM Debian sin entorno gráfico migrados entre nodos (tiempos y espacio medidos) y copia de la configuración a TrueNAS. **Estado: ✅.** Detalle en [`configuracion/proxmox.md`](configuracion/proxmox.md); incidencias en [`../incidencias/incidencias.md`](../incidencias/incidencias.md).

## Otros documentos

- [`configuraciones-criticas.md`](configuraciones-criticas.md): configuración crítica, problemas y tiempos de recuperación por sistema.
- Evidencias: [`evidencies/`](evidencies/).

## Pendiente

- Windows Server 2025: nombre del equipo.
