# 04. Entorno de virtualización

## 1. Plataforma y equipos anfitriones

Se utilizan dos equipos físicos que arrancan el mismo Linux Mint con VirtualBox, instalado en un SSD externo SanDisk que se conecta a uno u otro. Las máquinas virtuales están en ese mismo disco, por lo que el laboratorio se ejecuta en un equipo cada vez.

| Característica | PC doméstico | Portátil ASUS |
|---|---|---|
| Sistema anfitrión | Linux Mint | Linux Mint 22.3 |
| Virtualizador | VirtualBox 7.0.20 r163906 | VirtualBox 7.0.20 (misma versión que el PC, según indica el alumno) |
| Procesador | AMD Ryzen 5 3400G, 4 núcleos/8 hilos | Intel Core Ultra 5 125H, 14 núcleos/18 hilos |
| Memoria RAM | 16 GB | 32 GB |
| Almacenamiento | El mismo SanDisk Portable SSD de 931,5 GB | SanDisk Portable SSD de 931,5 GB por USB 3.2 |
| Espacio libre | 87 GB en `/` y 559 GB en `/home` (el disco es el mismo) | 87 GB en `/` y 559 GB en `/home` (medido el 17/11/2026) |

El SSD Samsung interno de 1 TB del portátil queda excluido del proyecto. El sistema Linux Mint que se utilizará está instalado en el SanDisk Portable SSD.

## 2. Distribución de la carga

Al compartir el disco, las VM no se reparten entre los dos equipos a la vez: se ejecutan en el que tenga el SSD conectado. El portátil tiene más memoria RAM y capacidad de CPU (32 GB), mientras que el PC doméstico dispone de 16 GB. Se decide qué cargas van a cada uno según los requisitos de cada VM y las mediciones de rendimiento (tarea 7): todo se diseña y se prueba primero en el PC (16 GB); si funciona ahí, funciona en el portátil.

No se debe asumir que todas las máquinas virtuales pueden ejecutarse simultáneamente. Habrá que reservar memoria y CPU para los sistemas anfitriones y comprobar el consumo real.

**Cálculo de la memoria asignada.** Sumando la RAM asignada a todas las VM del laboratorio (apartado 3) se obtienen unos 44 GB (14 VM, incluidos los clones de recuperación y los tres nodos Proxmox), más que la RAM de cualquiera de los dos anfitriones (16 GB y 32 GB). Por tanto, nunca se encenderán todas a la vez; en cada prueba se arrancan solo las VM necesarias (por ejemplo, un router, el cliente Debian y TrueNAS).

## 3. Inventario de máquinas virtuales

Datos obtenidos con `VBoxManage list vms`, `VBoxManage showvminfo --machinereadable` y `VBoxManage list hdds` en el equipo que dispone del adaptador puente `enp8s0` (PC doméstico). Los valores son los **asignados** a cada VM, no los del equipo físico. La capacidad de disco es la capacidad máxima del disco virtual.

| VM | Sistema | vCPU | RAM | Disco virtual | Adaptadores | Estado |
|---|---|---:|---:|---|---|---|
| Debian Server | Debian 13 Server (cliente de pruebas) | 2 | 2 GB | 20 GB | 1: red interna `asir_lab`; 2: NAT | Instalada y probada |
| Ubuntu Server | Ubuntu Server (router con nftables) | 2 | 2 GB | 25 GB | 1: NAT; 2: red interna `asir_lab`; 3: host-only `vboxnet2` | Instalada, configurada y probada |
| Mikrotik | MikroTik RouterOS/CHR | 1 | 512 MB | 2 GB | 1: puente `enp8s0`; 2: red interna `asir_lab` | Instalada, configurada y probada |
| OPNsense | OPNsense | 2 | 5 GB | 20 GB | 1: puente `enp8s0`; 2: red interna `asir_lab`; 3: host-only `vboxnet0` | Instalada, configurada y probada |
| TrueNAS | TrueNAS (NAS de copias) | 2 | 8 GB | 20 GB + 20 GB | 1: red interna `asir_lab`; 2: host-only `vboxnet1`; 3: host-only `vboxnet2` | Instalada y en uso para copias |
| Mikrotik-RECUPERACION | Clon de MikroTik | 1 | 512 MB | 2 GB | 1: NAT; 2: red interna `asir_lab`; 3: host-only `vboxnet2` | Usada en la prueba de recuperación |
| OPNsense-RECUPERACION | Clon de OPNsense | 2 | 5 GB | 20 GB | 1: puente `enp8s0`; 2: red interna `asir_lab`; 3: host-only `vboxnet2` | Usada en la prueba de recuperación |
| Proxmox N1 | Proxmox VE 9.2.2 (nodo `pve1`) | 2 | 3 GB | 32 GB | 1: red interna `asir_lab` (modo promiscuo: permitir todo); 2: host-only `vboxnet1` | Instalado, en el clúster `asirlab` |
| Proxmox N2 | Proxmox VE 9.2.2 (nodo `pve2`) | 2 | 3 GB | 20 GB | 1: red interna `asir_lab` (modo promiscuo: permitir todo); 2: host-only `vboxnet1` | Instalado, en el clúster `asirlab` |
| Proxmox N3 | Proxmox VE 9.2.2 (nodo `pve3`) | 2 | 3 GB | 20 GB | 1: red interna `asir_lab` (modo promiscuo: permitir todo); 2: host-only `vboxnet1` | Instalado, en el clúster `asirlab` |

Notas:
- El campo "tipo de SO" que muestra VirtualBox para algunas VM (por ejemplo, "Oracle Linux") es solo una etiqueta de la configuración y no indica el sistema realmente instalado.
- Las VM del proyecto son las **14** del grupo `/ISOFHW` de VirtualBox (`VBoxManage list vms --long`). Las otras 5, en el grupo raíz (`Debian 13.1`, `Debian 13.1 1`, `W11`, `W11 Particiones` e `ISO-DUAL-<iniciales>`), pertenecen a otras actividades, no forman parte de este laboratorio y no se cuentan en las mediciones.
- Suma de la capacidad máxima de los discos del laboratorio: unos 273 GB. El espacio realmente ocupado es menor si los discos son de tamaño dinámico.
- La VM `Windows Server 2025` (Windows Server 2025 Standard Evaluation, 2 vCPU, 4 GB, adaptador 1 NAT desactivado en Windows y adaptador 2 en red interna `asir_lab`, `192.168.34.21`) se creó el 16/11/2026 y no está en la tabla de arriba porque esta se obtuvo antes con `VBoxManage`; sus datos están en `05-instalacion-comunicaciones/configuracion/windows-server-2025.md`. Los servidores GNU/Linux de infraestructura se crean como clones de Debian Server (ver `05-instalacion-comunicaciones/configuracion/linux-infraestructura.md`).

## 4. Instalación de Debian Server

Datos conocidos:
- Debian 13 Server instalado.
- No se instaló entorno gráfico.
- Durante la instalación se seleccionaron SSH server y utilidades estándar, según la información disponible.

## 5. Red de las VM

El detalle de los adaptadores de cada VM, el modo de la interfaz WAN y las redes host-only está en `04-diseno-red/05-xarxa.md`.

Resumen:
- La interfaz WAN de MikroTik y OPNsense (y del clon de OPNsense) es un adaptador puente sobre la tarjeta física del anfitrión (`enp8s0`).
- Ubuntu Server y el clon de MikroTik usan NAT de VirtualBox como WAN.
- La LAN de todos los routers es la red interna `asir_lab` (`192.168.34.0/24`).
- Las redes host-only (`vboxnet1`, `vboxnet2`) se utilizan para la gestión desde el anfitrión.

## 6. Estado de componentes

| Elemento | Estado | Evidencia/comentario |
|---|---|---|
| VirtualBox en los dos anfitriones | PC doméstico: 7.0.20 r163906. Portátil: 7.0.20 (misma versión que el PC) | `VBoxManage --version` |
| Inventario de VM del PC doméstico | Documentado (apartado 3) | Salida de `VBoxManage` |
| Inventario de VM del portátil | Las mismas 19 VM que en el PC (14 del proyecto y 5 de otras actividades): el SanDisk es el mismo (17/11/2026) | `VBoxManage list vms` |
| Router Ubuntu con nftables | Configurado y probado | `05-instalacion-comunicaciones/configuracion/` |
| Router MikroTik | Configurado y probado | `05-instalacion-comunicaciones/configuracion/` |
| Router OPNsense | Configurado y probado | `05-instalacion-comunicaciones/configuracion/` |
| TrueNAS (copias) | Instalado y en uso | `05-instalacion-comunicaciones/configuracion/` |
| Proxmox | Clúster de tres nodos desplegado, con contenedor y VM migrados (apartado 8) | `05-instalacion-comunicaciones/configuracion/proxmox.md` |
| Windows Server 2025 | Instalado y probado (16/11/2026) | `05-instalacion-comunicaciones/configuracion/windows-server-2025.md` |
| Windows 11 (cliente) | Instalado y probado (16/11/2026) | `05-instalacion-comunicaciones/configuracion/windows-11.md` |
| Cliente GNU/Linux | Debian Server, documentado (16/11/2026) | `05-instalacion-comunicaciones/configuracion/debian-cliente.md` |
| Servidores GNU/Linux de infraestructura | `Linux-Servicios` y `Linux-Datos` instalados y probados | `05-instalacion-comunicaciones/configuracion/linux-infraestructura.md` |
| Qué cargas van en cada equipo | Medido en el PC | `07-rendimiento-diagnostico/informe-rendimiento.md` |

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

## 8. Proxmox: clúster de tres nodos y migración

**Actualización (17/11/2026).** La decisión del 16/11 (documentar solo el diseño) se sustituye por el plan de **desplegar el clúster de tres nodos** y hacer pruebas reales: crear un contenedor y migrar un contenedor y una VM entre nodos, como pide el enunciado. La rúbrica exige que la VM migrada sea un Ubuntu Server o Debian sin entorno gráfico, para que sea más rápido. El diseño o la simulación solo se usaría como alternativa autorizada si el despliegue no fuera viable.

**Estado (17/11/2026).** Desplegado en el PC doméstico (16 GB), el equipo más limitado: tres nodos de 3 GB (`pve1`, `pve2`, `pve3`), clúster `asirlab` con quórum, un contenedor y una VM Debian migrados entre nodos con tiempo y espacio medidos. El detalle está en `05-instalacion-comunicaciones/configuracion/proxmox.md`.

**Riesgos que motivaron la decisión anterior y que hay que controlar:**

- **Doble capa de virtualización.** Proxmox es un hipervisor; ejecutarlo dentro de una VM de VirtualBox añade una segunda capa de virtualización. El rendimiento es inferior al de un servidor real y los tiempos y consumos medidos en una migración no serían representativos, por lo que la tarea de medir tiempo y espacio perdería valor.
- **Memoria.** Los tres nodos reservan 9 GB de RAM (3 + 3 + 3) solo para los propios nodos, sin contar las VM que se ejecutan dentro. Con todo el clúster encendido, el PC doméstico (16 GB) llegó a 12 GiB usados y 230 MiB libres (medido el 17/11/2026), y la suma de todas las VM del laboratorio (unos 44 GB) supera la RAM de ambos anfitriones.
- **Recursos compartidos con el resto del laboratorio.** Mantener el clúster encendido impediría ejecutar a la vez el router, TrueNAS y el cliente de pruebas.

**Documentación:** `05-instalacion-comunicaciones/configuracion/proxmox.md`.

**Limitación conocida.** Dentro de VirtualBox, las VM de Proxmox necesitan virtualización anidada para ejecutar VM con aceleración; los contenedores no la necesitan. Si no está disponible, se desactiva la aceleración KVM en la VM de prueba (más lenta, pero válida con un Debian sin entorno gráfico). Los tiempos medidos no serán los de un servidor real y así se hará constar.

## 9. Portabilidad entre equipos

El SSD con Linux Mint y las máquinas virtuales se conecta al PC doméstico, al portátil o a los equipos del aula, así que todo lo que se monte debe poder ejecutarse también en el portátil (32 GB) y en clase. Reglas que se siguen:

- **Misma versión de VirtualBox** en los dos equipos propios (7.0.20).
- **Adaptador puente:** está asociado a la tarjeta física de cada equipo (`enp8s0` en el PC, `eno1` en el portátil). Al abrir una VM en otro equipo hay que volver a elegir el adaptador físico en `Configuración → Red`.
- **Redes host-only:** las VM de gestión necesitan que existan `vboxnet0`, `vboxnet1` y `vboxnet2` con los mismos direccionamientos (`192.168.56.0/24`, `192.168.57.0/24`, `192.168.58.0/24`). Si no existen en el otro equipo, hay que crearlas antes de arrancar.
- **Red interna `asir_lab`:** no depende del equipo; se crea sola al usarla.
- **Recursos:** cada VM nueva se dimensiona para caber en el equipo de 16 GB, aunque se pueda mover al de 32 GB. No se activa virtualización anidada, que depende del procesador (AMD en el PC, Intel en el portátil), salvo en los nodos Proxmox (apartado 8), que se ejecutarán primero en el PC (AMD-V) y se comprobarán en el portátil (VT-x) si hay tiempo.
- **Ruta de los discos:** las VM están en `/home/batoi/VirtualBox VMs/ISOFHW/`.
