# Windows Server 2025

## 1. Objetivo

Instalar Windows Server 2025 como servidor Windows del laboratorio y comprobar su versión y su funcionamiento en la red `asir_lab` (tarea 5, centralización).

## 2. Máquina virtual

| Característica | Valor |
|---|---|
| VM | `Windows Server 2025` (VirtualBox 7.0.20, PC doméstico) |
| Imagen | `win_server_2025.iso`, de la página de recursos del centro (ver `00-entorno-pruebas/05-isos.md`; huella en `00-entorno-pruebas/05-isos.md`; Microsoft no publica la huella de la versión de evaluación) |
| Edición | Windows Server 2025 Standard Evaluation, con experiencia de escritorio |
| vCPU y RAM | 2 vCPU y 4 GB (comprobado con `VBoxManage showvminfo`: `cpus=2`, `memory=4096`) |
| Disco | 50 GB (`VBoxManage list hdds`: formato VDI, capacidad 51200 MB, sin cifrar), en `/home/batoi/VirtualBox VMs/ISOFHW/Windows Server 2025/` |
| Red | Adaptador 1: NAT (`nic1="nat"`); adaptador 2: red interna `asir_lab` (`nic2="intnet"`) |
| Usuario | `Administrador` (cuenta local de administración) |

**Elección de la edición.** Se instala Standard con experiencia de escritorio: cubre las necesidades de este laboratorio, Datacenter solo añade funciones para grandes centros de datos, y la interfaz gráfica facilita documentar con capturas. Server Core consumiría menos RAM y disco (aproximadamente la mitad en reposo); podría probarse como ampliación para la medición de recursos de la tarea 7.

## 3. Versión

| Dato | Valor |
|---|---|
| Producto | Windows Server 2025 Standard Evaluation |
| Versión | 24H2 (`WindowsVersion` 2009) |
| Compilación | 26100.1742 |

Evidencias:
- `05-instalacion-comunicaciones/evidencies/2026-11-16-winserver2025-winver.png` (`winver`)
- `05-instalacion-comunicaciones/evidencies/2026-11-16-winserver2025-get-computerinfo.png` (`Get-ComputerInfo`)

## 4. Configuración de red

| Parámetro | Valor |
|---|---|
| Adaptador | `Ethernet` (Intel PRO/1000 MT Desktop) |
| Dirección IPv4 | `192.168.34.21/24`, estática |
| Puerta de enlace | `192.168.34.3` (MikroTik, router activo en esta prueba) |
| DNS | `8.8.8.8` y `1.1.1.1` |

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-winserver2025-configuracion-red.png` (`Get-NetIPConfiguration`, 17:28:42 del 16/11/2026).

## 5. Pruebas de funcionamiento

Montaje: MikroTik, `Windows Server 2025` y TrueNAS encendidos; OPNsense, Ubuntu y Debian apagados. La regla de bloqueo de MikroTik estaba deshabilitada.

| Prueba | Resultado | Origen | Qué demuestra |
|---|---|---|---|
| `Test-NetConnection 192.168.34.3` | `PingSucceeded: True` (0 ms) | `192.168.34.21`, `Ethernet` | Comunicación con la puerta de enlace |
| `Test-NetConnection 192.168.34.20` | `PingSucceeded: True` (1 ms) | `192.168.34.21`, `Ethernet` | Comunicación con TrueNAS |
| `Test-NetConnection 1.1.1.1 -Port 443` | `TcpTestSucceeded: True` | `192.168.34.21`, `Ethernet` | Salida a Internet por TCP a través de MikroTik |

Evidencias: `05-instalacion-comunicaciones/evidencies/2026-11-16-winserver2025-pruebas-mikrotik-truenas.png` y `05-instalacion-comunicaciones/evidencies/2026-11-16-winserver2025-prueba-tcp443-internet.png`.

La salida a Internet se prueba con TCP y no con ping, como en el resto del laboratorio (ver `incidencias/incidencias.md`).

## 6. Incidencia durante la prueba

La VM tenía un segundo adaptador (`Ethernet 2`, NAT de VirtualBox, `10.0.2.15`) además del de la LAN. En la primera tanda de pruebas, las conexiones salían por ese adaptador y no por `Ethernet`: la prueba a TrueNAS falló (con TrueNAS además apagado) y la de `1.1.1.1:443` funcionó por la NAT sin pasar por MikroTik, por lo que no demostraba nada sobre el router. Se desactivó con `Disable-NetAdapter -Name "Ethernet 2" -Confirm:$false`, se encendió TrueNAS y se repitieron las pruebas; en las de la tabla anterior el origen es `192.168.34.21`.

El adaptador NAT es el adaptador 1 de la VM en VirtualBox (el de la LAN es el 2).

## 7. Por qué no va en un nodo Proxmox

Windows Server 2025 se ejecuta como VM independiente de VirtualBox y no dentro de los nodos Proxmox porque los recursos son limitados: los tres nodos reservan 12 GB de RAM solo para ellos, con una doble capa de virtualización, y el anfitrión tiene 16 GB (ver `00-entorno-pruebas/04-entorn-virtualitzacio.md`, apartado 8).

## 8. Copia al servidor de copias

Se copió a TrueNAS (`192.168.34.20`) el fichero `config-red-winserver.txt` (guardado en TrueNAS, no en el repositorio; salida de `ipconfig /all` y de `Get-LocalUser`), en la misma carpeta que la configuración del cliente Windows 11:

```powershell
ipconfig /all > $env:USERPROFILE\config-red-winserver.txt
Get-LocalUser | Out-File -Append $env:USERPROFILE\config-red-winserver.txt
sftp nasbackup@192.168.34.20
sftp> put C:/Users/Administrador/config-red-winserver.txt /mnt/NAS_DATA/copias_seguridad/windows/
sftp> ls /mnt/NAS_DATA/copias_seguridad/windows
```

- Usuario: `nasbackup`. Primera conexión desde este equipo: SFTP pidió aceptar la huella ED25519 del servidor, la misma que vio el cliente Windows 11, lo que confirma que es el mismo servidor.
- Resultado: transferencia al 100 % (3830 bytes, 19:01 del 16/11/2026). El `ls` lista `config-red-win11.txt` y `config-red-winserver.txt` en `/mnt/NAS_DATA/copias_seguridad/windows/`.

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-winserver2025-copia-sftp-truenas.png`.

### Qué se copia y qué no

| Elemento | ¿Se copia? | Motivo |
|---|---|---|
| Configuración de red y lista de usuarios | Sí | Pequeña, y es lo que no se deduce de la ISO |
| Imagen del disco de la VM (50 GB) | No | Ocupa mucho espacio en TrueNAS y la VM se reinstala desde la ISO y se reconfigura con el fichero |
| Contraseñas | No | `Get-LocalUser` no las incluye; no deben guardarse en texto |

La copia es manual; no hay tarea programada.

## 9. Qué es un dominio y qué aporta a la empresa

Un **dominio** (en Windows, un dominio de Active Directory) es un conjunto de equipos, usuarios y recursos que comparten una base de datos de seguridad común, gestionada por uno o varios servidores llamados controladores de dominio. En lugar de tener cuentas en cada ordenador, las cuentas existen una sola vez en el servidor y todos los equipos del dominio las reconocen.

**Ventajas de centralizar la gestión a nivel administrativo:**
- **Una sola cuenta por persona**, válida en cualquier equipo del dominio. Dar de alta o de baja a un empleado se hace en un único sitio.
- **Directivas de grupo (GPO):** el administrador define desde el servidor reglas que se aplican a muchos equipos (por ejemplo, requisitos de contraseña, fondos de pantalla, restricciones de software o unidades de red) sin tocar cada equipo.
- **Permisos por grupos:** el acceso a carpetas, impresoras y aplicaciones se asigna a grupos (administración, ventas, dirección) y no usuario por usuario.
- **Seguridad y control:** contraseñas, bloqueos de cuenta y auditoría se gestionan y registran de forma centralizada.
- **Menos trabajo y menos errores** al crecer la empresa: un equipo nuevo se une al dominio y adopta la configuración y los permisos que le correspondan.

**Qué aporta a nuestra empresa:** el laboratorio simula una empresa pequeña con varios puestos (Windows 11 y GNU/Linux). Con un dominio, el servidor Windows Server 2025 serviría para gestionar de forma única los usuarios y los permisos de esos puestos y aplicar la misma configuración de seguridad a todos.

**Decisión de diseño:** en esta fase no se instala el rol de controlador de dominio (Active Directory Domain Services) ni se une ningún cliente al dominio. La rúbrica lo exige solo para explicar el concepto, y la integración de los clientes solo procede si el diseño lo prevé. Por tanto, Windows Server 2025 queda instalado, configurado en red y con su copia de seguridad, y la integración de dominio se deja como mejora posible.
