# Proxmox VE: clúster de tres nodos

**Estado:** teoría redactada; instalación, clúster y migración **pendientes** (apartado 6). Las tres VM de los nodos están creadas y no se ha completado la instalación.

## 1. Objetivo

Montar un clúster de tres nodos Proxmox VE, crear un contenedor y una máquina virtual, migrarlos entre nodos midiendo tiempo y espacio, y decidir qué se guarda en el servidor de copias.

## 2. Diseño

| Elemento | Valor |
|---|---|
| Nodos | `pve1`, `pve2`, `pve3` |
| IP de gestión (prevista) | `192.168.34.32`, `.33` y `.34` (`/24`), puerta de enlace en el router activo |
| Red | Red interna `asir_lab` (LAN) |
| Equipo anfitrión | PC doméstico (16 GB), el equipo más limitado: se dimensiona para que quepa aquí y así funciona también en el portátil (32 GB). Con el clúster solo se enciende además el router y, si hace falta, TrueNAS |
| Quórum | Tres nodos: el clúster mantiene el quórum si falla uno (con dos nodos haría falta un dispositivo de quórum externo) |
| Almacenamiento | Local en cada nodo; la migración copia el disco entre nodos |
| Máquinas de prueba | Una VM Debian sin entorno gráfico (la rúbrica exige Ubuntu Server o Debian sin escritorio) y un contenedor Linux |

Gestión conjunta, migración y alta disponibilidad son cosas distintas: la **gestión conjunta** administra los tres nodos desde una sola interfaz; la **migración** mueve una VM o contenedor de un nodo a otro bajo demanda; la **alta disponibilidad** reinicia automáticamente un servicio en otro nodo si el suyo cae, y exige almacenamiento compartido y servicios configurados para ello. En este laboratorio se hace gestión conjunta y migración manual.

## 3. Ventajas e inconvenientes de virtualizar servidores

| Ventajas | Inconvenientes |
|---|---|
| Se aprovecha mejor el hardware: varios servidores en una máquina | Si el equipo físico falla, caen todos los servidores que aloja (punto único de fallo) |
| Aislamiento entre servidores | El hipervisor consume recursos y añade una capa que gestionar |
| Copias, instantáneas y restauración sencillas | Los servidores compiten por CPU, memoria y disco; uno puede degradar a los demás |
| Crear, clonar o mover un servidor lleva minutos | Más complejidad: red virtual, almacenamiento y actualizaciones del hipervisor |
| Migración entre nodos y alta disponibilidad | La alta disponibilidad exige almacenamiento compartido y más nodos |
| Entornos de prueba baratos y repetibles | Algunos servicios con requisitos de hardware especial o de rendimiento no se virtualizan bien |

## 4. Contenedores frente a máquinas virtuales

| | Contenedor (LXC) | Máquina virtual (KVM) |
|---|---|---|
| Núcleo | Comparte el del anfitrión | Tiene el suyo |
| Sistema invitado | Solo Linux, con el núcleo del anfitrión | Cualquiera (Linux, Windows...) |
| Arranque | Segundos | Más lento (arranca un sistema completo) |
| Consumo | Muy bajo (decenas de MB de RAM, disco pequeño) | Mayor (RAM reservada y disco completo) |
| Aislamiento | Menor | Mayor |

**Cuándo usar cada uno:** un contenedor para servicios Linux ligeros y numerosos (DNS, servidor web, base de datos pequeña), donde importa ahorrar recursos y arrancar rápido. Una máquina virtual cuando se necesita otro sistema operativo (por ejemplo, Windows Server), un núcleo distinto o un aislamiento fuerte por seguridad. Por esto, en este laboratorio Windows Server 2025 es una VM y los servicios Linux ligeros podrían ser contenedores.

## 5. Qué se copia al servidor de copias y qué no

| Se copia | Motivo |
|---|---|
| Configuración de red de cada nodo (`/etc/network/interfaces`, `/etc/hosts`) | Pequeña y necesaria para reconstruir un nodo |
| Configuración del clúster (base `config.db` de `/var/lib/pve-cluster/`, que es el origen de `/etc/pve`) | Contiene la definición del clúster, VM y contenedores |
| Copias (`vzdump`) de las VM y contenedores de prueba, que son pequeños | Permiten restaurarlos en otro nodo |

| No se copia | Motivo |
|---|---|
| La imagen completa de cada nodo (discos de 40-64 GB) | Se reinstala desde la ISO y se reconfigura con lo anterior |
| Contraseñas y claves privadas del clúster | Los secretos no deben almacenarse sin cifrar; se custodian fuera del repositorio |
| Discos grandes de VM de usuario sin valor | Ocupan espacio de TrueNAS sin aportar |

## 6. Instalación de los tres nodos (17/11/2026)

| Dato | pve1 | pve2 | pve3 |
|---|---|---|---|
| Versión | Proxmox VE 9.2.2 (`pve-manager/9.2.2`, kernel `7.0.2-6-pve`) | igual | igual |
| Sistema de ficheros | ext4 | ext4 | ext4 |
| Usuario de administración | `root` (`root@pam` en la web) | igual | igual |
| Hostname | `pve1.asir.lab` | `pve2.asir.lab` | `pve3.asir.lab` |
| Red de gestión y clúster (`vmbr0`, sobre `nic0`, adaptador 1 `asir_lab`) | `192.168.34.32/24`, gateway `192.168.34.3` | `192.168.34.33/24` | `192.168.34.34/24` |
| Red de administración web desde el anfitrión (adaptador 2, `vboxnet1`) | `192.168.57.32/24` | `192.168.57.33/24` | `192.168.57.34/24` |
| Recursos de la VM | 3 GB de RAM, 2 CPU, virtualización anidada activada | igual | igual |
| Disco | 32 GiB | 20 GB | 20 GB |
| Zona horaria y teclado | Europe/Madrid, `es` | igual | igual |

Decisiones y observaciones:

- **Dos adaptadores por nodo.** El adaptador 1 está en la red interna `asir_lab` y lleva la gestión y el tráfico del clúster por `vmbr0`. El adaptador 2 está en la red host-only `vboxnet1` y solo sirve para abrir la web (`https://192.168.57.3x:8006`) desde el anfitrión, que no pertenece a `asir_lab`. Sin gateway: la salida a Internet, si hace falta, va por `vmbr0`.
- **Nombre de la segunda interfaz.** Proxmox fija los nombres durante la instalación (`nic0`, `nic1`). En `pve1` la segunda interfaz se mostró como `enp0s8` en el portátil y como `nic1` en el PC, por lo que se comprueba con `ip -br link` antes de escribir `/etc/network/interfaces`.
- **Reinicio tras añadir la interfaz.** En `pve1`, la web no respondía desde el anfitrión hasta reiniciar el nodo, aunque `ping` funcionaba y `pveproxy` escuchaba en el 8006.
- **Sin acceso a Internet.** Los nodos no tienen adaptador NAT, así que la tarea de "Update package database" falla (`apt-get update`, visible en `pve3`). No afecta al laboratorio.
- **Tamaño de disco.** `pve1` tiene 32 GiB y `pve2`/`pve3` 20 GB; el almacenamiento tiene el mismo nombre (`local` y `local-lvm`) en los tres, que es lo necesario para migrar.
- **Aviso de licencia.** Se usa el repositorio sin suscripción; la web muestra el aviso de "No valid subscription", sin consecuencias para el laboratorio.

Evidencias (`05-instalacion-comunicaciones/evidencies/`):

- `2026-11-17-proxmox-pve1-consola-version-red.png`, `2026-11-17-proxmox-pve2-consola-version-red.png`, `2026-11-17-proxmox-pve3-consola-version-red.png`: versión (`pveversion`) y direcciones (`ip -br a`).
- `2026-11-17-proxmox-pve1-web-panel.png`, `2026-11-17-proxmox-pve2-web-panel.png`, `2026-11-17-proxmox-pve3-web-panel.png`: panel web de cada nodo con el usuario `root@pam`.

## 7. Clúster (17/11/2026)

El clúster se crea desde la web de `pve1` (Centro de datos → Cluster → Crear cluster) con el nombre `asirlab`, usando como *Link 0* la dirección `192.168.34.32` (red interna `asir_lab`) y no la de la red host-only, para que el tráfico del clúster (Corosync) no dependa de la red de administración. `pve2` y `pve3` se unen con la información de unión y la contraseña de `root` de `pve1`, cada uno con su propia dirección `192.168.34.x` como *Link 0*.

Resultado de `pvecm status` (ejecutado en `pve3`):

| Dato | Valor |
|---|---|
| Nombre | `asirlab` |
| Transporte | `knet`, con autenticación segura |
| Nodos | 3 (`pve1` id 1, `pve2` id 2, `pve3` id 3) |
| Votos esperados / totales / quórum | 3 / 3 / 2 |
| Estado | `Quorate: Yes` |

Con tres votos y quórum de 2, el clúster sigue funcionando si cae un nodo. Con dos nodos no sería posible sin un dispositivo de quórum externo.

Evidencias (`05-instalacion-comunicaciones/evidencies/`): `2026-11-17-proxmox-cluster-creacion.png` (tarea "Crear cluster" terminada en `TASK OK`) y `2026-11-17-proxmox-pvecm-status-quorum.png` (`pvecm status` y `pvecm nodes`).

## 8. Contenedor de prueba y migración (17/11/2026)

**Contenedor.** `ct-prueba` (ID 100) en `pve1`: plantilla `debian-13-standard_13.6-1_amd64.tar.zst` (subida desde el anfitrión, porque los nodos no tienen Internet), sin privilegios, 1 núcleo, 256 MB de RAM y 256 MB de swap, disco de 2 GB en `local-lvm` (LVM-thin) y red `192.168.34.41/24` por `vmbr0` con gateway `192.168.34.3`. Tras arrancar usaba 571 MB de disco (32 %) y 18 MB de RAM.

**Migración `pve1` → `pve2`** (modo reinicio: Proxmox para el contenedor, copia el disco y lo arranca en el nodo de destino, porque el almacenamiento es local en cada nodo).

| Medida | Resultado |
|---|---|
| Duración total de la migración | 37 s (`duration 00:00:37`) |
| Datos copiados por la red | 2,0 GiB (2 147 483 648 bytes), a unos 83 MB/s (25,9 s) |
| Espacio realmente ocupado en el disco del contenedor | 571 MB (32 %) antes y después |
| Volumen lógico `vm-100-disk-0` en `pve1` (antes) | 2,00 GB, `Data%` 32,40 |
| Volumen lógico `vm-100-disk-0` en `pve2` (después) | 2,00 GB, `Data%` 29,02 |
| Volumen en el nodo de origen | Eliminado al terminar (`successfully removed`) |
| Dirección IP tras migrar | La misma, `192.168.34.41/24` |

Observaciones:

- La migración copia el volumen **completo asignado** (2 GiB), no solo los 571 MB usados. En el destino el volumen ocupa algo menos porque es de aprovisionamiento ligero (`thin`) y se omiten bloques a cero (`Data%` 29,02 frente a 32,40). Dimensionar el disco del contenedor al tamaño que necesita reduce el tiempo de migración.
- El contenedor está parado durante la mayor parte de los 37 s (modo reinicio). Una migración en caliente sin parada solo es posible con almacenamiento compartido (por ejemplo, el servidor TrueNAS por NFS), que no se ha montado en este laboratorio.
- Los nodos tienen 3 GB de RAM y 20-32 GB de disco, de modo que los tiempos medidos no son los de servidores reales.

Evidencias (`05-instalacion-comunicaciones/evidencies/`): `2026-11-17-proxmox-ct100-resumen-creacion.png`, `2026-11-17-proxmox-ct100-tarea-creada.png`, `2026-11-17-proxmox-ct100-consola-antes-migrar.png` y las cuatro de la migración (`2026-11-17-proxmox-ct100-migracion-1-lvs-pve1-antes.png`, `-2-tarea.png`, `-3-lvs-pve2-despues.png`, `-4-consola-pve2.png`).

## 9. Pendiente de realizar

| Paso | Estado |
|---|---|
| Instalar Proxmox VE en los tres nodos (versión, usuario `root`, red) | ✅ |
| Crear el clúster y comprobar el quórum | ✅ |
| Crear una VM Debian sin entorno gráfico y un contenedor | 🟡 Contenedor creado; falta la VM |
| Migrar el contenedor y la VM entre nodos; medir tiempo y espacio en disco; valorar mejoras | 🟡 Contenedor migrado y medido; falta la VM |
| Copiar configuraciones al servidor de copias | ⬜ |

**Limitación esperada:** los nodos son VM de VirtualBox; sin virtualización anidada, la VM de prueba se ejecutará sin aceleración (KVM desactivado en sus opciones), más lenta. Los tiempos medidos no serán los de un servidor real y así se hará constar.
