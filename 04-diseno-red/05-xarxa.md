# 05. Diseño y pruebas de red

## 1. Objetivo
Documentar los adaptadores virtuales, el direccionamiento y las pruebas de comunicación del laboratorio.

## 2. Diagrama
El esquema de red individual, con la configuración de cada interfaz y las direcciones previstas, está en `diagramas/esquema-red-individual.md`. Las pruebas de ping, traceroute y tablas de rutas están en `06-pruebas-conectividad.md`.

## 3. Mapa real de adaptadores

Obtenido con `VBoxManage showvminfo --machinereadable` en el equipo con el adaptador puente `enp8s0` (PC doméstico).

| VM | Adaptador 1 | Adaptador 2 | Adaptador 3 |
|---|---|---|---|
| Debian Server | Red interna `asir_lab` | NAT | — |
| Ubuntu Server | NAT (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet2` (`enp0s9`, `192.168.58.3/24`) |
| Mikrotik | Puente `enp8s0` (WAN) | Red interna `asir_lab` (LAN) | — |
| OPNsense | Puente `enp8s0` (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet0` (gestión) |
| TrueNAS | Red interna `asir_lab` | Host-only `vboxnet1` | Host-only `vboxnet2` |
| Mikrotik-RECUPERACION | NAT (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet2` (gestión) |
| OPNsense-RECUPERACION | Puente `enp8s0` (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet2` (gestión) |
| Proxmox N1 | Red interna `asir_lab` | Host-only `vboxnet1` | — |
| Proxmox N2 | Red interna `asir_lab` | Host-only `vboxnet1` | — |
| Proxmox N3 | Red interna `asir_lab` | Host-only `vboxnet1` | — |

### Redes host-only

| Red | Uso | Direccionamiento |
|---|---|---|
| `vboxnet0` | Gestión de OPNsense | `192.168.56.0/24` (anfitrión `192.168.56.1`, OPNsense `192.168.56.2`) |
| `vboxnet1` | Gestión de TrueNAS y de los nodos Proxmox | `192.168.57.0/24` (anfitrión `192.168.57.1`) |
| `vboxnet2` | Gestión de Ubuntu Server, TrueNAS y los clones de recuperación | `192.168.58.0/24` (anfitrión `192.168.58.1`) |

Datos obtenidos con `VBoxManage list hostonlyifs` (las tres redes en estado `Up`, máscara `255.255.255.0`).

**Resuelto (16/11/2026):** la gestión web de OPNsense está en `192.168.56.2`, que pertenece a la red de `vboxnet0` (anfitrión `192.168.56.1`). Su adaptador de gestión se conectó a `vboxnet0` y se comprobó con `VBoxManage showvminfo "OPNsense" --machinereadable | grep hostonlyadapter3`. El direccionamiento de los clones de recuperación (`192.168.58.0/24`) coincide con `vboxnet2`. La gestión web de TrueNAS se ha visto en `192.168.58.5` (`vboxnet2`).

### Modo de la interfaz WAN de cada router

| Router | Modo WAN | Cómo obtiene la IP |
|---|---|---|
| Ubuntu Server | NAT de VirtualBox | DHCP (`10.0.2.15/24`, puerta de enlace `10.0.2.2`) |
| Mikrotik | Puente sobre `enp8s0` | DHCP de la red a la que está conectado el anfitrión |
| OPNsense | Puente sobre `enp8s0` | DHCP de la red a la que está conectado el anfitrión |
| Mikrotik-RECUPERACION | NAT de VirtualBox | DHCP (`10.0.2.15/24`, puerta de enlace `10.0.2.2`) |
| OPNsense-RECUPERACION | Puente sobre `enp8s0` | DHCP de la red a la que está conectado el anfitrión |

### Direccionamiento de la LAN `asir_lab` (`192.168.34.0/24`)

Direcciones documentadas en pruebas anteriores. Cada router se prueba por separado como puerta de enlace de Debian.

| Equipo | IP LAN |
|---|---|
| OPNsense | `192.168.34.2` |
| Ubuntu Server (router nftables) | `192.168.34.3` |
| Mikrotik-RECUPERACION | `192.168.34.3` |
| Debian Server (cliente de pruebas) | `192.168.34.4` |
| TrueNAS | `192.168.34.20` |
| Windows Server 2025 | `192.168.34.21` |
| Linux-Servicios | `192.168.34.22` |
| Linux-Datos | `192.168.34.23` |
| Nodos Proxmox | `192.168.34.32` a `.34` |
| Windows 11 | `192.168.34.100` |

### Reglas de uso

- Para probar un router, Debian Server no debe tener conectado el adaptador NAT (adaptador 2), porque le permitiría salir a Internet sin pasar por el router.
- Los routers y sus clones comparten la red interna `asir_lab` y direcciones IP iguales (por ejemplo, `192.168.34.3`). No se deben encender a la vez.
- El adaptador puente está asociado a la tarjeta física `enp8s0` del PC doméstico. En el portátil la tarjeta cableada es `eno1`; al ejecutar estas VM allí hay que volver a elegir el adaptador físico.
