# 05. Diseño y pruebas de red

## 1. Objetivo
Documentar los adaptadores virtuales, el direccionamiento y las pruebas de comunicación del laboratorio.

## 2. Diseño conocido
- La VM Debian Server tiene un adaptador NAT.
- Se configuró un segundo adaptador como red interna de VirtualBox.
- Nombre de la red interna: `asir_lab`.
- La IP de la red interna está pendiente de confirmar.

NAT y red interna son modos distintos; se documentarán por separado.

> Actualización (16/11/2026): este apartado y el siguiente recogen el diseño inicial. El mapa real de adaptadores de todas las VM está en el apartado 7.

## 3. Plan de direccionamiento

| Máquina/interfaz | Red/modo | IP | Máscara/prefijo | Puerta de enlace | Estado |
|---|---|---|---|---|---|
| Debian Server, `enp0s3` | NAT | `10.0.2.15` observada | `/24` | Pendiente de verificar | Observado anteriormente |
| Debian Server, segundo adaptador | Interna `asir_lab` | Pendiente | Pendiente | Según diseño final | Pendiente |
| VM cliente | `asir_lab` prevista | Pendiente | Pendiente | Según diseño final | Pendiente |

## 4. Comprobaciones en Debian

```bash
ip -br address
ip route
ping -c 4 10.0.2.2
```

`10.0.2.2` suele ser la puerta de enlace de una configuración NAT habitual de VirtualBox, pero comprueba la ruta real antes de sacar conclusiones. Si el ping falla, registra el resultado; por sí solo no demuestra que toda la red esté caída.

Cuando exista una segunda VM en `asir_lab`, probar la conectividad entre ambas con sus IP reales.

## 5. Registro de pruebas

| Fecha | Origen | Destino | Comando/prueba | Resultado | Conclusión |
|---|---|---|---|---|---|
| Pendiente | Debian Server | Interfaces | `ip -br address` | En una comprobación anterior se observó `enp0s3` con `10.0.2.15/24` | Falta comprobar el segundo adaptador |

## 6. Diagrama
Añadir el diagrama en `diagramas/`. Diferenciar NAT y red interna; marcar como pendientes los equipos que todavía no estén instalados.

## 7. Mapa real de adaptadores (16/11/2026)

Obtenido con `VBoxManage showvminfo --machinereadable` en el equipo con el adaptador puente `enp8s0` (PC doméstico).

| VM | Adaptador 1 | Adaptador 2 | Adaptador 3 |
|---|---|---|---|
| Debian Server | Red interna `asir_lab` | NAT | — |
| Ubuntu Server | NAT (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet2` |
| Mikrotik | Puente `enp8s0` (WAN) | Red interna `asir_lab` (LAN) | — |
| OPNsense | Puente `enp8s0` (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet1` (gestión) |
| TrueNAS | Red interna `asir_lab` | Host-only `vboxnet1` | Host-only `vboxnet2` |
| Mikrotik-RECUPERACION | NAT (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet2` (gestión) |
| OPNsense-RECUPERACION | Puente `enp8s0` (WAN) | Red interna `asir_lab` (LAN) | Host-only `vboxnet2` (gestión) |
| Proxmox N1 | NAT | Red interna `asir_lab` | Host-only `vboxnet1` |
| Proxmox N2 | NAT | Red interna `asir_lab` | — |
| Proxmox N3 | NAT | Red interna `asir_lab` | — |

### Redes host-only

| Red | Uso | Direccionamiento |
|---|---|---|
| `vboxnet0` | Sin uso por ninguna VM | — |
| `vboxnet1` | Gestión de OPNsense, TrueNAS y Proxmox N1 | `192.168.56.0/24` según la configuración anterior de OPNsense (`192.168.56.1` en el anfitrión, `192.168.56.2` en OPNsense). Falta confirmar con `VBoxManage list hostonlyifs` |
| `vboxnet2` | Gestión de Ubuntu Server, TrueNAS y los clones de recuperación | Pendiente de confirmar con `VBoxManage list hostonlyifs` |

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

### Reglas de uso

- Para probar un router, Debian Server no debe tener conectado el adaptador NAT (adaptador 2), porque le permitiría salir a Internet sin pasar por el router.
- Los routers y sus clones comparten la red interna `asir_lab` y direcciones IP iguales (por ejemplo, `192.168.34.3`). No se deben encender a la vez.
- El adaptador puente está asociado a la tarjeta física `enp8s0` del PC doméstico. En el portátil la tarjeta cableada es `eno1`; al ejecutar estas VM allí hay que volver a elegir el adaptador físico.
