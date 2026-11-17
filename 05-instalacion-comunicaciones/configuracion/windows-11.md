# Windows 11 (cliente)

## 1. Objetivo

Instalar Windows 11 como cliente Windows del laboratorio, configurar su usuario de administración y su red, y comprobar su versión y su funcionamiento en la LAN `asir_lab` (tarea 5, clientes).

## 2. Máquina virtual

| Característica | Valor |
|---|---|
| VM | `Windows11 Cliente` (VirtualBox 7.0.20, PC doméstico; distinta de la `W11` de otra actividad) |
| Imagen | `w11.iso`, de la página de recursos del centro (ver `00-entorno-pruebas/05-isos.md`; su huella no coincidió con la consultada en Microsoft) |
| Edición | Windows 11 Home |
| Recursos | 4 GB de RAM (`memory=4096`), 2 vCPU (`cpus=2`) y disco VDI de 80 GB (`VBoxManage list hdds`: 81920 MB, sin cifrar), en `/home/batoi/VirtualBox VMs/ISOFHW/Windows11 Cliente/` |
| Firmware | EFI (`firmware="EFI"`); el TPM no aparece en la salida consultada |
| Red | Adaptador 2 en red interna `asir_lab` (`nic2="intnet"`); adaptador 1 y los demás sin conectar (`none`), sin NAT |
| Instalación | Sin conexión a Internet, con usuario local |

## 3. Versión

| Dato | Valor | Fuente |
|---|---|---|
| Sistema | Windows 11 Home | `winver` y `Win32_OperatingSystem.Caption` |
| Versión | 23H2 | `winver` |
| Compilación | 22631.2861 | `winver` |

`Get-ComputerInfo` muestra `WindowsProductName: Windows 10 Home` con `OsBuildNumber: 22631`. Es una particularidad conocida: Windows 11 conserva en el registro el nombre "Windows 10"; la compilación 22631 corresponde a Windows 11 23H2, y `winver` y `Win32_OperatingSystem` confirman que es Windows 11.

La compilación `22631.2861` es anterior a las actualizaciones más recientes porque el sistema se instaló sin Internet y no se ha actualizado.

Evidencias:
- `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-winver.png`
- `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-version-usuarios.png`

## 4. Usuario de administración

| Cuenta | Estado | Grupo `Administradores` |
|---|---|---|
| `Windows-Cliente` | Habilitada | Sí |
| `Administrador` (integrada) | Deshabilitada | Sí (deshabilitada) |
| `Invitado`, `DefaultAccount`, `WDAGUtilityAccount` | Deshabilitadas | No |

El usuario de administración es la cuenta local `Windows-Cliente`, creada durante la instalación (sin cuenta de Microsoft). La cuenta `Administrador` integrada queda deshabilitada, que es el estado recomendado. El nombre de equipo es el generado por Windows (`DESKTOP-0QFI0TG`).

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-version-usuarios.png` (`Get-LocalUser` y `Get-LocalGroupMember`, 18:52:29 del 16/11/2026).

## 5. Configuración de red

| Parámetro | Valor |
|---|---|
| Adaptador | `Ethernet` (Intel PRO/1000 MT Desktop) |
| Dirección IPv4 | `192.168.34.100/24`, estática |
| Puerta de enlace | `192.168.34.3` (MikroTik, router activo) |
| DNS | `8.8.8.8` y `1.1.1.1` |

La dirección es estática porque el laboratorio no tiene servidor DHCP; el rango `.100-.200` previsto para los puestos de trabajo se mantiene como diseño.

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-configuracion-red.png` (`Get-NetIPConfiguration`, 18:39 del 16/11/2026).

## 6. Pruebas de funcionamiento

Con MikroTik y TrueNAS encendidos:

| Prueba | Resultado | Origen | Qué demuestra |
|---|---|---|---|
| `Test-NetConnection 192.168.34.3` | `PingSucceeded: True` (0 ms) | `192.168.34.100`, `Ethernet` | Comunicación con la puerta de enlace |
| `Test-NetConnection 192.168.34.20` | `PingSucceeded: True` (1 ms) | `192.168.34.100`, `Ethernet` | Comunicación con TrueNAS |
| `Test-NetConnection 1.1.1.1 -Port 443` | `TcpTestSucceeded: True` | `192.168.34.100`, `Ethernet` | Salida a Internet por TCP a través de MikroTik |

Evidencias: `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-prueba-mikrotik.png`, `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-prueba-truenas.png` y `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-prueba-tcp443-internet.png`. La salida a Internet se prueba con TCP y no con ping (ver `incidencias/incidencias.md`).

## 7. Copia al servidor de copias

Se copió a TrueNAS (`192.168.34.20`) el fichero `config-red-win11.txt`, que contiene la salida de `ipconfig /all` y de `Get-LocalUser`:

```powershell
ipconfig /all > $env:USERPROFILE\config-red-win11.txt
Get-LocalUser | Out-File -Append $env:USERPROFILE\config-red-win11.txt
sftp nasbackup@192.168.34.20
sftp> mkdir /mnt/NAS_DATA/copias_seguridad/windows
sftp> put C:/Users/Windows-Cliente/config-red-win11.txt /mnt/NAS_DATA/copias_seguridad/windows/
sftp> ls /mnt/NAS_DATA/copias_seguridad/windows
```

- Usuario: `nasbackup`. Es la primera conexión desde este equipo, por lo que SFTP pidió aceptar la huella del servidor (ED25519) y la guardó como conocida.
- Resultado: transferencia al 100 % (3810 bytes, 18:55 del 16/11/2026). El `mkdir` no dio error y el `ls` confirma el fichero en `/mnt/NAS_DATA/copias_seguridad/windows/config-red-win11.txt`.

Evidencia: `05-instalacion-comunicaciones/evidencies/2026-11-16-windows11-copia-sftp-truenas.png`.

### Qué se copia y qué no

| Elemento | ¿Se copia? | Motivo |
|---|---|---|
| Configuración de red (IP, puerta de enlace, DNS) y lista de usuarios | Sí | Es pequeña y es lo único que no se deduce de la ISO; permite reconstruir la configuración de la VM |
| Imagen del disco de la VM (80 GB) | No | Ocupa mucho espacio en TrueNAS y la VM se puede reinstalar desde la ISO y reconfigurar con el fichero anterior en pocos minutos |
| Contraseñas | No | `Get-LocalUser` no las incluye; no deben guardarse en ficheros de texto |

La copia es manual; no hay tarea programada para Windows 11.

## 8. Pendiente

- Integración en dominio: no se hace. La rúbrica la exige solo si el diseño la prevé, y en este diseño no se instala el controlador de dominio (ver `windows-server-2025.md`, apartado 9).
- Prueba de recuperación (borrar la configuración y restaurarla desde la copia): no realizada.
