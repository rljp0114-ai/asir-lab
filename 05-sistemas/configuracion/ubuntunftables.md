# Ubuntu Server - Router con nftables

## 1. Objetivo

Configurar Ubuntu Server como router y firewall para conectar nuestra red interna `asir_lab` con Internet.

Ubuntu Server dispone de dos interfaces de red:
- Una interfaz WAN conectada a la red NAT de VirtualBox.
- Una interfaz LAN conectada a la red interna `asir_lab`.

El objetivo es permitir que los equipos de la red interna puedan acceder a Internet utilizando Ubuntu Server como puerta de enlace, aplicando reglas de filtrado y NAT mediante nftables.

## 2. Características de la máquina virtual

| Característica | Configuración |
|---|---|
| Sistema operativo | Ubuntu Server |
| Función | Router y firewall |
| Virtualizador | VirtualBox |
| Memoria RAM | Según configuración de la VM |
| Red interna | asir_lab |

## 3. Configuración de red

| Interfaz | Dirección IP | Función |
|---|---|---|
| enp0s3 | 10.0.2.15/24 | WAN (Internet) |
| enp0s8 | 192.168.34.3/24 | LAN (red interna) |
| enp0s9 | 192.168.58.3/24 | Gestión desde el anfitrión (host-only `vboxnet2`) |

**Puerta de enlace predeterminada:** `10.0.2.2`

La interfaz WAN utiliza DHCP para recibir automáticamente la configuración de la red NAT de VirtualBox. La interfaz LAN utiliza una dirección IP estática.

### Configuración persistente

Archivo utilizado:

`/etc/netplan/00-installer-config.yaml`

La configuración establece:
- DHCP activado en `enp0s3`.
- Dirección estática `192.168.34.3/24` en `enp0s8`.
- DHCPv6 desactivado.

## 4. Configuración del encaminamiento

Para permitir que los paquetes atraviesen Ubuntu Server, se habilitó el reenvío IPv4 (*IP Forwarding*).

Archivo:

`/etc/sysctl.d/99-ip-forward.conf`

Configuración:

```text
net.ipv4.ip_forward=1
```

Se aplicó mediante:

```bash
sudo sysctl --system
```

## 5. Configuración del firewall con nftables

Se instaló y configuró nftables para controlar el tráfico de red.

Archivo principal:

`/etc/nftables.conf`

Se configuraron las siguientes políticas:

- **INPUT:** política DROP. Permite tráfico de loopback, conexiones establecidas y relacionadas, ICMP desde la LAN y SSH desde la LAN.
- **FORWARD:** política DROP. Permite el tráfico de la red interna hacia Internet y las respuestas de conexiones establecidas.
- **OUTPUT:** política ACCEPT. Permite el tráfico saliente del propio Ubuntu Server.
- **NAT:** utiliza masquerade para traducir las direcciones IP privadas de la LAN al salir por la interfaz WAN.

### Comprobación de las reglas

```bash
sudo nft list ruleset
```

Para validar la sintaxis:

```bash
sudo nft -c -f /etc/nftables.conf
```

Para habilitar el servicio durante el arranque:

```bash
sudo systemctl enable --now nftables
```

Se realizó también una copia de seguridad de la configuración:

`/etc/nftables.conf.final`

## 6. Pruebas realizadas

Se realizaron pruebas para comprobar el funcionamiento del router:

1. Comprobación de las interfaces y sus direcciones IP.
2. Comprobación del reenvío IPv4.
3. Comprobación de las reglas de nftables.
4. Comprobación de la salida a Internet desde el cliente Debian.
5. Prueba de filtrado mediante una regla temporal que bloqueaba ICMP desde Debian.
6. Comprobación de los registros del firewall y de los contadores de paquetes.
7. Eliminación de la regla temporal y recuperación de la conectividad.
8. Comprobación de la persistencia de la configuración tras reiniciar (realizada el 16/11/2026; apartado 9).
9. Copia de la configuración al servidor de copias (apartado 7).
10. Fallo controlado y recuperación desde esa copia (apartado 8).

## 7. Copia de seguridad en TrueNAS

La configuración del firewall se copió al servidor de copias (TrueNAS, `192.168.34.20`) mediante SFTP con el usuario `nasbackup`:

```bash
sftp nasbackup@192.168.34.20
sftp> mkdir /mnt/NAS_DATA/copias_seguridad/ubuntu
sftp> put /etc/nftables.conf.final /mnt/NAS_DATA/copias_seguridad/ubuntu/nftables.conf.final
```

- Origen: `/etc/nftables.conf.final`.
- Destino: `/mnt/NAS_DATA/copias_seguridad/ubuntu/nftables.conf.final`.
- Resultado: transferencia completada al 100 % (846 bytes). El `mkdir` devolvió un error, pero como el `put` terminó correctamente el directorio de destino existe.
- La copia es manual. No hay tarea programada para Ubuntu (sí la hay para MikroTik y OPNsense).

Evidencia: `evidencies/2026-11-16-ubuntu-persistencia-copia-sftp-fallo.png`.

## 8. Fallo controlado y recuperación

### Fallo provocado

Se eliminaron todas las reglas del firewall, incluido el NAT:

```bash
date; sudo nft flush ruleset
```

### Comprobación desde el cliente Debian

Prueba de conexión TCP al puerto 443 de `1.1.1.1` (no se usa `ping` porque la red del aula filtra ICMP; ver `08-incidencias/06-proves-incidencies.md`):

```bash
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/443' && echo abierto || echo CERRADO
```

| Momento | Resultado en Debian |
|---|---|
| Antes del fallo (dos pruebas) | abierto |
| Con las reglas eliminadas | **CERRADO** |
| Tras la recuperación | abierto |

El orden de los resultados es el de la captura `evidencies/2026-11-16-debian-prueba-fallo-recuperacion-ubuntu.png`. Sin la regla de `masquerade`, la causa más probable del bloqueo es que los paquetes de Debian salen con su IP privada y no reciben respuesta; no se ha aislado con otra prueba.

### Recuperación desde el servidor de copias

```bash
sftp nasbackup@192.168.34.20:/mnt/NAS_DATA/copias_seguridad/ubuntu/nftables.conf.final /tmp/nftables.recuperado
sudo nft -c -f /tmp/nftables.recuperado && sudo nft -f /tmp/nftables.recuperado; date
```

La primera orden descarga la copia desde TrueNAS. La segunda valida la sintaxis (`-c`) y, si es correcta, carga las reglas.

### Tiempos medidos

| Intento | Fallo | Reglas cargadas | Tiempo de recuperación |
|---|---|---|---|
| 1 (primera vez) | 15:19:11 | 15:23:36 | 4 min 25 s |
| 2 (repetición con Debian como testigo) | 15:28:55 | 15:29:29 | 34 s |

Los tiempos incluyen teclear los comandos y escribir la contraseña de `nasbackup`. La diferencia entre intentos se debe a que el primero fue la primera ejecución del procedimiento; el segundo es representativo del tiempo de recuperación manual con el procedimiento ya conocido.

### Estado tras la recuperación

`sudo nft list ruleset` muestra de nuevo la tabla `inet filter` (INPUT y FORWARD con política `drop`, OUTPUT `accept`, con reglas de registro `nft-input-drop` y `nft-forward-drop` limitadas a 5 por segundo) y la tabla `ip nat` con el `masquerade` de `192.168.34.0/24` por `enp0s3`.

Evidencia: `evidencies/2026-11-16-ubuntu-recuperacion-ruleset-persistencia.png`.

## 9. Persistencia tras reiniciar

Se reinició Ubuntu Server y se comprobó que la configuración se carga sin intervención:

| Comprobación | Resultado |
|---|---|
| `systemctl is-enabled nftables` | `enabled` |
| `who -b` (último arranque) | `2026-11-16 15:09` |
| `sysctl net.ipv4.ip_forward` | `net.ipv4.ip_forward = 1` |
| `ip -br addr` | `enp0s3` 10.0.2.15/24, `enp0s8` 192.168.34.3/24, `enp0s9` 192.168.58.3/24 |
| Reglas | Tabla `ip nat` con `masquerade` cargada tras el arranque, antes de provocar el fallo del apartado 8 |

Evidencias: `evidencies/2026-11-16-ubuntu-persistencia-copia-sftp-fallo.png` y `evidencies/2026-11-16-ubuntu-recuperacion-ruleset-persistencia.png`.

## 10. Resultado

Ubuntu Server funciona como router y firewall de nuestra red interna `asir_lab`.

Los equipos conectados a la LAN pueden acceder a Internet a través de Ubuntu Server mediante encaminamiento IPv4 y NAT.

La configuración de nftables está habilitada para iniciarse automáticamente con el sistema, y se ha comprobado que se conserva tras un reinicio.

La configuración está copiada en el servidor de copias y se ha comprobado que el router se recupera de un fallo (reglas eliminadas) cargando esa copia.

## 11. Evidencias

Capturas disponibles en `evidencies/`:

- `2026-11-16-ubuntu-persistencia-copia-sftp-fallo.png`: reglas NAT, `ip_forward`, interfaces, copia por SFTP, fallo provocado y primera recuperación.
- `2026-11-16-ubuntu-recuperacion-ruleset-persistencia.png`: repetición del fallo y la recuperación, reglas cargadas, `is-enabled` y `who -b`.
- `2026-11-16-debian-prueba-fallo-recuperacion-ubuntu.png`: resultados de Debian antes, durante y después del fallo.

Pendientes de capturar (los comandos y resultados de estas pruebas están en `evidencies/Comandos.md`):

- Reglas de nftables completas, interfaces y reenvío IPv4 (fuera de lo ya visible en las capturas anteriores).
- Prueba de bloqueo temporal con nftables y su registro.
