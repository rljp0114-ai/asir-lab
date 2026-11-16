# Servidores GNU/Linux de infraestructura

## 1. Objetivo

Instalar los servidores GNU/Linux de infraestructura del laboratorio, configurar su usuario de administración y su red, y guardar su configuración en el servidor de copias (tarea 5). El enunciado indica que, de momento, no se instala software adicional: cada servidor queda como sistema base listo para recibir servicios más adelante.

## 2. Servidores previstos

| Servidor | VM | IP | Función prevista | Estado |
|---|---|---|---|---|
| Servicios | `Linux-Servicios` | `192.168.34.22/24` | Servicios de infraestructura (sin software adicional por ahora) | Instalado y probado (16/11/2026) |
| Datos | `Linux-Datos` | `192.168.34.23/24` | Datos (sin software adicional por ahora) | Pendiente de clonar |

Ambos se crean como **clon completo** de la VM `Debian Server`, con nuevas direcciones MAC, y se ejecutan como VM independientes de VirtualBox. No van dentro de los nodos Proxmox porque los recursos son limitados (ver `00-preparacion/04-entorn-virtualitzacio.md`, apartado 8).

## 3. Linux-Servicios

### 3.1 Versión

| Dato | Valor |
|---|---|
| Sistema | Debian GNU/Linux 13 (trixie) |
| Kernel | 6.12.113+deb13-amd64 |
| Nombre de equipo | `linux-servicios` (cambiado con `hostnamectl set-hostname`) |
| Virtualización | Oracle VirtualBox |

Evidencia: `evidencies/2026-11-16-linux-servicios-version-red.png` (19:32:47 del 16/11/2026).

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

Evidencia: `evidencies/2026-11-16-linux-servicios-pruebas-red.png`.

### 3.4 Usuario de administración

Se hereda de `Debian Server`: el usuario `batoi` y la cuenta `root`, a la que se pasa con `su -`. En las capturas se trabaja como `root` (`root@linux-servicios`).

### 3.5 Copia al servidor de copias

Con `nasbackup` por SFTP se copiaron a `/mnt/NAS_DATA/copias_seguridad/linux-servicios/`:

| Fichero | Tamaño | Contenido |
|---|---|---|
| `hostname` | 16 bytes | Nombre del equipo |
| `interfaces` | 394 bytes | Configuración de red |

Evidencia: `evidencies/2026-11-16-linux-servicios-copia-sftp-truenas.png`.

No se copia la imagen del disco (20 GB): la VM se vuelve a crear clonando `Debian Server` y reconfigurando con estos ficheros. Tampoco se copian contraseñas.

### 3.6 Observación: identificadores duplicados por clonar

El `Machine ID` que muestra `hostnamectl` (`7138cb0a...`) es **el mismo** que el de `Debian Server`, porque el clon lo hereda. Dos equipos con el mismo identificador pueden confundir a servicios que lo usan para identificarse en red. Pendiente de regenerarlo en el clon (`rm /etc/machine-id`, `systemd-machine-id-setup` y reiniciar); también se regenerarían las claves SSH del servidor si se utilizaran.

## 4. Linux-Datos

Pendiente: clonar `Debian Server`, asignar `192.168.34.23/24` y el nombre `linux-datos`, repetir las pruebas y copiar su configuración a `/mnt/NAS_DATA/copias_seguridad/linux-datos/`.
