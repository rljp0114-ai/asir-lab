# TrueNAS: servidor de copias

Servidor de copias de seguridad del laboratorio. El procedimiento paso a paso con comandos está en [`../../evidencies/Comandos.md`](../../evidencies/Comandos.md), apartado 5.

## 1. Sistema

| Elemento | Valor |
|---|---|
| Sistema | TrueNAS 13.0-U5.3 (CORE) |
| Imagen | `TrueNAS-13.0-U5.3.iso`, huella SHA256 verificada ([`../../00-entorno-pruebas/05-isos.md`](../../00-entorno-pruebas/05-isos.md)) |
| Discos | Disco 1 del sistema; disco 2 adicional solo para copias |
| Pool y dataset | Pool `NAS_DATA`, dataset `copias_seguridad` (`/mnt/NAS_DATA/copias_seguridad`) |
| Redundancia del pool | Ninguna: un único disco virtual |
| Usuario de administración | `root` (web) |
| Usuario de copias | `nasbackup`, propietario del dataset |
| Acceso | SMB (445/TCP) y SFTP |

## 2. Red

| Adaptador | Red | Dirección |
|---|---|---|
| Interno | `asir_lab` | `192.168.34.20/24` |
| Gestión | host-only | Acceso web desde el anfitrión |

## 3. Qué es una copia, cómo y dónde

- **Qué:** ficheros de configuración de cada sistema (red, usuarios, reglas, clúster), no los discos de las VM.
- **Cómo:** `scp`/SFTP o montaje SMB desde cada sistema, a una carpeta por equipo.
- **Dónde:** un disco distinto del de arranque del NAS, para que las copias no dependan de él.
- **Límite:** sin redundancia en el pool, es una copia fuera del equipo origen, no una copia protegida contra el fallo del disco del NAS.

Carpetas actuales en `copias_seguridad`: `debian`, `linux`, `linux-datos`, `linux-servicios`, `mikrotik`, `opnsense`, `ubuntu`, `windows`, y el paquete de configuración de `pve1`.

## 4. Pendiente

- Captura del disco adicional y del pool en la interfaz de TrueNAS.
- Captura de la versión instalada.
- Zona horaria en `Europe/Madrid` (ahora en hora del Pacífico).
