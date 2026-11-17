# 02. Inventario y diagnóstico de los equipos

Este inventario recoge los dos equipos físicos que se utilizarán como anfitriones de las máquinas virtuales del laboratorio doméstico. Se excluye expresamente el disco Samsung interno de 1 TB del portátil: no se utilizará ni se considera recurso disponible para el laboratorio.

## 1. PC doméstico

| Elemento | Dato |
|---|---|
| Procesador | AMD Ryzen 5 3400G |
| Núcleos/hilos | 4 núcleos y 8 hilos |
| Memoria RAM | 16 GB |
| Almacenamiento | SSD, aproximadamente 700 GB disponibles según la estimación actual |
| Sistema operativo anfitrión | Linux Mint |
| Virtualizador | VirtualBox |

La capacidad y el espacio libre exactos del SSD quedan pendientes de comprobar mediante `lsblk` y `df -h`. La cifra de 700 GB es aproximada y no debe interpretarse como espacio libre confirmado.

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

**Observación:** el nombre de equipo del portátil es `JuanpaPC`, igual que el del PC doméstico; la instalación de Linux Mint de este SSD externo parece ser la misma que se utiliza en el otro equipo. Pendiente de confirmar.

**Disco excluido:** el SSD interno Samsung de aproximadamente 1 TB no se tendrá en cuenta ni se modificará para este proyecto. El sistema Linux Mint utilizado para el laboratorio está instalado en el SanDisk Portable SSD.

## 3. Comparación y diagnóstico de recursos

| Recurso | PC doméstico | Portátil |
|---|---|---|
| CPU | Ryzen 5 3400G, 4 núcleos/8 hilos | Core Ultra 5 125H, 14 núcleos/18 hilos |
| RAM | 16 GB | 32 GB |
| Almacenamiento utilizado | SSD, unos 700 GB estimados | SanDisk externo, 931,5 GB |
| Espacio libre confirmado | Pendiente de medir | 87 GB en `/` (medido el 17/11/2026); `/home`: pendiente de medir con `df -h /home` |

### Limitaciones y decisiones

- Los recursos de cada equipo deben compartirse entre Linux Mint y las máquinas virtuales. No se puede asignar toda la RAM ni todos los recursos de CPU a las VM.
- El PC doméstico dispone de 16 GB de RAM, por lo que será necesario limitar el número de máquinas virtuales encendidas simultáneamente o repartirlas entre los dos equipos.
- El portátil dispone de 32 GB de RAM y un procesador con más núcleos e hilos, por lo que permite asumir una parte mayor de la carga de virtualización.
- En el portátil, el sistema se ejecuta desde un SSD externo conectado por USB. Esto añade dependencia del cable y del puerto USB y puede influir en el rendimiento de las operaciones de disco frente a una unidad interna. El impacto real dependerá de la unidad y se comprobará durante las pruebas.
- El espacio del PC doméstico es una estimación; se verificará antes de crear nuevos discos virtuales.
- Se utilizarán ambos equipos para distribuir las máquinas virtuales y evitar concentrar toda la carga en un solo anfitrión.

## 4. Comprobaciones realizadas y pendientes

| Comprobación | Estado |
|---|---|
| CPU y RAM del PC doméstico | Datos identificados |
| Almacenamiento del PC doméstico | Estimación de unos 700 GB; falta confirmar capacidad y espacio libre exactos |
| CPU y RAM del portátil | Identificados |
| Almacenamiento del portátil | Medido el 17/11/2026 con `lsblk` y `df -h /`; falta `df -h /home` |
| Disco Samsung interno del portátil | Excluido del laboratorio |
| Interfaces de red y conectividad de ambos equipos | Portátil documentado (`eno1`, Wi-Fi, host-only); PC doméstico pendiente |
| Prueba de ejecución simultánea de VM en ambos equipos | Pendiente |

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
