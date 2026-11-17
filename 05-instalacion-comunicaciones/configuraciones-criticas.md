# Configuraciones críticas y problemas posibles por sistema

Qué configuración de cada sistema es crítica, qué ocurre si falla y cuánto se tarda en recuperarla.  Los tiempos son los medidos en las pruebas.

## 1. Por sistema

| Sistema | Configuración crítica | Si falla | Respuesta y tiempo medido |
|---|---|---|---|
| Ubuntu + nftables | Regla `masquerade` y reenvío de paquetes (`ip_forward`) | La LAN pierde la salida a Internet | Restaurar `nftables.conf` desde TrueNAS: 34 s (repetición) y 4 min 25 s (primera vez), ver `configuracion/ubuntunftables.md` |
| MikroTik | Regla NAT en `ether1` y direcciones de WAN y LAN | Sin salida a Internet para toda la LAN | Copia diaria a las 02:00; restaurar en un clon obliga a reasignar interfaces |
| OPNsense | Interfaces WAN/LAN, regla de la LAN y acceso a la gestión | Sin salida a Internet o sin acceso a la web de gestión | Restaurar el XML y adaptar la interfaz de gestión; copia diaria a las 03:00 |
| TrueNAS | Pool `NAS_DATA`, dataset `copias_seguridad` y usuario `nasbackup` | Todas las copias dejan de estar disponibles | Pool de un solo disco, sin redundancia: si falla el disco se pierden las copias |
| Proxmox | Quórum (2 de 3 nodos), red del clúster y claves SSH entre nodos | Sin quórum no se pueden hacer cambios ni migrar; claves vacías en `pve1` impidieron migrar (incidencia 3) | Migración de contenedor: 37 s; de VM en caliente: 35 a 38 s. Copia de la configuración en TrueNAS |
| Windows Server 2025 | Dirección `192.168.34.21` y adaptador de red correcto | Sin conectividad; el adaptador NAT desvió las pruebas (incidencia 2) | Copia de red y usuarios en TrueNAS |
| Windows 11 | IP estática `192.168.34.100`, firmware EFI y usuarios | Sin red o sin acceso | Copia de red y usuarios en TrueNAS |
| Debian (cliente) | IP, puerta de enlace, DNS y `/etc/fstab` del montaje de TrueNAS | Sin red, o arranque lento si el NAS no responde | `nofail` en `fstab` evita que el arranque se bloquee; copia en TrueNAS |
| Linux-Servicios, Linux-Datos | Dirección propia distinta de la del Debian original (clones) y, en Datos, los arrays RAID | IP duplicada; los RAID no se reensamblan tras reiniciar | Cambiar la IP del clon; reensamblar a mano los RAID (no están en `mdadm.conf`) |
| Anfitrión (SSD externo) | Un único disco con todas las VM | Se pierde todo el laboratorio | Solo hay copia de configuraciones, no de los discos de las VM |

## 2. Problemas ya ocurridos en el laboratorio

| Problema | Efecto | Dónde |
|---|---|---|
| ICMP filtrado hacia Internet | El `ping` falla; las pruebas se hacen por TCP | `incidencias/incidencias.md`, 1 |
| Adaptador NAT activo en Windows Server | Las pruebas salían sin pasar por el router | incidencia 2 |
| Clave SSH vacía en `pve1` | La migración fallaba | incidencia 3 |
| IP duplicada entre una VM y el router | Sin salida a Internet | incidencia 4 |
| Modo promiscuo en VirtualBox | Las VM anidadas no tenían red | incidencia 5 |

## 3. Primera respuesta ante una incidencia de instalación o arranque

1. Anotar el síntoma y la hora.
2. Comprobar la red (`ip -br address`, `ip route`) y probar la salida por TCP, no por ping.
3. Revisar el registro (`journalctl -b`, o el del sistema afectado).
4. Aplicar el cambio más pequeño posible y repetir la prueba.
5. Si no se resuelve, restaurar la copia de TrueNAS o recrear la VM descartable.
