# 06. Pruebas de conectividad: ping, traceroute y tablas de rutas

Evidencia de la tarea 4 (ampliación): comprobación de la conectividad con `ping` y `traceroute` y consulta de las tablas de rutas, con OPNsense como router activo.

## 1. Condiciones

| Dato | Valor |
|---|---|
| Fecha y hora | lunes 16/11/2026, 16:03:25 CET |
| Router activo | OPNsense (`192.168.34.2` en la LAN) |
| Red exterior | Red doméstica (`192.168.1.0/24`); la prueba no se hizo en el aula |
| Cliente | Debian Server, `192.168.34.4/24` |
| Servidor de copias | TrueNAS, `192.168.34.20` |

Orden de las pruebas: en Debian, `ip -br address`, `ip route`, cambio de la ruta por defecto a OPNsense, `ip route` de nuevo, dos `ping`, `traceroute` y una prueba TCP al puerto 443.

## 2. Interfaces de Debian

| Interfaz | Estado | Dirección | Función |
|---|---|---|---|
| `lo` | UNKNOWN | `127.0.0.1/8`, `::1/128` | Loopback |
| `enp0s3` | UP | `192.168.34.4/24` | LAN `asir_lab` |
| `enp0s8` | UP | `10.0.3.15/24` (DHCP) | NAT de VirtualBox |

## 3. Tabla de rutas de Debian

Con `ip route`, tras ejecutar `sudo ip route replace default via 192.168.34.2`:

| Destino | Puerta de enlace | Interfaz | Métrica | Origen |
|---|---|---|---|---|
| `default` | `192.168.34.2` (OPNsense) | `enp0s3` | 0 (por defecto) | Ruta añadida a mano |
| `default` | `10.0.3.2` | `enp0s8` | 1003 | DHCP del adaptador NAT |
| `10.0.3.0/24` | — (conectada) | `enp0s8` | 1003 | DHCP |
| `192.168.34.0/24` | — (conectada) | `enp0s3` | 0 | Red local |

Hay dos rutas por defecto. Se usa la de menor métrica: `192.168.34.2`, es decir, OPNsense.

Limitación: la salida pegada del primer `ip route` (antes del cambio) se mezcló con la del segundo. Aquí solo se documenta el estado final, que sí se distingue.

## 4. Ping

| Destino | Enviados / recibidos | Pérdida | RTT mín / medio / máx | Qué demuestra |
|---|---|---|---|---|
| `192.168.34.2` (OPNsense) | 4 / 4 | 0 % | 0,486 / 1,005 / 2,058 ms | La puerta de enlace responde por la LAN |
| `192.168.34.20` (TrueNAS) | 4 / 4 | 0 % | 0,579 / 2,879 / 9,641 ms | Hay comunicación entre equipos de la LAN |

No se hace `ping` a Internet: la red del aula filtra ICMP hacia el exterior (ver `08-final-incidencias/06-proves-incidencies.md`). En su lugar se usa TCP.

## 5. Traceroute hacia Internet

```text
traceroute -n -T -p 443 1.1.1.1
 1  192.168.34.2   1.185 ms  0.949 ms  *
 2  1.1.1.1        1.942 ms  *  *
```

- **Salto 1:** `192.168.34.2`, la LAN de OPNsense. El tráfico sale por el router y no por el NAT de VirtualBox, cuya puerta de enlace sería `10.0.3.2`.
- **Salto 2:** `1.1.1.1`, el destino.
- Los asteriscos son sondas sin respuesta dentro del tiempo de espera; no impiden llegar al destino. Entre OPNsense y el destino no hay saltos intermedios visibles.
- La prueba TCP posterior (`timeout 5 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/443'`) devolvió `abierto`, con la regla de bloqueo de OPNsense desactivada.

## 6. Interfaces y tabla de rutas de OPNsense

Evidencias:
- `04-diseno-red/evidencies/2026-11-16-opnsense-interfaces-overview.png` (`Interfaces → Overview`)
- `04-diseno-red/evidencies/2026-11-16-opnsense-tabla-rutas.png` (`System → Routes → Status`)

| Interfaz | Dispositivo | Configuración |
|---|---|---|
| WAN | `em0` | DHCP: `192.168.1.27/24`, puerta de enlace `192.168.1.1` |
| LAN | `em1` | Estática: `192.168.34.2/24` |
| OPT1 | `em2` | Estática: `192.168.56.2/24` (gestión, `vboxnet0`) |

Rutas principales de la tabla:

| Destino | Puerta de enlace | Indicadores | Interfaz |
|---|---|---|---|
| `default` | `192.168.1.1` | UGS | `em0` (WAN) |
| `192.168.1.0/24` | `link#1` | U | `em0` (WAN) |
| `192.168.34.0/24` | `link#2` | U | `em1` (LAN) |
| `192.168.56.0/24` | `link#3` | U | `em2` (OPT1) |

La ruta por defecto sale por la WAN hacia el router de la red doméstica, y las redes `192.168.34.0/24` y `192.168.56.0/24` son directamente conectadas. Las demás entradas son direcciones propias del firewall en `lo0` y rutas IPv6 locales.

## 7. Conclusión

Con OPNsense como router, Debian se comunica con el router y con TrueNAS por la LAN, y su tráfico hacia Internet atraviesa OPNsense, como demuestra el traceroute. Las tablas de rutas de Debian y de OPNsense son coherentes con el esquema (`diagramas/esquema-red-individual.md`).
