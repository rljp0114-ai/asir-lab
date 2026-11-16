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
8. Comprobación de la persistencia de la configuración tras reiniciar.

## 7. Resultado

Ubuntu Server funciona como router y firewall de nuestra red interna `asir_lab`.

Los equipos conectados a la LAN pueden acceder a Internet a través de Ubuntu Server mediante encaminamiento IPv4 y NAT.

La configuración de nftables está habilitada para iniciarse automáticamente con el sistema.

## 8. Evidencias

Se adjuntarán las siguientes capturas:

- `evidencias/reglas-nftables.png`: reglas del firewall y NAT.
- `evidencias/interfaces-red.png`: interfaces y direcciones IP.
- `evidencias/ip-forwarding.png`: comprobación del reenvío IPv4.
- `evidencias/prueba-bloqueo.png`: prueba de bloqueo temporal mediante nftables.
- `evidencias/conectividad-cliente.png`: comprobación de la salida a Internet desde Debian.
