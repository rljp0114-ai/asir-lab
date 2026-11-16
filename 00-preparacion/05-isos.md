# 05. Imágenes ISO utilizadas

Registro de las imágenes ISO del laboratorio con su tamaño y su huella SHA256, calculados en el equipo donde se guardan (comando `sha256sum`, 16/11/2026). La huella permite comprobar más adelante que el fichero no se ha corrompido ni modificado.

## 1. Inventario

| Fichero | Sistema | Uso en el laboratorio | Tamaño (bytes) | Tamaño | Fecha del fichero | Estado |
|---|---|---|---:|---:|---|---|
| `debian-13.1.0-amd64-netinst(1).iso` | Debian 13.1 (netinst) | Debian Server: cliente de pruebas y base de servidores Linux | 821 035 008 | 0.76 GiB | 2026-09-22 | Usada |
| `mikrotik-7.24.5.iso` | MikroTik RouterOS 7.24.5 | Router MikroTik | 71 475 200 | 0.07 GiB | 2026-11-03 | Usada |
| `OPNsense-26.7-dvd-amd64.iso` | OPNsense 26.7 (DVD, amd64) | Router y firewall OPNsense | 2 101 714 944 | 1.96 GiB | 2026-11-05 | Usada |
| `proxmox-ve_9.2-1.iso` | Proxmox VE 9.2-1 | Nodos Proxmox (diseño; sin despliegue) | 1 706 178 560 | 1.59 GiB | 2026-10-21 | VM creadas; instalación no completada |
| `TrueNAS-13.0-U5.3.iso` | TrueNAS 13.0-U5.3 | Servidor de copias | 1 047 345 152 | 0.98 GiB | 2026-10-21 | Usada |
| `ubuntu-26.04-live-server-amd64.iso` | Ubuntu Server 26.04 | Router con nftables | 2 918 598 656 | 2.72 GiB | 2026-10-21 | Usada |
| `w11.iso` | Windows 11 | Cliente Windows 11 | 6 807 373 824 | 6.34 GiB | 2026-09-22 | Pendiente de usar en el laboratorio |
| `win_server_2025.iso` | Windows Server 2025 | Servidor Windows | 6 019 420 160 | 5.61 GiB | 2026-10-13 | Pendiente de instalar |

## 2. Huellas SHA256

- `debian-13.1.0-amd64-netinst(1).iso`
  `658b28e209b578fe788ec5867deebae57b6aac5fce3692bbb116bab9c65568b3`
- `mikrotik-7.24.5.iso`
  `4bff16b8ee455eb00a0a5f183936fb0ecfd8f2bf3f5ba1ba64773d8375aaec02`
- `OPNsense-26.7-dvd-amd64.iso`
  `1efd5dc9fa12a1f93571183fe5e3823e22e332872de8417fafb5e4e4d48d5dcd`
- `proxmox-ve_9.2-1.iso`
  `4e88fe416df9b527624a175f24c9aa07c714d3332afb1ee3dbf3879573ef2c6c`
- `TrueNAS-13.0-U5.3.iso`
  `7c16a4f59a3081b55682e5dd9183e80fa7defd59129ac280d5ff213af4bb4c80`
- `ubuntu-26.04-live-server-amd64.iso`
  `dec49008a71f6098d0bcfc822021f4d042d5f2db279e4d75bdd981304f1ca5d9`
- `w11.iso`
  `5210deedb54d373dccbf4a164be9d8a010ef867af4fc66856443450e89119dc8`
- `win_server_2025.iso`
  `b73c9688a4b8d165cadc8bf9a52d86d6483b397801b791ffd5e7d1be6cbd5d56`

## 3. Comprobación contra la huella oficial

Estado: **Debian, Ubuntu, Proxmox y TrueNAS verificadas el 16/11/2026**; OPNsense, MikroTik y Windows, pendientes. La huella oficial se obtuvo con `curl` del fichero `SHA256SUMS` del proveedor y se comparó con la calculada en el equipo (la cadena completa de 64 caracteres es idéntica). Para las demás solo se ha registrado la huella calculada, que sirve para detectar cambios posteriores del fichero.

| Sistema | Huella oficial | Resultado |
|---|---|---|
| Debian 13.1 | `658b28e2...65568b3` (`cdimage.debian.org/cdimage/archive/13.1.0/amd64/iso-cd/SHA256SUMS`, línea de `debian-13.1.0-amd64-netinst.iso`) | **Coincide** |
| Ubuntu Server 26.04 | `dec49008...1ca5d9` (`releases.ubuntu.com/26.04/SHA256SUMS`, línea de `ubuntu-26.04-live-server-amd64.iso`) | **Coincide** |
| Proxmox VE 9.2-1 | `4e88fe41...ef2c6c` (`enterprise.proxmox.com/iso/SHA256SUMS`, línea de `proxmox-ve_9.2-1.iso`, no la de `arm64`) | **Coincide** |
| OPNsense 26.7 | `95cafedd...86bfb`, pero es la del fichero comprimido `OPNsense-26.7-dvd-amd64.iso.bz2` (`pkg.opnsense.org/releases/26.7/OPNsense-26.7-checksums-amd64.sha256`) | **No comparable**: la huella calculada (`1efd5dc9...5d48d5dcd`) es la del `.iso` descomprimido. Para verificarla habría que volver a descargar el `.bz2`, comprobar su huella y descomprimirlo |
| TrueNAS 13.0-U5.3 | `7c16a4f5...bb4c80` (`download.freenas.org/13.0/STABLE/U5.3/x64/TrueNAS-13.0-U5.3.iso.sha256`) | **Coincide** |
| MikroTik 7.24.5 | No encontrada: `download.mikrotik.com/routeros/7.24.5/CHECKSUMS.txt` no devolvió ninguna línea de ISO | Pendiente |
| Windows 11 y Windows Server 2025 | Microsoft no suele publicar la huella de las imágenes de evaluación; si no existe, se deja anotado | Pendiente |

## 4. Observaciones

- La ISO de Debian se llama `debian-13.1.0-amd64-netinst(1).iso`: el `(1)` indica una descarga repetida del navegador. Su huella coincide con la oficial de `debian-13.1.0-amd64-netinst.iso`, así que el nombre es solo cosmético.
- Ubuntu ya publica la versión 26.04.1 (`ubuntu-26.04.1-live-server-amd64.iso`). La ISO utilizada es la 26.04 inicial, verificada contra su propia línea del fichero oficial.
- La fecha del fichero es la de su última modificación en el disco, que normalmente coincide con la descarga pero no lo garantiza.
- TrueNAS 13.0 corresponde a TrueNAS CORE (basado en FreeBSD).
- Windows 11 y Windows Server 2025 son ISO de gran tamaño (6,3 GiB y 5,6 GiB); hay que tenerlo en cuenta en el espacio libre del anfitrión que las use.
