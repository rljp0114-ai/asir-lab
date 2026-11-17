# 02. Inventario y diagnóstico de los equipos

Este inventario recoge los dos equipos físicos que se utilizarán como anfitriones de las máquinas virtuales del laboratorio doméstico. Se excluye expresamente el disco Samsung interno de 1 TB del portátil: no se utilizará ni se considera recurso disponible para el laboratorio.

## 1. PC doméstico

| Elemento | Dato |
|---|---|
| Procesador | AMD Ryzen 5 3400G |
| Núcleos/hilos | 4 núcleos y 8 hilos |
| Memoria RAM | 16 GB |
| Almacenamiento | El mismo SanDisk Portable SSD de 931,5 GB que usa el portátil (ver apartado 2) |
| Sistema operativo anfitrión | Linux Mint 22.3, la misma instalación que el portátil |
| Virtualizador | VirtualBox 7.0.20 |

**Un único sistema, dos equipos.** Linux Mint y las máquinas virtuales están en un SSD externo que se conecta al PC o al portátil: se arranca la misma instalación (el nombre de equipo es `JuanpaPC` en ambos) y se ven las mismas 19 VM (`VBoxManage list vms`, 17/11/2026). Solo puede estar conectado a un equipo a la vez, por lo que el laboratorio se ejecuta en uno u otro, no en los dos a la vez. La estimación anterior de 700 GB para el PC se sustituye por los datos medidos del SanDisk (apartado 2).

## 2. Portátil ASUS ExpertBook B3605CCA

| Elemento | Dato |
|---|---|
| Procesador | Intel Core Ultra 5 125H |
| Núcleos/hilos | 14 núcleos y 18 hilos |
| Memoria RAM | 32 GB |
| Sistema operativo anfitrión | Linux Mint 22.3 |
| Virtualizador | VirtualBox |
| Unidad utilizada por Linux Mint | SanDisk Portable SSD de 931,5 GB, conectado por USB 3.2 |
| Partición raíz `/` | 121 GB; aproximadamente 89 GB libres |
| Partición `/home` | 795 GB; aproximadamente 613 GB libres |
| Red cableada | Intel Ethernet Gigabit |
| Red inalámbrica | Wi-Fi 6 |

### Medidas realizadas en el portátil (17/11/2026, en el aula)

| Dato | Valor | Comando |
|---|---|---|
| Modelo | ASUS ExpertBook B3605CCA, firmware B3605CCA.303 (11/06/2025) | `hostnamectl` |
| Sistema | Linux Mint 22.3, kernel 6.8.0-149-generic | `hostnamectl` |
| CPU | Intel Core Ultra 5 125H, 1 socket, 18 hilos lógicos, frecuencia de 400 MHz a 4500 MHz | `lscpu` |
| Memoria | 30 GiB visibles (32 GB nominales), 4,5 GiB en uso, 26 GiB disponibles | `free -h` |
| Swap | 7,6 GB en zram (en memoria comprimida), sin uso | `lsblk`, `free -h` |
| SanDisk externo | `sda`, 931,5 GB: `sda1` 509 MB (EFI), `sda2` 122,6 GB (`/`), `sda3` 808,4 GB (`/home`) | `lsblk` |
| Raíz `/` | 121 GB, 28 GB usados, 87 GB libres (25 %) | `df -h /` |
| SSD interno | `nvme0n1`, 953,9 GB, **sin puntos de montaje** (no se usa) | `lsblk` |
| Red | `eno1` (cable) activa; `wlp1s0` (Wi-Fi) apagada; `docker0` sin uso; `vboxnet0`, `vboxnet1` y `vboxnet2` creadas | `ip -br link` |
| VirtualBox | 7.0.20 r163906 | `VBoxManage --version` |

El disco interno aparece sin montar, lo que confirma que no se está utilizando. Las tres redes host-only existen también en este equipo, por lo que las VM de gestión podrán arrancar aquí con los mismos direccionamientos.

**Observación (confirmada por el alumno):** el nombre de equipo del portátil es `JuanpaPC`, igual que el del PC doméstico, porque es la misma instalación de Linux Mint en el mismo SanDisk, conectado a uno u otro equipo. `VBoxManage list vms` muestra las mismas 19 VM en el portátil.

| Partición | Tamaño | Usado | Libre | Medido el |
|---|---|---|---|---|
| `/` (`sda2`) | 121 GB | 28 GB | 87 GB | 17/11/2026 |
| `/home` (`sda3`) | 795 GB | 197 GB | 559 GB | 17/11/2026 |

Las VM están en `/home`, por lo que el espacio relevante para crear nuevos discos virtuales son los 559 GB libres de esa partición.

**Disco excluido:** el SSD interno Samsung de aproximadamente 1 TB no se tendrá en cuenta ni se modificará para este proyecto. El sistema Linux Mint utilizado para el laboratorio está instalado en el SanDisk Portable SSD.

## 3. Comparación y diagnóstico de recursos

| Recurso | PC doméstico | Portátil |
|---|---|---|
| CPU | Ryzen 5 3400G, 4 núcleos/8 hilos | Core Ultra 5 125H, 14 núcleos/18 hilos |
| RAM | 16 GB | 32 GB |
| Almacenamiento utilizado | SanDisk externo, 931,5 GB (el mismo disco) | SanDisk externo, 931,5 GB |
| Espacio libre confirmado | 87 GB en `/` y 559 GB en `/home` (el disco es el mismo) | 87 GB en `/` y 559 GB en `/home` (medido el 17/11/2026) |

### Limitaciones y decisiones

- Los recursos de cada equipo deben compartirse entre Linux Mint y las máquinas virtuales. No se puede asignar toda la RAM ni todos los recursos de CPU a las VM.
- El PC doméstico dispone de 16 GB de RAM, por lo que será necesario limitar el número de máquinas virtuales encendidas simultáneamente. Como el disco es el mismo, no se pueden repartir las VM entre los dos equipos a la vez: se ejecutan en el que tenga el SanDisk conectado.
- El portátil dispone de 32 GB de RAM y un procesador con más núcleos e hilos, por lo que permite una carga de virtualización mayor; allí tiene sentido ejecutar el clúster Proxmox.
- En ambos equipos, el sistema se ejecuta desde un SSD externo conectado por USB. Esto añade dependencia del cable y del puerto USB y puede influir en el rendimiento de las operaciones de disco frente a una unidad interna. El impacto real dependerá de la unidad y se comprobará durante las pruebas.
- El espacio libre (559 GB en `/home`) se verificará antes de crear nuevos discos virtuales.
- Se mide el rendimiento en cada equipo por separado (tarea 7): en el PC se ve el límite de 16 GB y en el portátil el margen de 32 GB.

## 4. Comprobaciones realizadas y pendientes

| Comprobación | Estado |
|---|---|
| CPU y RAM del PC doméstico | Datos identificados |
| Almacenamiento del PC doméstico | Es el mismo SanDisk que el portátil: 931,5 GB y 559 GB libres en `/home` |
| CPU y RAM del portátil | Identificados |
| Almacenamiento del portátil | Medido el 17/11/2026 con `lsblk` y `df -h` |
| Disco Samsung interno del portátil | Excluido del laboratorio |
| Interfaces de red y conectividad de ambos equipos | Portátil documentado (`eno1`, Wi-Fi, host-only); PC doméstico pendiente |
| Prueba de ejecución de VM en cada equipo | Pendiente (tarea 7) |

## 5. Comandos de diagnóstico

En Linux se pueden utilizar estos comandos para consultar los recursos del anfitrión:

```bash
lscpu
free -h
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
df -h
ip -br address
```

Antes de publicar las salidas, revisar que no incluyan información privada.

## 6. Evidencias

Cuando se complete la implementación, guardar las capturas o salidas de comandos seleccionadas en `evidencies/`. No incluir contraseñas, claves privadas ni información sensible.
