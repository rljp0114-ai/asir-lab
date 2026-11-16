# 04. Entorno de virtualización

## 1. Plataforma y equipos anfitriones

Se utilizarán dos equipos físicos con Linux Mint y VirtualBox para ejecutar y repartir las máquinas virtuales del laboratorio.

| Característica | PC doméstico | Portátil ASUS |
|---|---|---|
| Sistema anfitrión | Linux Mint | Linux Mint 22.3 |
| Virtualizador | VirtualBox | VirtualBox |
| Procesador | AMD Ryzen 5 3400G, 4 núcleos/8 hilos | Intel Core Ultra 5 125H, 14 núcleos/18 hilos |
| Memoria RAM | 16 GB | 32 GB |
| Almacenamiento | SSD, aproximadamente 700 GB según estimación; falta medir el espacio libre | SanDisk Portable SSD de 931,5 GB por USB 3.2 |
| Espacio libre | Pendiente de confirmar | 89 GB en `/` y 613 GB en `/home` |

El SSD Samsung interno de 1 TB del portátil queda excluido del proyecto. El sistema Linux Mint que se utilizará está instalado en el SanDisk Portable SSD.

## 2. Distribución de la carga

Se repartirán las máquinas virtuales entre los dos anfitriones según sus recursos disponibles. El portátil tiene más memoria RAM y capacidad de CPU, mientras que el PC doméstico dispone de 16 GB de RAM. La distribución definitiva se decidirá según los requisitos de cada VM y las pruebas de funcionamiento.

No se debe asumir que todas las máquinas virtuales pueden ejecutarse simultáneamente. Habrá que reservar memoria y CPU para los sistemas anfitriones y comprobar el consumo real.

## 3. Inventario de máquinas virtuales

| Nombre de VM | Sistema y versión | Anfitrión | vCPU | RAM | Disco virtual | Adaptadores | Estado |
|---|---|---|---:|---:|---:|---|---|
| Debian Server inicial | Debian 13 Server, sin entorno gráfico | Pendiente de asignar definitivamente | Pendiente de verificar | Pendiente de verificar | Pendiente de verificar | NAT y red interna prevista/configurada | Instalada |
| Cliente de pruebas | Pendiente | Pendiente | — | — | — | — | Pendiente |

Completar los valores consultando la configuración de cada VM en VirtualBox. No confundir la capacidad del equipo físico con los recursos asignados a una máquina virtual.

## 4. Instalación de Debian Server

Datos conocidos:
- Debian 13 Server instalado.
- No se instaló entorno gráfico.
- Durante la instalación se seleccionaron SSH server y utilidades estándar, según la información disponible.

## 5. Red de la VM

- Adaptador NAT: anteriormente se observó `enp0s3` con `10.0.2.15/24`.
- Segundo adaptador: configurado como red interna de VirtualBox con el nombre `asir_lab`, según la información disponible.
- La configuración actual debe verificarse desde Debian antes de darla por definitiva.

## 6. Estado de componentes

| Elemento | Estado | Evidencia/comentario |
|---|---|---|
| VirtualBox en los dos anfitriones | Pendiente de verificar/documentar versión | — |
| Instalación Debian Server | Ejecutado | Añadir evidencia al revisar el apartado |
| Adaptador NAT | Observado anteriormente; comprobar estado actual | `ip -br address` |
| Red interna `asir_lab` | Configurada anteriormente según la información disponible | Comprobar desde Debian |
| VM cliente | Pendiente | — |
| Reparto de VM entre anfitriones | Pendiente de decidir y probar | — |

## 7. Comandos útiles dentro de Debian Server

```bash
cat /etc/os-release
ip -br address
ip route
free -h
lsblk
```
