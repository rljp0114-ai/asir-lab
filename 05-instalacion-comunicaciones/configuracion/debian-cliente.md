# Debian - Cliente de la red interna

## 1. Objetivo

Configurar una máquina virtual Debian como cliente de la red interna `asir_lab`.

Esta máquina utiliza Ubuntu Server como puerta de enlace para acceder a Internet.

El objetivo es comprobar que un equipo conectado a la LAN puede comunicarse con el router, salir a Internet y resolver nombres de dominio mediante DNS.

## 2. Características de la máquina virtual

| Característica | Configuración |
|---|---|
| Sistema operativo | Debian |
| Función | Cliente de red |
| Virtualizador | VirtualBox |
| Red | asir_lab |

## 3. Configuración de red

La máquina Debian está conectada a la red interna `asir_lab` mediante la interfaz `enp0s3`.

| Parámetro | Valor |
|---|---|
| Interfaz | enp0s3 |
| Dirección IP | 192.168.34.4/24 |
| Máscara | 255.255.255.0 |
| Puerta de enlace | 192.168.34.3 |
| DNS principal | 8.8.8.8 |
| DNS secundario | 1.1.1.1 |

La puerta de enlace corresponde a Ubuntu Server, que se encarga de encaminar el tráfico hacia Internet.

## 4. Configuración IP persistente

Debian utiliza ifupdown para gestionar la configuración de red.

Archivo:

`/etc/network/interfaces`

Configuración aplicada:

```text
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
    address 192.168.34.4/24
    gateway 192.168.34.3
```

Se utiliza `auto enp0s3` para que la interfaz se active automáticamente durante el arranque del sistema.

La dirección IP y la puerta de enlace se configuran de forma estática para mantener la misma configuración después de reiniciar.

## 5. Configuración DNS

Se configuraron los servidores DNS en el archivo:

`/etc/resolv.conf`

Contenido:

```text
# DNS del laboratorio ASIR ThinkLab
nameserver 8.8.8.8
nameserver 1.1.1.1
```

Estos servidores permiten traducir nombres de dominio, como `google.com`, a sus correspondientes direcciones IP.

Se comprobó que la configuración se conservaba después de reiniciar la máquina.

## 6. Pruebas de conectividad

Se realizaron las siguientes comprobaciones:

### 6.1. Comprobación de la dirección IP

```bash
ip -br addr
```

Permite comprobar que la interfaz tiene asignada la dirección `192.168.34.4/24`.

### 6.2. Comprobación de la puerta de enlace

```bash
ip route
```

Permite verificar que la ruta predeterminada utiliza Ubuntu Server:

```text
default via 192.168.34.3 dev enp0s3
```

### 6.3. Comunicación con Ubuntu Server

```bash
ping -c 4 192.168.34.3
```

Se comprueba que Debian puede comunicarse con el router.

### 6.4. Conectividad con Internet

```bash
ping -c 4 1.1.1.1
```

Se comprueba que Debian puede alcanzar una dirección IP externa.

### 6.5. Resolución DNS

```bash
getent hosts google.com
```

También se realizó la prueba:

```bash
ping -c 4 google.com
```

Estas comprobaciones permiten verificar que los servidores DNS funcionan correctamente.

## 7. Resultado

Debian funciona correctamente como cliente de la red interna `asir_lab`.

Dispone de una dirección IP estática, utiliza Ubuntu Server como puerta de enlace y puede acceder a Internet mediante el encaminamiento y NAT configurados en Ubuntu.

La configuración de IP, puerta de enlace y DNS se comprobó después de reiniciar la máquina.

## 8. Evidencias

Se adjuntarán las siguientes capturas:

- `evidencias/interfaces-red.png`: dirección IP de Debian.
- `evidencias/rutas-red.png`: tabla de encaminamiento.
- `evidencias/configuracion-dns.png`: servidores DNS configurados.
- `evidencias/conectividad-router.png`: comunicación con Ubuntu Server.
- `evidencias/conectividad-internet.png`: conexión a Internet y resolución DNS.

## 9. Uso como cliente GNU/Linux de la tarea 5

Debian Server se utiliza también como el cliente GNU/Linux del laboratorio. Los apartados anteriores se redactaron con Ubuntu Server como router; la comprobación del 16/11/2026 se hizo con **MikroTik** como puerta de enlace (`192.168.34.3`, misma dirección que Ubuntu).

### 9.1 Versión

| Dato | Valor |
|---|---|
| Sistema | Debian GNU/Linux 13 (trixie), versión 13.7 |
| Kernel | 6.12.113+deb13-amd64 |
| Nombre de equipo | `debian-server` |
| Virtualización | Oracle VirtualBox (`hostnamectl`) |
| Equipo físico | PC doméstico; VM `Debian Server (02-11)` |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-debian-version-hostnamectl.png` (19:06 del 16/11/2026).

### 9.2 Red

| Interfaz | Estado | Dirección | Función |
|---|---|---|---|
| `enp0s3` | UP | `192.168.34.4/24` | LAN `asir_lab` |
| `enp0s8` | UP | `10.0.3.15/24` (DHCP) | NAT de VirtualBox |

Tabla de rutas: `default via 192.168.34.3 dev enp0s3` (MikroTik), `default via 10.0.3.2 dev enp0s8` con métrica 1003, `10.0.3.0/24` y `192.168.34.0/24` conectadas. Se usa la ruta de menor métrica, la de MikroTik.

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-debian-red-rutas-mikrotik.png`.

### 9.3 Usuario

Usuario de trabajo: `batoi` (UID 1000). En la comprobación, `getent group sudo` devolvió `sudo:x:27:` sin miembros, de modo que `batoi` no pertenece al grupo `sudo`. La administración del sistema se hace con la cuenta `root`: el administrador entra como `batoi` y cambia a `root` con `su -` (así lo indica el alumno). Comprobado a las 19:14 del 16/11/2026: `whoami` como `batoi`, `su -` con contraseña, y después `whoami` = `root` e `id` = `uid=0(root) gid=0(root) grupos=0(root)`.

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-debian-su-root.png`.

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-debian-usuario-copia-sftp-truenas.png` (`getent group sudo` e `id`).

### 9.4 Copia al servidor de copias

Se copiaron a TrueNAS (`192.168.34.20`), con el usuario `nasbackup`, el nombre del equipo y la configuración de red:

```text
sftp> mkdir /mnt/NAS_DATA/copias_seguridad/linux
sftp> put /etc/hostname /mnt/NAS_DATA/copias_seguridad/linux/
sftp> put /etc/network/interfaces /mnt/NAS_DATA/copias_seguridad/linux/
sftp> ls /mnt/NAS_DATA/copias_seguridad/linux
```

El `ls` lista `hostname` e `interfaces` en `/mnt/NAS_DATA/copias_seguridad/linux/`. Es la primera conexión SFTP desde este equipo; se aceptó la huella ED25519 del servidor, la misma que vieron los equipos Windows.

Durante la copia se subió por error un `hostname` a `/mnt/NAS_DATA/copias_seguridad/` (un `put /etc/hostname` sin carpeta de destino). Era un fichero duplicado y sin uso; el alumno lo borró con `rm /mnt/NAS_DATA/copias_seguridad/hostname` desde `sftp` (sin captura del borrado).

| Elemento | ¿Se copia? | Motivo |
|---|---|---|
| `/etc/network/interfaces` y `/etc/hostname` | Sí | Pequeños; recogen la identidad y la red del equipo y no se deducen de la ISO |
| Imagen del disco (20 GB) | No | Ocupa mucho espacio; la VM se reinstala desde la ISO y se reconfigura con estos ficheros |
| Contraseñas | No | No deben guardarse en ficheros de texto |

### 9.5 Estado

Cliente GNU/Linux completo: instalación y versión, usuario de administración, red y copia a TrueNAS. Sin pendientes.
