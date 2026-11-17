# RAID con mdadm (tarea 6, punto 2)

## 1. Objetivo

Crear tres tipos de RAID en uno de los equipos, comprobar que funcionan y explicar qué se gana con cada uno. Se usan discos virtuales y datos ficticios, como pide el enunciado.

## 2. Montaje

| Elemento | Valor |
|---|---|
| Equipo | VM `Linux-Datos` (Debian 13), en el PC doméstico |
| Herramienta | `mdadm` 4.4 (2024-11-07, paquete de Debian) |
| Discos | Siete discos virtuales VDI de 1 GB (`raid1.vdi` a `raid7.vdi`), conectados a los puertos 1 a 7 del controlador SATA; se ven como `sdb` a `sdh` |
| Disco del sistema | `sda`, 20 GB |

Los discos se crearon con `VBoxManage createmedium disk --size 1024 --format VDI` y se conectaron con `VBoxManage storageattach` con la VM apagada (VirtualBox no permite añadir puertos al controlador SATA con la VM en marcha). Son discos de tamaño dinámico: al principio cada fichero ocupa unos 2 MB.

Evidencia: `evidencies/2026-11-17-raid-discos-lsblk.png` (`lsblk`: `sda` y siete discos de 1 GB).

## 3. Creación

```bash
mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc
mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sdd /dev/sde
mdadm --create /dev/md5 --level=5 --raid-devices=3 /dev/sdf /dev/sdg /dev/sdh
```

| RAID | Dispositivo | Discos | Creado (hora de la VM) |
|---|---|---|---|
| RAID 0 | `/dev/md0` | `sdb`, `sdc` | 08:33:42 |
| RAID 1 | `/dev/md1` | `sdd`, `sde` | 08:34:18 |
| RAID 5 | `/dev/md5` | `sdf`, `sdg`, `sdh` | 08:35:46 |

En RAID 1 y RAID 5, `mdadm` ofreció activar el mapa de bits de escritura (*write-intent bitmap*), que acelera la resincronización tras un fallo; se aceptó. En RAID 1 advirtió de que los metadatos al inicio del disco no sirven para arrancar desde él; no es un problema, porque estos discos son de datos.

Evidencia: `evidencies/2026-11-17-raid-creacion-mdadm.png` (17/11/2026, 08:33).

## 4. Verificación

### Estado

`/proc/mdstat` muestra los tres arrays activos y sin degradar:

| Array | Estado en `/proc/mdstat` |
|---|---|
| `md0` | `active raid0`, 2093056 bloques, chunks de 512k |
| `md1` | `active raid1`, 1046528 bloques, `[2/2] [UU]` |
| `md5` | `active raid5`, 2093056 bloques, `[3/3] [UUU]` |

Evidencia: `evidencies/2026-11-17-raid-mdstat-lsblk.png`.

### Capacidad y datos

Se creó un sistema de ficheros `ext4` en cada uno, se montaron en `/mnt/raid0`, `/mnt/raid1` y `/mnt/raid5`, se escribió un fichero de prueba en cada uno y se leyó de vuelta correctamente.

| RAID | Capacidad bruta (discos) | Capacidad útil (`df -h`) | Aprovechamiento |
|---|---|---|---|
| RAID 0 | 2 GB (2 × 1 GB) | 2,0 GB | 100 % |
| RAID 1 | 2 GB (2 × 1 GB) | 988 MB | 50 % |
| RAID 5 | 3 GB (3 × 1 GB) | 2,0 GB | 66 % |

Evidencia: `evidencies/2026-11-17-raid-mkfs-montaje-datos.png`.

### Detalle de cada array (`mdadm --detail`)

| RAID | Nivel | Discos activos | Estado | Evidencia |
|---|---|---|---|---|
| `md0` | raid0 | 2 de 2 | `clean` | `evidencies/2026-11-17-raid0-mdadm-detail.png` |
| `md1` | raid1 | 2 de 2 | `clean`, 0 fallidos | `evidencies/2026-11-17-raid1-mdadm-detail.png` |
| `md5` | raid5 | 3 de 3 | `clean`, 0 fallidos | `evidencies/2026-11-17-raid5-mdadm-detail.png` |

## 5. Qué se gana con cada tipo

| | RAID 0 (reparto) | RAID 1 (espejo) | RAID 5 (reparto con paridad) |
|---|---|---|---|
| Cómo funciona | Reparte los datos en bandas entre los discos | Guarda una copia idéntica en cada disco | Reparte los datos y una paridad entre todos los discos |
| Discos mínimos | 2 | 2 | 3 |
| Capacidad útil | Suma de todos los discos | La de un solo disco | Todos menos uno |
| Tolerancia a fallos | **Ninguna**: si falla un disco se pierde todo | Soporta el fallo de un disco | Soporta el fallo de un disco |
| Rendimiento | Mejor lectura y escritura (varios discos a la vez) | Lectura similar o mejor; escritura como un disco | Buena lectura; la escritura es más lenta por calcular la paridad |
| Uso adecuado | Datos temporales o de trabajo que se pueden recuperar | Datos críticos pequeños (sistema, configuraciones) | Servidores de ficheros: equilibrio entre capacidad y protección |

**Qué se gana:** con RAID 0, capacidad y velocidad, a cambio de seguridad; con RAID 1, seguridad, a cambio de la mitad de la capacidad; con RAID 5, un compromiso entre ambas, con un coste de escritura y con el riesgo de que un segundo fallo durante la reconstrucción haga perder los datos.

**Limitación del entorno:** los siete discos virtuales son ficheros del mismo SSD físico, así que no hay independencia real de fallos ni la mejora de velocidad de RAID 0 es representativa. Se demuestra el funcionamiento lógico, no el rendimiento real.

## 6. Pendiente

- Prueba de fallo: marcar un disco como fallido en RAID 1 y en RAID 5, comprobar que los datos siguen accesibles (array degradado) y reconstruir con el disco repuesto; mostrar que RAID 0 no admite fallos.
- Persistencia tras reiniciar: los arrays y los montajes no están guardados en `/etc/mdadm/mdadm.conf` ni en `/etc/fstab`; tras reiniciar habría que reensamblarlos y montarlos a mano.
- Punto 3 (Apte+): espejo entre discos de dos equipos distintos.
