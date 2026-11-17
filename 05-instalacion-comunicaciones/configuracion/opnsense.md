# OPNsense - Router y firewall

## 1. Objetivo

Utilizar OPNsense como servidor de comunicaciones del laboratorio: conecta la red interna `asir_lab` con la red exterior, traduce direcciones (NAT) y filtra el tráfico mediante reglas.

La instalación, el direccionamiento, la prueba de filtrado con ICMP, la copia de seguridad, la restauración en un clon y las copias automáticas por SFTP están registrados con sus comandos en `evidencies/Comandos.md` (apartados "OPNsense: configuración del servidor de comunicaciones", "Copia de seguridad y recuperación" y "Copias de seguridad automáticas mediante SFTP"). Este documento resume el estado y añade la comprobación de la versión, los usuarios y la prueba de conexión permitida y bloqueada con su registro.

## 2. Características de la máquina virtual

| Característica | Valor |
|---|---|
| VM | `OPNsense` (VirtualBox 7.0.20) |
| Sistema | OPNsense 26.7.9_1, arquitectura amd64, commit `e1020455a` |
| vCPU | 2 |
| RAM | 5 GB |
| Disco virtual | 20 GB |
| Última actualización del sistema | 14/11/2026 (según `System → Firmware → Status`) |

Evidencia de la versión: `05-instalacion-comunicaciones/evidencies/2026-11-16-opnsense-firmware-version.png`.

## 3. Usuarios de administración

`System → Access → Users` muestra un único usuario, `root`, con nombre completo "System Administrator", miembro del grupo `admins` y con autoridad sin restricciones. Es el usuario de administración del firewall; se utiliza para acceder a la interfaz web y a la consola.

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-opnsense-usuarios.png`.

## 4. Configuración de red

| Interfaz | Adaptador VirtualBox | Función | Configuración |
|---|---|---|---|
| `em0` (WAN) | Puente sobre `enp8s0` | WAN | DHCP de la red a la que está conectado el anfitrión |
| `em1` (LAN) | Red interna `asir_lab` | LAN | Estática: `192.168.34.2/24` |
| `em2` (OPT1) | Host-only | Gestión | `192.168.56.2/24` |

- En la prueba del 16/11/2026 el registro del firewall muestra que la WAN usaba la dirección `192.168.1.27` (red doméstica `192.168.1.0/24`).
- La interfaz web se abre desde el anfitrión en `https://192.168.56.2` (ver captura de la versión). El anfitrión usa `192.168.56.1` en `vboxnet0`, por lo que el adaptador de gestión de OPNsense (adaptador 3) está conectado a `vboxnet0`. Se comprobó con `VBoxManage showvminfo "OPNsense" --machinereadable | grep hostonlyadapter3`, que devuelve `vboxnet0`.
- En `Firewall → Rules → OPT1` existe una regla que permite HTTPS (TCP) solo desde `192.168.56.1/32` (descripción "Acceso web desde Linux Mint").
- Cliente de pruebas: Debian Server, `192.168.34.4/24`. Para usar OPNsense como puerta de enlace se cambia temporalmente la ruta por defecto: `sudo ip route replace default via 192.168.34.2`.

## 5. Prueba de una conexión permitida y otra bloqueada

### Objetivo

Comprobar que OPNsense aplica una regla de filtrado, que bloquea solo el tráfico indicado y que el registro permite identificar la conexión bloqueada.

### Condiciones

- OPNsense, Debian y TrueNAS encendidos; Ubuntu Server y MikroTik apagados.
- Debian con OPNsense (`192.168.34.2`) como puerta de enlace y sin el adaptador NAT conectado.
- Prueba con TCP y no con ping, porque en la red del aula el ICMP hacia Internet está filtrado (ver `incidencias/incidencias.md`).

### Regla

Regla en `Firewall → Rules → LAN` con la descripción **"Bloqueo controlado TCP hacia Internet"**:

| Parámetro | Valor |
|---|---|
| Interfaz | LAN |
| Acción | `Block` |
| Versión | IPv4 |
| Protocolo | TCP |
| Origen | `LAN network` |
| Destino | `1.1.1.1` |
| Puerto de destino | `https` (443) |
| Registro | Activado |

Evidencia (la regla aparece en gris porque está desactivada tras la prueba): `05-instalacion-comunicaciones/evidencies/2026-11-16-opnsense-reglas-firewall-regla-desactivada.png`.

### Pruebas desde Debian

Comando (cambiando el destino):

```bash
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/DESTINO/443' && echo abierto || echo CERRADO
```

Secuencia registrada en la captura `05-instalacion-comunicaciones/evidencies/2026-11-16-debian-prueba-bloqueo-opnsense.png` (orden de ejecución):

| Nº | Destino | Estado de la regla | Resultado | Significado |
|---|---|---|---|---|
| 1 | `1.1.1.1:443` | Activa | **CERRADO** | Conexión bloqueada |
| 2 | `8.8.8.8:443` | Activa | abierto | Conexión permitida |
| 3 | `1.1.1.1:443` | Activa | **CERRADO** | Conexión bloqueada (repetición) |
| 4 | `8.8.8.8:443` | Activa | abierto | Conexión permitida (repetición) |
| 5 | `1.1.1.1:443` | Desactivada | abierto | Se recupera el estado anterior |

La regla bloquea solo el destino indicado: `1.1.1.1` queda bloqueado y `8.8.8.8` sigue accesible mientras la regla está activa.

### Registro del firewall

En `Firewall → Log Files → Live View` se ven en la captura cinco entradas de bloqueo con la etiqueta de la regla, entre las 14:48:48 y las 14:48:52 (hora UTC del firewall). Evidencias: `05-instalacion-comunicaciones/evidencies/2026-11-16-opnsense-log-bloqueo-tcp443.png` y `05-instalacion-comunicaciones/evidencies/2026-11-16-opnsense-log-entrada-bloqueo.png`.

Entrada de ejemplo:

| Campo | Valor | Significado |
|---|---|---|
| Interface | `LAN` | El paquete llegó por la interfaz LAN |
| Dirección | `In` | Entrante en esa interfaz, es decir, procedente de un equipo de la LAN |
| Time | `2026-11-16T14:48:52` | Hora UTC |
| Protocol | `TCP` | Intento de conexión TCP |
| Source | `192.168.34.4:46300` | Debian, desde un puerto de origen temporal |
| Destination | `1.1.1.1:443` | Servidor HTTPS de destino |
| Action | `block` | El firewall descartó el paquete |
| Label | `Bloqueo controlado TCP hacia Internet` | Regla que lo bloqueó |

Las cinco entradas tienen el mismo puerto de origen (`46300`) y se repiten cada segundo. Lo más probable es que sean los reintentos de un único intento de conexión: al no recibir respuesta, Debian vuelve a enviar el paquete de inicio de conexión.

En la misma captura aparecen entradas con otra acción que permiten comparar tráfico permitido y bloqueado:

- `pass` para el tráfico generado por el propio firewall, por ejemplo la sincronización de hora (UDP/123) y una conexión TCP/443 a `8.8.8.8` (regla "let out anything from firewall host itself").
- `block` para un paquete IGMP de `192.168.1.1` hacia `224.0.0.1` que entra por la WAN (regla por defecto "Block private networks from WAN").

### Vuelta al estado anterior

La regla quedó **desactivada** (se conserva en la lista, sin efecto sobre el tráfico). Tras desactivarla, la conexión a `1.1.1.1:443` volvió a dar `abierto` (prueba 5).

Nota: la regla que permite el tráfico de la LAN tiene como descripción "- prueba backup". Conviene renombrarla (por ejemplo, "Permitir LAN hacia cualquier destino") para que el listado de reglas sea claro en la entrega.

## 6. Copia de seguridad y recuperación

Resumen (detalle y comandos en `evidencies/Comandos.md`):

- Exportación de la configuración (XML) desde `System → Configuration → Backups`, guardada en TrueNAS en `copias_seguridad/opnsense/`.
- Copias automáticas con el complemento `os-sftp-backup`: usuario `nasbackup`, autenticación con clave SSH Ed25519, tarea diaria a las 03:00. Probada con `configctl system remote backup`; la ejecución nocturna real no se ha observado.
- Prueba de recuperación en el clon `OPNsense-RECUPERACION`: se restauró el XML y fue necesario adaptar la interfaz de gestión y la regla HTTPS de OPT1 a la red host-only del clon; después Debian volvió a tener salida a Internet.
