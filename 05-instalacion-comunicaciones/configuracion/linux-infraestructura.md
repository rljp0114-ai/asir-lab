# Servidores GNU/Linux de infraestructura

## 1. Objetivo

Instalar los servidores GNU/Linux de infraestructura del laboratorio, configurar su usuario de administración y su red, y guardar su configuración en el servidor de copias (tarea 5). El enunciado indica que, de momento, no se instala software adicional: cada servidor queda como sistema base listo para recibir servicios más adelante.

## 2. Servidores previstos

| Servidor | VM | IP | Función prevista | Estado |
|---|---|---|---|---|
| Servicios | `Linux-Servicios` | `192.168.34.22/24` | Servicios de infraestructura (sin software adicional por ahora) | Instalado y probado (16/11/2026) |
| Datos | `Linux-Datos` | `192.168.34.23/24` | Datos (sin software adicional por ahora) | Instalado y probado (16/11/2026) |

Ambos se crean como **clon completo** de la VM `Debian Server`, con nuevas direcciones MAC, y se ejecutan como VM independientes de VirtualBox. No van dentro de los nodos Proxmox porque los recursos son limitados (ver `00-entorno-pruebas/04-entorn-virtualitzacio.md`, apartado 8).

## 3. Linux-Servicios

### 3.1 Versión

| Dato | Valor |
|---|---|
| Sistema | Debian GNU/Linux 13 (trixie) |
| Kernel | 6.12.113+deb13-amd64 |
| Nombre de equipo | `linux-servicios` (cambiado con `hostnamectl set-hostname`) |
| Virtualización | Oracle VirtualBox |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-linux-servicios-version-red.png` (19:32:47 del 16/11/2026).

### 3.2 Red

| Parámetro | Valor |
|---|---|
| Interfaz | `enp0s3` (única interfaz de red de la VM; sin adaptador NAT) |
| Dirección IPv4 | `192.168.34.22/24`, estática en `/etc/network/interfaces` |
| Puerta de enlace | `192.168.34.3` (MikroTik, router activo) |

La tabla de rutas contiene solo `default via 192.168.34.3 dev enp0s3` y `192.168.34.0/24`. Al no haber adaptador NAT, todo el tráfico saliente pasa por el router.

Incidencia al configurarla: tras el clonado y cambio de adaptadores, el nombre de la interfaz no coincidía con el del fichero `interfaces`, la VM tomó una dirección `169.254.x.x` (sin configuración) y `networking.service` falló. Se corrigió ajustando el nombre de la interfaz y la dirección en `interfaces`, y se reinició el servicio.

### 3.3 Pruebas de funcionamiento

| Prueba | Resultado |
|---|---|
| `ping -c 3 192.168.34.3` | 3/3 respuestas, 0 % de pérdida, 0,513 / 0,733 / 1,021 ms |
| `ping -c 3 192.168.34.20` (TrueNAS) | 3/3 respuestas, 0 % de pérdida, 0,568 / 0,857 / 1,417 ms |
| TCP 443 a `1.1.1.1` | `abierto`: salida a Internet a través de MikroTik (no hay otra salida) |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-linux-servicios-pruebas-red.png`.

### 3.4 Usuario de administración

Se hereda de `Debian Server`: el usuario `batoi` y la cuenta `root`, a la que se pasa con `su -`. En las capturas se trabaja como `root` (`root@linux-servicios`).

### 3.5 Copia al servidor de copias

Con `nasbackup` por SFTP se copiaron a `/mnt/NAS_DATA/copias_seguridad/linux-servicios/`:

| Fichero | Tamaño | Contenido |
|---|---|---|
| `hostname` | 16 bytes | Nombre del equipo |
| `interfaces` | 394 bytes | Configuración de red |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-linux-servicios-copia-sftp-truenas.png`.

No se copia la imagen del disco (20 GB): la VM se vuelve a crear clonando `Debian Server` y reconfigurando con estos ficheros. Tampoco se copian contraseñas.

### 3.6 Observación: identificadores duplicados por clonar

El `Machine ID` que muestra `hostnamectl` (`7138cb0a...`) es **el mismo** que el de `Debian Server`, porque el clon lo hereda. Dos equipos con el mismo identificador pueden confundir a servicios que lo usan para identificarse en red. Se decide **no regenerarlo** en este laboratorio: los servidores no ejecutan servicios que dependan de ese identificador y no se encienden a la vez con el original. Si en el futuro se instalan servicios de red (por ejemplo, DHCP o monitorización), habría que regenerarlo con `rm /etc/machine-id`, `systemd-machine-id-setup` y reiniciar, y regenerar también las claves SSH del servidor.

## 4. Linux-Datos

### 4.1 Versión

| Dato | Valor |
|---|---|
| Sistema | Debian GNU/Linux 13 (trixie) |
| Kernel | 6.12.113+deb13-amd64 |
| Nombre de equipo | `linux-datos` |
| Virtualización | Oracle VirtualBox |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-linux-datos-version-red.png` (19:57:27 del 16/11/2026).

### 4.2 Red

| Interfaz | Estado | Dirección | Función |
|---|---|---|---|
| `enp0s3` | UP | `192.168.34.23/24`, estática | LAN `asir_lab` |
| `enp0s8` | UP | `10.0.3.15/24` (DHCP) | NAT de VirtualBox |

Rutas: `default via 192.168.34.3 dev enp0s3` (MikroTik), `default via 10.0.3.2 dev enp0s8` con métrica 1003, `10.0.3.0/24` y `192.168.34.0/24` conectadas. Se aplica la ruta de menor métrica, la de MikroTik. A diferencia de `Linux-Servicios`, este clon conserva el adaptador NAT; la salida a Internet de las pruebas se hace por la ruta de menor métrica, la de MikroTik.

Incidencia al configurarla: la primera vez el fichero `interfaces` se dejó con la dirección heredada de `Debian Server` (`192.168.34.4`) y, tras un segundo intento, se escribió la `.23` como puerta de enlace en lugar de como dirección propia. Con la puerta de enlace en una IP inexistente, la prueba TCP a `1.1.1.1:443` falló con "No existe ninguna ruta hasta el host" y `ip neigh` mostraba `192.168.34.23 FAILED`. Se corrigió dejando `address 192.168.34.23/24` y `gateway 192.168.34.3`.

### 4.3 Pruebas de funcionamiento

| Prueba | Resultado |
|---|---|
| `ping -c 3 192.168.34.3` | 3/3 respuestas, 0 % de pérdida, 0,463 / 0,473 / 0,493 ms |
| `ping -c 3 192.168.34.20` (TrueNAS) | 3/3 respuestas, 0 % de pérdida, 0,554 / 0,689 / 0,764 ms |
| TCP 443 a `1.1.1.1` | `abierto` |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-linux-datos-pruebas-red.png`.

### 4.4 Usuario de administración

Hereda `batoi` y `root` de `Debian Server`; se entra como `batoi` y se pasa a `root` con `su -` (visible en la captura de versión).

### 4.5 Copia al servidor de copias

Con `nasbackup` por SFTP, en `/mnt/NAS_DATA/copias_seguridad/linux-datos/`:

| Fichero | Tamaño | Contenido |
|---|---|---|
| `hostname` | 12 bytes | Nombre del equipo |
| `interfaces` | 394 bytes | Configuración de red |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-linux-datos-copia-sftp-truenas.png` (`ls -l`). Se copiaron dos veces: la primera, con una configuración errónea (`192.168.34.4`), y la segunda, ya corregida, que sustituyó a la anterior.

Los ficheros aparecen en TrueNAS con fecha `Nov 16 10:59` aunque en Debian eran las 19:59: el reloj o la zona horaria de TrueNAS está en hora del Pacífico (UTC-8). Conviene ponerlo en `Europe/Madrid` para que las marcas de tiempo de las copias y los registros coincidan con las del resto del laboratorio.

Misma política que en `Linux-Servicios`: no se copia la imagen del disco ni contraseñas.
