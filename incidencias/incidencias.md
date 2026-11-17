# Incidencias del laboratorio

## Ficha de cada incidencia

- **Título breve:**
- **Fecha:**
- **Sistema afectado:**
- **Objetivo:**
- **Síntoma observado:**
- **Mensaje de error o salida exacta:**
- **Comprobaciones realizadas:**
- **Causa identificada:**
- **Solución aplicada:**
- **Verificación posterior:**
- **Evidencia:**
- **Qué se ha aprendido:**

No indicar una causa como definitiva hasta haberla comprobado.

## Incidencias registradas

### 1. El ping a Internet falla a través de MikroTik en la red del aula

- **Título breve:** `ping` a `1.1.1.1` sin respuesta, con conexión al router correcta.
- **Fecha:** 16/11/2026.
- **Sistema afectado:** Debian Server (cliente) y MikroTik (router), con el WAN conectado por adaptador puente a la red del aula.
- **Objetivo:** comprobar que los equipos de la LAN tienen salida a Internet a través de MikroTik.
- **Síntoma observado:** Debian se comunicaba con MikroTik (`192.168.34.3`), pero `ping 1.1.1.1` no recibía respuesta. El ping lanzado desde el propio MikroTik también fallaba.
- **Comprobaciones realizadas:**
  1. Comunicación Debian-MikroTik: correcta.
  2. Ping desde MikroTik hacia el exterior: fallaba; al fallar también desde el router, el fallo no dependía del cliente Debian ni de la LAN.
  3. Prueba de conexión TCP al puerto 443 desde Debian, sin usar ICMP: `timeout 5 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/443' && echo ABIERTO || echo CERRADO`. Resultado: `ABIERTO`.
- **Causa identificada:** la causa más probable es que la red del aula filtra el tráfico ICMP hacia el exterior, pero no se ha confirmado con la administración de la red. Lo que sí se ha comprobado es que el tráfico TCP sale correctamente por MikroTik.
- **Solución aplicada:** no se cambió ninguna configuración. Para probar la salida a Internet en este entorno se utilizan pruebas TCP (y resolución DNS) en lugar de `ping`.
- **Verificación posterior:** la prueba de conexión permitida y bloqueada de MikroTik se hizo con TCP y funcionó (ver `05-instalacion-comunicaciones/configuracion/mikrotik.md`).
- **Evidencia:** `05-instalacion-comunicaciones/evidencies/2026-11-16-debian-prueba-tcp443-bloqueo-mikrotik.png` (la primera línea muestra la conexión TCP al 443 abierta), `05-instalacion-comunicaciones/evidencies/2026-11-16-mikrotik-log-lista-prueba-bloqueo.png` y `05-instalacion-comunicaciones/evidencies/2026-11-16-mikrotik-log-entrada-detalle.png`.
- **Qué se ha aprendido:** un `ping` fallido no demuestra que no haya salida a Internet. Hay que distinguir entre fallo de ICMP y fallo de conectividad probando con otro protocolo, y probar desde el propio router para localizar dónde está el problema.

### 2. Pruebas de red de Windows Server salían por la NAT en lugar de por la LAN

- **Objetivo:** comprobar que Windows Server 2025 (`192.168.34.21`) llega a MikroTik, a TrueNAS y a Internet a través de MikroTik.
- **Síntoma observado:** `Test-NetConnection 192.168.34.20` falló con `DestinationHostUnreachable`, y `Test-NetConnection 1.1.1.1 -Port 443` funcionó.
- **Comprobaciones realizadas:** `ipconfig /all` mostró un segundo adaptador (`Ethernet 2`, `10.0.2.15`, puerta de enlace `10.0.2.2`) además del de la LAN. Las dos pruebas fallidas o dudosas tenían `SourceAddress: 10.0.2.15`, es decir, salían por la NAT de VirtualBox.
- **Causa identificada:** la VM conservaba un adaptador NAT adicional, y TrueNAS estaba apagado en ese momento.
- **Solución aplicada:** desactivar el adaptador con `Disable-NetAdapter -Name "Ethernet 2" -Confirm:$false`, encender TrueNAS y repetir las pruebas.
- **Verificación posterior:** las tres pruebas dieron resultado correcto con `SourceAddress: 192.168.34.21` (ver `05-instalacion-comunicaciones/configuracion/windows-server-2025.md`).
- **Qué se ha aprendido:** con dos adaptadores, una prueba que funciona no demuestra que el tráfico pase por el router. Hay que mirar siempre el `SourceAddress` y el `InterfaceAlias` del resultado.

### 3. La migración en Proxmox falla por una clave SSH vacía en pve1

- **Título breve:** migración abortada por `error in libcrypto`.
- **Fecha:** 17/11/2026.
- **Sistema afectado:** nodo `pve1` del clúster Proxmox `asirlab`.
- **Objetivo:** migrar el contenedor `ct-prueba` de `pve1` a `pve2`.
- **Síntoma observado:** la tarea terminó en 0 s con `TASK ERROR: migration aborted`.
- **Mensaje de error o salida exacta:** `Load key "/root/.ssh/id_rsa": error in libcrypto`, `root@192.168.34.33: Permission denied (publickey,password)` y `ERROR: migration aborted (duration 00:00:00): Can't connect to destination address using public key`.
- **Comprobaciones realizadas:** `ls -l /root/.ssh/` en `pve1` mostró `id_rsa` e `id_rsa.pub` con 0 bytes (creados a las 14:07, en la instalación); `ssh-keygen -y -f /root/.ssh/id_rsa` dio `error in libcrypto`. En `pve2` y `pve3` las claves eran válidas (3369 bytes).
- **Causa identificada:** la clave SSH de `pve1` se creó vacía durante la instalación, antes de formar el clúster. La migración usa SSH entre nodos con esa clave.
- **Solución aplicada:** se renombraron los dos ficheros vacíos, se generó una clave nueva (`ssh-keygen -t rsa -b 4096 -N '' -f /root/.ssh/id_rsa`) y se ejecutó `pvecm updatecerts --force` para repartirla por el clúster. La prueba con las mismas opciones que usa Proxmox (alias de huella y fichero `ssh_known_hosts` del clúster) dio `SSH_OK` hacia `pve2` y `pve3`.
- **Verificación:** la migración repetida terminó con `TASK OK` en 37 s.
- **Prevención:** tras crear el clúster, comprobar con `ls -l /root/.ssh/id_rsa` que la clave de cada nodo no está vacía antes de migrar.

### 4. Sin salida a Internet desde pve1 por una IP duplicada con el router

- **Título breve:** el instalador de Debian en la VM no encuentra el espejo y `pve1` no sale a Internet.
- **Fecha:** 17/11/2026.
- **Sistema afectado:** nodo `pve1`, VM `vm-debian` (101) y router MikroTik (`192.168.34.3`).
- **Objetivo:** instalar Debian sin entorno gráfico en la VM de prueba, descargando paquetes del espejo.
- **Síntoma observado:** el instalador mostraba `ERROR: Réplica de Debian inválida`. Desde `pve1`, `ping 192.168.34.3` respondía, pero `timeout 5 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/443'` daba `CERRADO` y `getent hosts deb.debian.org` fallaba. `pve3` sí salía a Internet.
- **Comprobaciones realizadas:** MikroTik tenía WAN con DHCP (`192.168.1.40`), ruta por defecto, `masquerade` y llegaba a `1.1.1.1`; su única regla de filtro estaba deshabilitada; no aparecía ninguna conexión de `192.168.34.32` en su tabla. La tabla de vecinos de `pve1` (`ip neigh show`) asociaba `192.168.34.3` con la MAC `bc:24:11:7f:56:af`, cuyo prefijo `BC:24:11` es el que Proxmox asigna a sus VM.
- **Causa identificada:** durante la instalación se había configurado la VM con la IP `192.168.34.3` (la del gateway) en lugar de `192.168.34.40`. La VM respondía a las peticiones ARP y a los `ping` en lugar de MikroTik, pero no reenvía tráfico.
- **Solución aplicada:** detener la VM, limpiar la tabla de vecinos con `ip neigh flush 192.168.34.3` y repetir el instalador con IP `192.168.34.40/24` y gateway `192.168.34.3`.
- **Verificación:** la prueba TCP al 443 desde `pve1` dio `abierto` y el instalador alcanzó el espejo.
- **Prevención:** reservar una tabla de direcciones del laboratorio y comprobar con `ip neigh` que la MAC de la puerta de enlace es la del router. Un `ping` que responde no demuestra que la puerta de enlace sea la correcta.

### 5. La VM anidada no sale por el router: modo promiscuo de VirtualBox

- **Título breve:** una VM dentro de un nodo Proxmox tiene IP pero no alcanza al router.
- **Fecha:** 17/11/2026.
- **Sistema afectado:** VM `vm-debian` (101) dentro del nodo `pve1`, que es a su vez una VM de VirtualBox con el adaptador 1 en la red interna `asir_lab`.
- **Objetivo:** que la VM anidada llegara a `192.168.34.3` (MikroTik) y a Internet.
- **Síntoma observado:** `ping 192.168.34.3` desde la VM daba `Destination Host Unreachable`, y MikroTik no mostraba ninguna conexión de `192.168.34.40`, aunque la VM tenía IP y era alcanzable desde `pve1`.
- **Causa identificada:** VirtualBox descarta por defecto las tramas con direcciones MAC distintas de la del adaptador de la VM (modo promiscuo en *Denegar*). La VM anidada usa su propia MAC (`bc:24:11:…`), de modo que sus tramas no pasaban a la red interna.
- **Solución aplicada:** `VBoxManage controlvm "Proxmox N<n>" nicpromisc1 allow-all` en los tres nodos, con las VM encendidas. Tras ello, `ping` al router y a `1.1.1.1` respondió desde la VM. Para que persista tras apagar, se aplica `VBoxManage modifyvm "Proxmox N<n>" --nicpromisc1 allow-all` con los nodos apagados.
- **Verificación:** la VM llegó a `192.168.34.3` y a `1.1.1.1` (`ttl=63`, pasando por el router).
- **Prevención:** al anidar máquinas virtuales en VirtualBox, poner el modo promiscuo del adaptador de red de la VM anfitriona en *Permitir todo*.

