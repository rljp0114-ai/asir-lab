# 04. Entorno de virtualización

## 1. Plataforma y equipos anfitriones

Se utilizarán dos equipos físicos con Linux Mint y VirtualBox para ejecutar y repartir las máquinas virtuales del laboratorio.

| Característica | PC doméstico | Portátil ASUS |
|---|---|---|
| Sistema anfitrión | Linux Mint | Linux Mint 22.3 |
| Virtualizador | VirtualBox 7.0.20 r163906 | VirtualBox (versión pendiente de anotar) |
| Procesador | AMD Ryzen 5 3400G, 4 núcleos/8 hilos | Intel Core Ultra 5 125H, 14 núcleos/18 hilos |
| Memoria RAM | 16 GB | 32 GB |
| Almacenamiento | SSD, aproximadamente 700 GB según estimación; falta medir el espacio libre | SanDisk Portable SSD de 931,5 GB por USB 3.2 |
| Espacio libre | Pendiente de confirmar | 89 GB en `/` y 613 GB en `/home` |

El SSD Samsung interno de 1 TB del portátil queda excluido del proyecto. El sistema Linux Mint que se utilizará está instalado en el SanDisk Portable SSD.

## 2. Distribución de la carga

Se repartirán las máquinas virtuales entre los dos anfitriones según sus recursos disponibles. El portátil tiene más memoria RAM y capacidad de CPU, mientras que el PC doméstico dispone de 16 GB de RAM. La distribución definitiva se decidirá según los requisitos de cada VM y las mediciones de rendimiento (tarea 7).

No se debe asumir que todas las máquinas virtuales pueden ejecutarse simultáneamente. Habrá que reservar memoria y CPU para los sistemas anfitriones y comprobar el consumo real.

**Cálculo de la memoria asignada.** Sumando la RAM asignada a todas las VM del laboratorio (apartado 3) se obtienen unos 35 GB, más que la RAM de cualquiera de los dos anfitriones (16 GB y 32 GB). Por tanto, nunca se encenderán todas a la vez; en cada prueba se arrancan solo las VM necesarias (por ejemplo, un router, el cliente Debian y TrueNAS).

## 3. Inventario de máquinas virtuales

Datos obtenidos con `VBoxManage list vms`, `VBoxManage showvminfo --machinereadable` y `VBoxManage list hdds` en el equipo que dispone del adaptador puente `enp8s0` (PC doméstico). Los valores son los **asignados** a cada VM, no los del equipo físico. La capacidad de disco es la capacidad máxima del disco virtual.

| VM | Sistema | vCPU | RAM | Disco virtual | Adaptadores | Estado |
|---|---|---:|---:|---|---|---|
| Debian Server | Debian 13 Server (cliente de pruebas) | 2 | 2 GB | 20 GB | 1: red interna `asir_lab`; 2: NAT | Instalada y probada |
| Ubuntu Server | Ubuntu Server (router con nftables) | 2 | 2 GB | 25 GB | 1: NAT; 2: red interna `asir_lab`; 3: host-only `vboxnet2` | Instalada, configurada y probada |
| Mikrotik | MikroTik RouterOS/CHR | 1 | 512 MB | 2 GB | 1: puente `enp8s0`; 2: red interna `asir_lab` | Instalada, configurada y probada |
| OPNsense | OPNsense | 2 | 5 GB | 20 GB | 1: puente `enp8s0`; 2: red interna `asir_lab`; 3: host-only `vboxnet1` | Instalada, configurada y probada |
| TrueNAS | TrueNAS (NAS de copias) | 2 | 8 GB | 20 GB + 20 GB | 1: red interna `asir_lab`; 2: host-only `vboxnet1`; 3: host-only `vboxnet2` | Instalada y en uso para copias |
| Mikrotik-RECUPERACION | Clon de MikroTik | 1 | 512 MB | 2 GB | 1: NAT; 2: red interna `asir_lab`; 3: host-only `vboxnet2` | Usada en la prueba de recuperación |
| OPNsense-RECUPERACION | Clon de OPNsense | 2 | 5 GB | 20 GB | 1: puente `enp8s0`; 2: red interna `asir_lab`; 3: host-only `vboxnet2` | Usada en la prueba de recuperación |
| Proxmox N1 | Proxmox VE (nodo 1) | 2 | 6 GB | 64 GB | 1: NAT; 2: red interna `asir_lab`; 3: host-only `vboxnet1` | VM creada; instalación iniciada hasta la consola, sin clúster |
| Proxmox N2 | Proxmox VE (nodo 2) | 2 | 3 GB | 40 GB | 1: NAT; 2: red interna `asir_lab` | VM creada; instalación no confirmada |
| Proxmox N3 | Proxmox VE (nodo 3) | 2 | 3 GB | 40 GB | 1: NAT; 2: red interna `asir_lab` | VM creada; instalación no confirmada |

Notas:
- El campo "tipo de SO" que muestra VirtualBox para algunas VM (por ejemplo, "Oracle Linux") es solo una etiqueta de la configuración y no indica el sistema realmente instalado.
- Las VM `Debian 13.1`, `W11`, `W11 Particiones` e `ISO-DUAL-<iniciales>` pertenecen a otras actividades y no forman parte de este laboratorio.
- Suma de la capacidad máxima de los discos del laboratorio: unos 273 GB. El espacio realmente ocupado es menor si los discos son de tamaño dinámico; está pendiente de comprobar.
- Aún no existen VM de Windows Server 2025, cliente GNU/Linux ni servidores GNU/Linux de infraestructura.

## 4. Instalación de Debian Server

Datos conocidos:
- Debian 13 Server instalado.
- No se instaló entorno gráfico.
- Durante la instalación se seleccionaron SSH server y utilidades estándar, según la información disponible.

## 5. Red de las VM

El detalle de los adaptadores de cada VM, el modo de la interfaz WAN y las redes host-only está en `04-red/05-xarxa.md`.

Resumen:
- La interfaz WAN de MikroTik y OPNsense (y del clon de OPNsense) es un adaptador puente sobre la tarjeta física del anfitrión (`enp8s0`).
- Ubuntu Server y el clon de MikroTik usan NAT de VirtualBox como WAN.
- La LAN de todos los routers es la red interna `asir_lab` (`192.168.34.0/24`).
- Las redes host-only (`vboxnet1`, `vboxnet2`) se utilizan para la gestión desde el anfitrión.

## 6. Estado de componentes

| Elemento | Estado | Evidencia/comentario |
|---|---|---|
| VirtualBox en los dos anfitriones | PC doméstico: 7.0.20 r163906. Portátil: pendiente de anotar la versión | `VBoxManage --version` |
| Inventario de VM del PC doméstico | Documentado (apartado 3) | Salida de `VBoxManage` |
| Inventario de VM del portátil | Pendiente de revisar si hay VM en el portátil | `VBoxManage list vms` |
| Router Ubuntu con nftables | Configurado y probado | `evidencies/Comandos.md` |
| Router MikroTik | Configurado y probado | `evidencies/Comandos.md` |
| Router OPNsense | Configurado y probado | `evidencies/Comandos.md` |
| TrueNAS (copias) | Instalado y en uso | `evidencies/Comandos.md` |
| Proxmox | Decisión de diseño/simulación (apartado 8) | Pendiente de autorización del profesorado |
| Windows Server 2025, cliente GNU/Linux, servidores GNU/Linux de infraestructura | Pendientes de crear | — |
| Reparto de VM entre anfitriones | Pendiente de decidir y probar | Tarea 7 |

## 7. Comandos útiles

Dentro de Debian Server:

```bash
cat /etc/os-release
ip -br address
ip route
free -h
lsblk
```

En el anfitrión (VirtualBox):

```bash
VBoxManage --version
VBoxManage list vms
VBoxManage list hostonlyifs
VBoxManage list hdds
VBoxManage showvminfo "NOMBRE_VM" --machinereadable
```

## 8. Decisión sobre Proxmox: diseño y simulación en lugar de clúster operativo

**Estado.** Se crearon tres VM para los nodos Proxmox (N1, N2 y N3). Se decide no desplegar el clúster sobre VirtualBox y documentarlo como diseño o simulación identificada, a falta de la autorización del profesorado (el enunciado contempla el diseño o la simulación cuando no hay nodos suficientes).

**Motivos.**
- **Doble capa de virtualización.** Proxmox es un hipervisor; ejecutarlo dentro de una VM de VirtualBox añade una segunda capa de virtualización. El rendimiento es inferior al de un servidor real y los tiempos y consumos medidos en una migración no serían representativos, por lo que la tarea de medir tiempo y espacio perdería valor.
- **Memoria.** Los tres nodos reservan 12 GB de RAM (6 + 3 + 3) solo para los propios nodos, sin contar las VM que se ejecutarían dentro. El PC doméstico tiene 16 GB, y la suma de todas las VM del laboratorio (unos 35 GB) supera la RAM de ambos anfitriones.
- **Recursos compartidos con el resto del laboratorio.** Mantener el clúster encendido impediría ejecutar a la vez el router, TrueNAS y el cliente de pruebas.

**Qué se documenta en su lugar** (pendiente de redactar): diseño del clúster (nodos, red de gestión, quórum y almacenamiento compartido), máquinas virtuales previstas, ventajas e inconvenientes de virtualizar servidores, diferencia entre contenedor y máquina virtual y cuándo usar cada uno, procedimiento previsto de migración y qué copias se guardarían en el servidor de copias y por qué.

**Limitación reconocida.** Al no haber nodos operativos, la migración de un contenedor y una VM entre nodos y su medición no se ejecutan en el laboratorio. Si el profesorado no autoriza esta alternativa, el criterio quedaría pendiente y habría que replantear el despliegue (por ejemplo, en el portátil de 32 GB).
