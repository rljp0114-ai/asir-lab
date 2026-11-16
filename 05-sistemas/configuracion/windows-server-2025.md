# Windows Server 2025

## 1. Objetivo

Instalar Windows Server 2025 como servidor Windows del laboratorio y comprobar su versión y su funcionamiento en la red `asir_lab` (tarea 5, centralización).

## 2. Máquina virtual

| Característica | Valor |
|---|---|
| VM | `Windows Server 2025` (VirtualBox 7.0.20, PC doméstico) |
| Imagen | `win_server_2025.iso`, de la página de recursos del centro (ver `00-preparacion/05-isos.md`; huella en `00-preparacion/05-isos.md`; Microsoft no publica la huella de la versión de evaluación) |
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
- `evidencies/2026-11-16-winserver2025-winver.png` (`winver`)
- `evidencies/2026-11-16-winserver2025-get-computerinfo.png` (`Get-ComputerInfo`)

## 4. Configuración de red

| Parámetro | Valor |
|---|---|
| Adaptador | `Ethernet` (Intel PRO/1000 MT Desktop) |
| Dirección IPv4 | `192.168.34.21/24`, estática |
| Puerta de enlace | `192.168.34.3` (MikroTik, router activo en esta prueba) |
| DNS | `8.8.8.8` y `1.1.1.1` |

Evidencia: `evidencies/2026-11-16-winserver2025-configuracion-red.png` (`Get-NetIPConfiguration`, 17:28:42 del 16/11/2026).

## 5. Pruebas de funcionamiento

Montaje: MikroTik, `Windows Server 2025` y TrueNAS encendidos; OPNsense, Ubuntu y Debian apagados. La regla de bloqueo de MikroTik estaba deshabilitada.

| Prueba | Resultado | Origen | Qué demuestra |
|---|---|---|---|
| `Test-NetConnection 192.168.34.3` | `PingSucceeded: True` (0 ms) | `192.168.34.21`, `Ethernet` | Comunicación con la puerta de enlace |
| `Test-NetConnection 192.168.34.20` | `PingSucceeded: True` (1 ms) | `192.168.34.21`, `Ethernet` | Comunicación con TrueNAS |
| `Test-NetConnection 1.1.1.1 -Port 443` | `TcpTestSucceeded: True` | `192.168.34.21`, `Ethernet` | Salida a Internet por TCP a través de MikroTik |

Evidencias: `evidencies/2026-11-16-winserver2025-pruebas-mikrotik-truenas.png` y `evidencies/2026-11-16-winserver2025-prueba-tcp443-internet.png`.

La salida a Internet se prueba con TCP y no con ping, como en el resto del laboratorio (ver `08-incidencias/06-proves-incidencies.md`).

## 6. Incidencia durante la prueba

La VM tenía un segundo adaptador (`Ethernet 2`, NAT de VirtualBox, `10.0.2.15`) además del de la LAN. En la primera tanda de pruebas, las conexiones salían por ese adaptador y no por `Ethernet`: la prueba a TrueNAS falló (con TrueNAS además apagado) y la de `1.1.1.1:443` funcionó por la NAT sin pasar por MikroTik, por lo que no demostraba nada sobre el router. Se desactivó con `Disable-NetAdapter -Name "Ethernet 2" -Confirm:$false`, se encendió TrueNAS y se repitieron las pruebas; en las de la tabla anterior el origen es `192.168.34.21`.

El adaptador NAT es el adaptador 1 de la VM en VirtualBox (el de la LAN es el 2). Pendiente: desactivarlo allí (`Configuración → Red → Adaptador 1`) para que no vuelva a activarse.

## 7. Por qué no va en un nodo Proxmox

Windows Server 2025 se ejecuta como VM independiente de VirtualBox y no dentro de los nodos Proxmox porque los recursos son limitados: los tres nodos reservan 12 GB de RAM solo para ellos, con una doble capa de virtualización, y el anfitrión tiene 16 GB (ver `00-preparacion/04-entorn-virtualitzacio.md`, apartado 8).

## 8. Pendiente

- Cambiar el nombre del equipo (ahora tiene uno aleatorio).
- Usar la VM en las pruebas de la tarea 5 que dependan de ella (por ejemplo, copia de seguridad hacia TrueNAS) y en la medición de recursos (tarea 7).
