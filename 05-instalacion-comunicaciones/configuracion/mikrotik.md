# MikroTik RouterOS (CHR) - Router y firewall

## 1. Objetivo

Utilizar MikroTik RouterOS como servidor de comunicaciones del laboratorio: conecta la red interna `asir_lab` con la red exterior, traduce direcciones (NAT) y filtra el tráfico.

Este documento resume la instalación, la configuración inicial, el problema con la regla NAT, las copias de seguridad en TrueNAS y la prueba de recuperación en un clon, y añade la comprobación de la versión y la prueba de conexión permitida y bloqueada.

## 2. Características de la máquina virtual

| Característica | Valor |
|---|---|
| VM | `Mikrotik` (VirtualBox 7.0.20) |
| Sistema | RouterOS 7.24.5 (stable), compilación 2026-09-29, arquitectura x86_64 |
| Identidad mostrada en WebFig | `MikroTik-Lab` |
| vCPU | 1 |
| RAM | 512 MB (WebFig muestra 512,0 MiB totales) |
| Disco virtual | 2 GB (WebFig muestra 1934,1 MiB) |
| Placa | `x86 innotek GmbH VirtualBox` |

Evidencia de la versión y los recursos: `05-instalacion-comunicaciones/evidencies/2026-11-16-mikrotik-webfig-resources-version.png`.

## 3. Configuración de red

| Interfaz | Adaptador VirtualBox | Función | Dirección |
|---|---|---|---|
| `ether1` | Puente sobre `enp8s0` | WAN | Por DHCP de la red a la que está conectado el anfitrión |
| `ether2` | Red interna `asir_lab` | LAN | `192.168.34.3/24` (estática) |

Durante la prueba del 16/11/2026 en la red del aula, WebFig se abrió en `http://172.16.222.221/webfig`, es decir, `ether1` obtuvo por DHCP una dirección de la red `172.16.222.0/24` del aula. En pruebas anteriores, en la red doméstica, obtuvo `192.168.30.193`. La dirección WAN cambia según la red a la que se conecte el anfitrión.

La regla de NAT es de tipo `masquerade` con salida por `ether1`. Cliente de pruebas: Debian Server, `192.168.34.4/24`, con puerta de enlace `192.168.34.3`.

## 4. Prueba de una conexión permitida y otra bloqueada

### Objetivo

Comprobar que MikroTik aplica una regla de filtrado, que bloquea solo el tráfico indicado y que el registro permite identificar el paquete bloqueado.

### Condiciones

- Solo encendidos MikroTik y Debian Server (Ubuntu Server apagado porque comparte la IP `192.168.34.3`).
- En Debian Server, adaptador NAT desconectado para que el tráfico pase por MikroTik.
- Prueba con TCP y no con ping. Ver el apartado 5: la red del aula no deja pasar el ICMP hacia Internet.

### Regla creada (WebFig: `IP → Firewall → Filter Rules`)

| Parámetro | Valor |
|---|---|
| Chain | `forward` |
| Src. Address | `192.168.34.4` |
| Dst. Address | `1.1.1.1` |
| Protocol | `tcp` |
| Dst. Port | `443` |
| Action | `drop` |
| Log | activado, prefijo `PRUEBA-BLOQUEO` |

Es la regla número 0 de la tabla `filter`, por lo que se evalúa la primera.

### Pruebas desde Debian

Cada prueba intenta abrir una conexión TCP al puerto 443 del destino indicado con:

```bash
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/DESTINO/443' && echo abierto || echo CERRADO
```

Secuencia registrada en la captura `05-instalacion-comunicaciones/evidencies/2026-11-16-debian-prueba-tcp443-bloqueo-mikrotik.png` (orden de ejecución):

| Nº | Destino | Estado de la regla | Resultado | Significado |
|---|---|---|---|---|
| 1 | `1.1.1.1:443` | Sin regla de bloqueo | abierto | Conexión permitida: el tráfico sale por MikroTik |
| 2 | `8.8.8.8:443` | Sin regla de bloqueo | abierto | Conexión permitida |
| 3 | `1.1.1.1:443` | Regla `drop` activa | **CERRADO** | Conexión bloqueada por la regla; coincide con las 5 entradas del registro |
| 4 | `1.1.1.1:443` | Regla deshabilitada o eliminada | abierto | Se recupera el estado anterior |

La prueba 3 se corresponde con los cinco paquetes SYN descartados que muestran los contadores y el registro. La prueba 4 se ejecutó después de retirar el bloqueo y confirma que el router vuelve a dejar pasar el tráfico.

### Resultado observado en MikroTik

- **Contadores de la regla:** 5 paquetes y 300 bytes. Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-mikrotik-regla-drop-tcp443-contadores.png`.
- **Registro:** cinco entradas (números 9 a 13) con el prefijo `PRUEBA-BLOQUEO`, entre las 09:08:45 y las 09:08:50 según el reloj del router. Evidencias: `05-instalacion-comunicaciones/evidencies/2026-11-16-mikrotik-log-lista-prueba-bloqueo.png` y `05-instalacion-comunicaciones/evidencies/2026-11-16-mikrotik-log-entrada-detalle.png`.

### Interpretación del registro

Mensaje de la última entrada (número 13):

```text
PRUEBA-BLOQUEO forward: in:ether2 out:ether1, connection-state:new src-mac 08:00:27:6D:13:43, proto TCP (SYN), 192.168.34.4:33944->1.1.1.1:443, len 60
```

| Campo | Significado |
|---|---|
| `PRUEBA-BLOQUEO` | Prefijo definido en la regla; permite localizar sus entradas |
| `forward` | Tráfico que atraviesa el router (no el dirigido al propio router) |
| `in:ether2 out:ether1` | Entra por la LAN y iba a salir por la WAN |
| `connection-state:new` | Es el inicio de una conexión nueva |
| `src-mac 08:00:27:6D:13:43` | Dirección MAC (virtual de VirtualBox) del origen |
| `proto TCP (SYN)` | Paquete de inicio de conexión TCP |
| `192.168.34.4:33944->1.1.1.1:443` | Debian, desde un puerto de origen temporal, hacia el puerto 443 de `1.1.1.1` |
| `len 60` | Longitud del paquete en bytes |

Los cinco paquetes SYN de 60 bytes coinciden con los contadores de la regla (5 paquetes y 300 bytes). Son los intentos de Debian de abrir la conexión, que MikroTik descartó. Al no recibir respuesta, Debian reintenta el SYN.

### Vuelta al estado anterior

Para devolver el router a su estado anterior se retiró el bloqueo y se repitió la prueba hacia `1.1.1.1:443`, que volvió a dar `abierto` (prueba 4 de la tabla anterior).

- Estado final de la regla: **deshabilitada** (se conserva en la tabla `filter` para consulta, sin efecto sobre el tráfico).

## 5. Incidencia durante las pruebas

El `ping` a `1.1.1.1` fallaba desde Debian y desde el propio MikroTik en la red del aula. Se resolvió comprobando la salida con TCP en lugar de ICMP. La ficha completa está en `incidencias/incidencias.md`.

## 6. Copias de seguridad y recuperación

Resumen:

- Copia binaria y exportación de texto en `copias_seguridad/mikrotik/` de TrueNAS, generadas por el script `backup-truenas` y la tarea programada `backup-diario` (02:00).
- Prueba de fallo: deshabilitar la regla NAT hace que Debian pierda la salida a Internet; al habilitarla se recupera.
- Prueba de recuperación en el clon `Mikrotik-RECUPERACION`: la copia binaria obligó a reasignar las interfaces, porque el clon tenía adaptadores distintos.
