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
