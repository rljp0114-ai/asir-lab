# 06. Pruebas e incidencias

## 1. Ficha para cada incidencia

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

## 2. Registro de pruebas

| Fecha | Prueba | Procedimiento | Resultado observado | ¿Correcta? | Evidencia |
|---|---|---|---|---|---|
| Pendiente | Verificar interfaces | `ip -br address` | Pendiente de repetir y guardar | Pendiente | Pendiente |
| Pendiente | Verificar rutas | `ip route` | Pendiente | Pendiente | Pendiente |

## 3. Almacenamiento y recuperación

Cuando se realicen las actividades, documentar:
- Sistemas de archivos comparados y fuentes.
- Configuración de cada tipo de RAID que se pruebe.
- Resultado de comprobaciones y estado de discos.
- Plan de contingencia y elementos que se pretende recuperar.
- Prueba de restauración, duración medida y limitaciones.

No realizar pruebas destructivas sobre discos con datos importantes. Utilizar discos virtuales de prueba y comprobar el dispositivo seleccionado antes de modificar particiones o sistemas de archivos.

## 4. Monitorización

Registrar una línea base y comparar reposo con carga controlada:

| Fecha | Máquina | Estado | CPU | RAM | Disco | Red | Herramienta |
|---|---|---|---|---|---|---|---|
| Pendiente | Debian Server | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente |

Anotar valores medidos, condiciones de la prueba y optimizaciones realizadas. No afirmar que existe una mejora sin comparar mediciones antes y después.

## 5. Incidencias registradas

### 5.1. El ping a Internet falla a través de MikroTik en la red del aula

- **Título breve:** `ping` a `1.1.1.1` sin respuesta, con conexión al router correcta.
- **Fecha:** 16/11/2026.
- **Sistema afectado:** Debian Server (cliente) y MikroTik (router), con el WAN conectado por adaptador puente a la red del aula.
- **Objetivo:** comprobar que los equipos de la LAN tienen salida a Internet a través de MikroTik.
- **Síntoma observado:** Debian se comunicaba con MikroTik (`192.168.34.3`), pero `ping 1.1.1.1` no recibía respuesta. El ping lanzado desde el propio MikroTik también fallaba.
- **Mensaje de error o salida exacta:** pendiente de pegar la salida literal del ping.
- **Comprobaciones realizadas:**
  1. Comunicación Debian-MikroTik: correcta.
  2. Ping desde MikroTik hacia el exterior: fallaba; al fallar también desde el router, el fallo no dependía del cliente Debian ni de la LAN.
  3. Prueba de conexión TCP al puerto 443 desde Debian, sin usar ICMP: `timeout 5 bash -c 'cat < /dev/null > /dev/tcp/1.1.1.1/443' && echo ABIERTO || echo CERRADO`. Resultado: `ABIERTO`.
- **Causa identificada:** la causa más probable es que la red del aula filtra el tráfico ICMP hacia el exterior, pero no se ha confirmado con la administración de la red. Lo que sí se ha comprobado es que el tráfico TCP sale correctamente por MikroTik.
- **Solución aplicada:** no se cambió ninguna configuración. Para probar la salida a Internet en este entorno se utilizan pruebas TCP (y resolución DNS) en lugar de `ping`.
- **Verificación posterior:** la prueba de conexión permitida y bloqueada de MikroTik se hizo con TCP y funcionó (ver `05-sistemas/configuracion/mikrotik.md`).
- **Evidencia:** `evidencies/2026-11-16-debian-prueba-tcp443-bloqueo-mikrotik.png` (la primera línea muestra la conexión TCP al 443 abierta), `evidencies/2026-11-16-mikrotik-log-lista-prueba-bloqueo.png` y `evidencies/2026-11-16-mikrotik-log-entrada-detalle.png`.
- **Qué se ha aprendido:** un `ping` fallido no demuestra que no haya salida a Internet. Hay que distinguir entre fallo de ICMP y fallo de conectividad probando con otro protocolo, y probar desde el propio router para localizar dónde está el problema.

## 5.2 Pruebas de red de Windows Server salían por la NAT en lugar de por la LAN

- **Objetivo:** comprobar que Windows Server 2025 (`192.168.34.21`) llega a MikroTik, a TrueNAS y a Internet a través de MikroTik.
- **Síntoma observado:** `Test-NetConnection 192.168.34.20` falló con `DestinationHostUnreachable`, y `Test-NetConnection 1.1.1.1 -Port 443` funcionó.
- **Comprobaciones realizadas:** `ipconfig /all` mostró un segundo adaptador (`Ethernet 2`, `10.0.2.15`, puerta de enlace `10.0.2.2`) además del de la LAN. Las dos pruebas fallidas o dudosas tenían `SourceAddress: 10.0.2.15`, es decir, salían por la NAT de VirtualBox.
- **Causa identificada:** la VM conservaba un adaptador NAT adicional, y TrueNAS estaba apagado en ese momento.
- **Solución aplicada:** desactivar el adaptador con `Disable-NetAdapter -Name "Ethernet 2" -Confirm:$false`, encender TrueNAS y repetir las pruebas.
- **Verificación posterior:** las tres pruebas dieron resultado correcto con `SourceAddress: 192.168.34.21` (ver `05-sistemas/configuracion/windows-server-2025.md`).
- **Qué se ha aprendido:** con dos adaptadores, una prueba que funciona no demuestra que el tráfico pase por el router. Hay que mirar siempre el `SourceAddress` y el `InterfaceAlias` del resultado.
