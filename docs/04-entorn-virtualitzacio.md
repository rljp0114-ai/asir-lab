# 04. Entorno de virtualización

## 1. Plataforma
- **Virtualizador:** VirtualBox.
- **Anfitrión:** AMD Ryzen 5 3400G, 16 GB de RAM.
- **Espacio libre del SSD:** pendiente de comprobar.

## 2. Inventario de máquinas virtuales

| Nombre de VM | Sistema y versión | vCPU | RAM | Disco virtual | Adaptadores | Estado |
|---|---|---:|---:|---:|---|---|
| Debian Server inicial | Debian 13 Server, sin entorno gráfico | Pendiente de verificar | Pendiente de verificar | Pendiente de verificar | NAT y red interna prevista/configurada | Instalada; comprobar configuración |
| Cliente de pruebas | Pendiente | — | — | — | — | Pendiente |

Consultar la configuración de cada VM en VirtualBox y sustituir “pendiente” por valores reales.

## 3. Instalación de Debian Server
Datos conocidos:
- Debian 13 Server instalado.
- No se instaló entorno gráfico.
- Durante la instalación se seleccionaron SSH server y utilidades estándar (según la información disponible).

## 4. Red de la VM
- Adaptador NAT: se observó `enp0s3` con `10.0.2.15/24`.
- Segundo adaptador: configurado como red interna de VirtualBox con el nombre `asir_lab`.
- Falta comprobar que Debian detecta el segundo adaptador y configurar/verificar su IP.

## 5. Estado de componentes

| Elemento | Estado | Evidencia/comentario |
|---|---|---|
| Instalación Debian Server | Ejecutado | Añadir captura o salida del sistema |
| Adaptador NAT | Observado anteriormente; comprobar estado actual | `ip -br address` |
| Red interna `asir_lab` | Configurada en VirtualBox según la información disponible | Comprobar desde Debian |
| VM cliente | Pendiente | — |
| Servicios adicionales | Pendiente de definir | — |

## 6. Comandos útiles dentro de Debian Server

```bash
cat /etc/os-release
ip -br address
ip route
free -h
lsblk
```
