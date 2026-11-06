# Debian Server:
# Configuración inicial de la red virtual

## 1. Comprobación inicial de la red en Debian

Lo primero que hice fue comprobar cómo estaba configurada la red de la máquina virtual Debian Server. Para ello utilicé el comando:

```bash
ip -br addr
```

Este comando permite ver las interfaces de red de la máquina y las direcciones IP que tienen asignadas. Utilicé la opción `-br` para mostrar la información de forma resumida y facilitar su lectura.

En la primera comprobación observé que Debian tenía una interfaz de red llamada `enp0s3`, que estaba activa y tenía asignada la dirección IP `10.0.2.15/24`. Esta dirección correspondía a la conexión NAT de VirtualBox, que permite a la máquina virtual acceder a Internet a través del ordenador anfitrión.

También necesitaba una segunda interfaz para comunicar Debian con otras máquinas virtuales de mi laboratorio mediante una red interna.

## 2. Activación de la segunda interfaz de red

Para comprobar las interfaces disponibles utilicé de nuevo:

```bash
ip -br addr
```

Observé que la interfaz `enp0s8` estaba disponible, pero no tenía ninguna dirección IP asignada. Esta sería la interfaz destinada a la comunicación entre las máquinas virtuales.

Para activarla utilicé:

```bash
sudo ip link set enp0s8 up
```

El comando permite activar una interfaz de red. En este caso, la interfaz pasó a estar disponible, aunque todavía no tenía una dirección IP.

Después volví a ejecutar `ip -br addr` para comprobar el estado de las interfaces y verificar que `enp0s8` aparecía activa.

## 3. Asignación temporal de una dirección IP en Debian

Una vez activada la segunda interfaz, le asigné una dirección IP para que pudiera comunicarse con otras máquinas de la red interna:

```bash
sudo ip addr add 192.168.34.10/24 dev enp0s8
```

Este comando asigna la dirección IP `192.168.34.10` a la interfaz `enp0s8`.

La parte `/24` indica la máscara de red, equivalente a `255.255.255.0`. Esto permite que las máquinas que estén dentro de esa misma red puedan comunicarse directamente, siempre que su configuración sea correcta.

La dirección se eligió de manera provisional para empezar a realizar las pruebas. Esta configuración es temporal, por lo que puede perderse al reiniciar Debian.

## 4. Configuración de Ubuntu Server

Después de preparar Debian, configuré una segunda máquina virtual con Ubuntu Server para comprobar la comunicación entre dos sistemas.

En VirtualBox revisé los adaptadores de red para que ambas máquinas tuvieran dos conexiones:

- Un adaptador configurado en modo NAT, para disponer de acceso a Internet.
- Un segundo adaptador conectado a una red interna llamada `asir_lab`, para permitir la comunicación entre las máquinas virtuales.

Es importante que el nombre de la red interna sea exactamente el mismo en ambas máquinas para que puedan comunicarse mediante esa conexión.

## 5. Configuración de las interfaces en Ubuntu

Al comprobar la configuración de red de Ubuntu, utilicé el comando:

```bash
ip -br addr
```

Este comando me permitió identificar las interfaces disponibles y comprobar qué direcciones IP tenían asignadas.

Ubuntu Server utiliza Netplan para configurar las interfaces de red. Por ello, revisé el archivo de configuración:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

En este archivo indiqué que la interfaz `enp0s3` obtuviera su dirección IP automáticamente mediante DHCP, ya que está conectada al adaptador NAT.

Para la interfaz `enp0s8`, destinada a la red interna, configuré una dirección IP fija: `192.168.34.20/24`.

La configuración permite que Ubuntu tenga acceso a Internet por NAT y, al mismo tiempo, pueda comunicarse con Debian a través de la red interna.

Después comprobé que la configuración fuera correcta y la apliqué utilizando:

```bash
sudo netplan generate
sudo netplan try
```

El primer comando comprueba que la configuración de Netplan se pueda generar correctamente. El segundo aplica los cambios de forma provisional y permite confirmar que la conexión sigue funcionando.

## 6. Comprobación de la conectividad

Una vez configuradas las dos máquinas, comprobé que podían comunicarse entre sí.

Para realizar esta prueba utilicé el comando `ping`, que permite comprobar si otra máquina responde a través de la red.

Desde Ubuntu, la prueba se realiza con:

```bash
ping -c 4 192.168.34.10
```

Desde Debian, se realiza con:

```bash
ping -c 4 192.168.34.20
```

La opción `-c 4` indica que se envíen cuatro paquetes y después finalice la prueba.

La comunicación entre ambas máquinas funcionó correctamente. Esto confirma que las dos máquinas pueden comunicarse a través de la red interna `asir_lab`.

## 7. Estado actual y próximos pasos

En este punto tengo dos máquinas virtuales configuradas con dos conexiones de red cada una:

- Debian Server, con una interfaz NAT y otra para la red interna.
- Ubuntu Server, con una interfaz NAT y otra para la red interna.

La red interna utiliza provisionalmente el rango `192.168.34.0/24`. Debian utiliza la dirección `192.168.34.10` y Ubuntu utiliza `192.168.34.20`.

Estas direcciones todavía no son definitivas, ya que primero debo diseñar el direccionamiento completo del laboratorio para reservar direcciones para los futuros servidores, routers y clientes.

La configuración de la dirección IP de Debian se ha realizado de forma temporal, mientras que la de Ubuntu se ha establecido mediante Netplan. Más adelante revisaré la configuración permanente de Debian y adaptaré las direcciones cuando haya decidido el diseño definitivo de la red.
## 8. Modificación del direccionamiento de la red interna

Después de realizar las primeras pruebas, decidí modificar las direcciones IP para organizar mejor el direccionamiento del laboratorio y reservar direcciones para los diferentes equipos.

La nueva distribución quedó de la siguiente manera:

| Máquina virtual | Dirección IP | Función |
|---|---|---|
| Ubuntu Server | `192.168.34.3/24` | Router y cortafuegos con nftables |
| Debian Server | `192.168.34.4/24` | Servidor conectado a la red interna |

En Ubuntu modifiqué el archivo de configuración de Netplan para establecer la dirección `192.168.34.3/24` en la interfaz `enp0s8`.

En Debian asigné la dirección `192.168.34.4/24` a la interfaz correspondiente a la red interna.

Para realizar esta última operación utilicé:

```bash
sudo ip addr add 192.168.34.4/24 dev enp0s8
```

También eliminé una dirección automática anterior del rango `169.254.0.0/16`, que había aparecido al no obtener la interfaz una configuración de red válida.

Esta situación puede producirse cuando una interfaz no consigue obtener una dirección mediante DHCP y el sistema se asigna automáticamente una dirección local.

Hay que tener en cuenta que la asignación realizada mediante `ip addr add` es temporal y puede perderse al reiniciar la máquina.

## 9. Adaptación de los adaptadores de red de Debian

Hasta este momento, Debian tenía dos adaptadores de red: uno configurado en modo NAT y otro conectado a la red interna `asir_lab`.

Sin embargo, para comprobar que Ubuntu podía funcionar como router, era necesario evitar que Debian utilizase directamente su propia conexión NAT para acceder a Internet.

Por ello, modifiqué la configuración de red de Debian en VirtualBox:

- Adaptador 1: conectado a la red interna `asir_lab`.
- Adaptador 2: desactivado.

De esta manera, Debian dependería de Ubuntu para acceder a otras redes y a Internet.

Esta modificación permite comprobar realmente la función de encaminamiento de Ubuntu, en lugar de utilizar una conexión directa proporcionada por VirtualBox.

## 10. Preparación de Ubuntu Server como router

Una vez definido el direccionamiento, decidí utilizar Ubuntu Server como gateway provisional del laboratorio doméstico.

Esta adaptación permite practicar las funciones de encaminamiento y cortafuegos que aparecen en la arquitectura de clase, aunque en dicha arquitectura el gateway principal es el MikroTik físico.

Ubuntu dispone de dos interfaces:

| Interfaz | Función | Dirección |
|---|---|---|
| `enp0s3` | WAN, conexión NAT de VirtualBox | `10.0.2.15/24` |
| `enp0s8` | LAN, red interna `asir_lab` | `192.168.34.3/24` |

La interfaz WAN obtiene su dirección automáticamente mediante DHCP y utiliza `10.0.2.2` como puerta de enlace hacia Internet.

La interfaz LAN utiliza una dirección estática para comunicarse con Debian.

### 10.1. Habilitación del reenvío IPv4

Para que Ubuntu pueda actuar como router, es necesario habilitar el reenvío de paquetes IPv4.

Comprobé su estado mediante:

```bash
sysctl net.ipv4.ip_forward
```

El valor `1` indica que el reenvío está habilitado, mientras que el valor `0` indica que está deshabilitado.

Para habilitarlo temporalmente utilicé:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

Después preparé una configuración permanente creando el archivo:

```bash
sudo nano /etc/sysctl.d/99-ip-forward.conf
```

Dentro añadí:

```ini
net.ipv4.ip_forward=1
```

Finalmente, apliqué la configuración:

```bash
sudo sysctl --system
```

Con esto, Ubuntu puede recibir paquetes por una interfaz de red y reenviarlos por otra, una función necesaria para actuar como router.

## 11. Instalación y configuración de nftables

Una vez preparado el reenvío IPv4, continué con la configuración del cortafuegos mediante nftables.

nftables es una herramienta de Linux que permite controlar el tráfico de red mediante reglas. Estas reglas determinan qué conexiones se permiten y cuáles se bloquean.

En esta práctica lo utilizo para controlar el tráfico entre la red interna y el exterior.

Antes de modificar la configuración comprobé que nftables estaba instalado correctamente.

### 11.1. Copia inicial del archivo de configuración

Antes de realizar cambios, guardé una copia del archivo original:

```bash
sudo cp /etc/nftables.conf /etc/nftables.conf.backup
```

Esto permite disponer de una copia de seguridad del archivo anterior por si fuera necesario recuperarlo.

### 11.2. Edición del archivo de reglas

Para configurar el cortafuegos abrí:

```bash
sudo nano /etc/nftables.conf
```

En este archivo establecí dos tablas principales:

- `inet filter`: contiene las reglas de filtrado del tráfico.
- `ip nat`: contiene las reglas de traducción de direcciones de red.

Dentro de la tabla `inet filter` configuré tres cadenas:

**INPUT:** controla el tráfico que llega directamente al propio Ubuntu.

**FORWARD:** controla el tráfico que atraviesa Ubuntu, por ejemplo, los paquetes que Debian envía hacia Internet.

**OUTPUT:** controla el tráfico que genera el propio Ubuntu.

También configuré la cadena `postrouting` dentro de la tabla NAT, que permite modificar la dirección IP de origen de los paquetes antes de que salgan hacia otra red.

Entre las reglas configuradas destacan:

- Permitir el tráfico local mediante la interfaz `lo`.
- Permitir conexiones que ya están establecidas o relacionadas.
- Permitir conexiones SSH y solicitudes de ping desde la red interna hacia Ubuntu.
- Permitir que los equipos de la LAN envíen tráfico hacia Internet.
- Bloquear por defecto el tráfico que no coincida con las reglas permitidas.
- Aplicar `masquerade` para que los equipos de la red interna puedan salir a Internet utilizando la dirección WAN de Ubuntu.

La regla `masquerade` es especialmente importante porque permite que Debian utilice la conexión de Ubuntu sin necesitar una dirección IP pública propia.

### 11.3. Comprobación de la sintaxis

Antes de aplicar las reglas utilicé:

```bash
sudo nft -c -f /etc/nftables.conf
```

Este comando comprueba que el archivo tenga una sintaxis válida sin aplicar todavía los cambios al cortafuegos.

Durante esta comprobación apareció un error relacionado con la declaración de la tabla `ip nat`.

El problema estaba relacionado con la estructura del archivo y el cierre de los bloques de configuración. En nftables es importante cerrar correctamente cada cadena y cada tabla mediante las llaves correspondientes.

Una vez corregida la estructura, volví a ejecutar la comprobación y la configuración fue aceptada sin errores.

### 11.4. Aplicación de las reglas

Después de comprobar la sintaxis, apliqué las reglas mediante:

```bash
sudo nft -f /etc/nftables.conf
```

Para comprobar las reglas que estaban cargadas utilicé:

```bash
sudo nft list ruleset
```

Finalmente, habilité el servicio para que nftables se iniciase automáticamente al arrancar el sistema:

```bash
sudo systemctl enable --now nftables
```

## 12. Configuración de Debian para utilizar Ubuntu como gateway

Una vez configurado Ubuntu, era necesario indicar a Debian que debía utilizarlo como puerta de enlace para acceder a otras redes.

Para ello utilicé:

```bash
sudo ip route replace default via 192.168.34.3 dev enp0s8
```

Este comando establece como ruta predeterminada la dirección `192.168.34.3`, que corresponde a Ubuntu Server.

De esta manera, cuando Debian necesita comunicarse con una dirección que no pertenece a su propia red, envía los paquetes a Ubuntu para que este los reenvíe.

Comprobé la configuración mediante:

```bash
ip route
```

La ruta que necesitaba encontrar era:

```text
default via 192.168.34.3 dev enp0s8
```

Durante esta configuración también apareció una ruta asociada al rango `169.254.0.0/16`. Esta ruta está relacionada con las direcciones automáticas y no constituye la puerta de enlace que estamos utilizando.

## 13. Comprobación del funcionamiento del router

Una vez configuradas las direcciones IP, el reenvío IPv4, las reglas de nftables y la puerta de enlace de Debian, realicé diferentes pruebas de conectividad.

### 13.1. Comunicación entre Debian y Ubuntu

Desde Debian ejecuté:

```bash
ping -c 4 192.168.34.3
```

La prueba respondió correctamente, confirmando que Debian podía comunicarse con Ubuntu a través de la red interna.

### 13.2. Comprobación del acceso a Internet

Después probé la conectividad con una dirección IP externa:

```bash
ping -c 4 1.1.1.1
```

La prueba funcionó correctamente, lo que permitió comprobar que los paquetes podían atravesar Ubuntu y llegar a Internet.

Esto demuestra que el reenvío IPv4 y la traducción NAT estaban funcionando.

### 13.3. Comprobación de la resolución DNS

Por último, probé la resolución de nombres de dominio:

```bash
ping -c 4 google.com
```

Para realizar esta comprobación configuré temporalmente servidores DNS externos en Debian mediante el archivo:

```bash
sudo nano /etc/resolv.conf
```

Añadí las siguientes direcciones:

```text
nameserver 8.8.8.8
nameserver 1.1.1.1
```

Estas direcciones corresponden a servidores DNS públicos de Google y Cloudflare.

La prueba respondió correctamente, confirmando que Debian podía resolver nombres de dominio y acceder a servicios mediante sus nombres.

Es importante diferenciar las dos funciones: Ubuntu actúa como gateway y se encarga del encaminamiento, mientras que los servidores DNS traducen los nombres de dominio a direcciones IP.

## 14. Prueba de tráfico bloqueado mediante nftables

Una vez comprobado que Debian podía acceder a Internet, realicé una prueba para verificar que nftables también era capaz de bloquear tráfico.

Para ello añadí temporalmente una regla al principio de la cadena `forward` de Ubuntu:

```bash
sudo nft insert rule inet filter forward ip saddr 192.168.34.4 ip protocol icmp counter log prefix "PRUEBA-BLOQUEO: " drop
```

Esta regla identifica los paquetes ICMP que proceden de Debian (`192.168.34.4`) y los bloquea.

Sus elementos principales son:

- `ip saddr`: identifica la dirección IP de origen.
- `ip protocol icmp`: selecciona el tráfico ICMP, utilizado por ejemplo por el comando `ping`.
- `counter`: cuenta los paquetes que coinciden con la regla.
- `log`: registra los paquetes en el sistema.
- `drop`: descarta los paquetes.

La regla se insertó al principio de la cadena para que se evaluase antes de la regla general que permite el tráfico desde la LAN hacia la WAN.

### 14.1. Comprobación del bloqueo

Desde Debian ejecuté:

```bash
ping -c 4 1.1.1.1
```

En esta ocasión, el ping no obtuvo respuesta, por lo que se comprobó que nftables estaba bloqueando correctamente el tráfico ICMP procedente de Debian.

También consulté el contador de paquetes mediante:

```bash
sudo nft list chain inet filter forward
```

El contador permitió comprobar que la regla había recibido paquetes.

Con esta prueba pude demostrar que Ubuntu no solamente permite el acceso a Internet, sino que también puede controlar y bloquear determinados tipos de tráfico.

## 15. Estado actual y próximos pasos

En este punto he conseguido configurar Ubuntu Server como router provisional y cortafuegos para la red interna de mi laboratorio.

La situación actual es la siguiente:

- Ubuntu dispone de una interfaz WAN conectada mediante NAT y otra interfaz LAN conectada a `asir_lab`.
- Ubuntu tiene habilitado el reenvío IPv4.
- nftables está instalado y tiene configuradas reglas de filtrado y NAT.
- Debian utiliza Ubuntu (`192.168.34.3`) como puerta de enlace.
- Debian puede comunicarse con Ubuntu y acceder a Internet.
- Se ha comprobado que nftables puede bloquear el tráfico ICMP procedente de Debian.

Quedan pendientes las siguientes tareas:

1. Comprobar e interpretar los registros de los paquetes bloqueados.
2. Retirar la regla temporal de bloqueo y verificar que Debian recupera el acceso a Internet.
3. Realizar una copia de seguridad de la configuración definitiva de nftables.
4. Comprobar el comportamiento del cortafuegos ante un fallo controlado y realizar su recuperación.
5. Revisar qué configuraciones deben hacerse permanentes en Debian, especialmente la dirección IP, la puerta de enlace y los servidores DNS.

Estas tareas se realizarán posteriormente para completar las pruebas de funcionamiento y recuperación del servidor de comunicaciones.
## 16. Comprobación de los registros del cortafuegos

Después de comprobar que la regla temporal bloqueaba correctamente los paquetes ICMP enviados desde Debian, se revisaron los registros del sistema Ubuntu Server para verificar que `nftables` estaba registrando los paquetes bloqueados.

Para consultar los registros se utilizó:

```bash
sudo journalctl -k -g "PRUEBA-BLOQUEO"
```

El comando permite consultar los mensajes del registro del kernel que contienen el texto `PRUEBA-BLOQUEO`, que es el prefijo configurado en la regla de bloqueo.

**Resultado obtenido:**

Se encontraron 4 registros correspondientes a los paquetes ICMP bloqueados durante la prueba.

Esto permite comprobar que el cortafuegos no solamente está bloqueando el tráfico indicado, sino que también está generando información que puede utilizarse para analizar posibles problemas de conectividad o intentos de comunicación no permitidos.

## 17. Eliminación de la regla temporal y recuperación de la conectividad

Una vez finalizada la prueba, se procedió a eliminar la regla temporal que bloqueaba los paquetes ICMP procedentes de Debian.

Para ello, primero se consultaron las reglas de la cadena `forward` con sus identificadores (*handles*):

```bash
sudo nft -a list chain inet filter forward
```

Los *handles* permiten identificar individualmente las reglas existentes en una cadena de `nftables`.

A continuación, se eliminaron las reglas temporales utilizando el identificador correspondiente:

```bash
sudo nft delete rule inet filter forward handle NUMERO
```

Se debe sustituir `NUMERO` por el identificador real de la regla que se quiere eliminar.

**Resultado obtenido:**

Después de eliminar las reglas temporales, se volvió a realizar una prueba de conectividad desde Debian:

```bash
ping -c 4 1.1.1.1
```

Debian volvió a recibir respuestas correctamente.

Con esta comprobación se verificó que la regla temporal había dejado de bloquear el tráfico y que la comunicación con Internet a través de Ubuntu Server se había recuperado.

## 18. Conclusiones de las pruebas de nftables

Las pruebas realizadas han permitido comprobar el funcionamiento básico del cortafuegos configurado en Ubuntu Server.

Se han verificado los siguientes aspectos:

- **Enrutamiento:** Ubuntu Server permite que Debian utilice su conexión de red para acceder a Internet.
- **Reenvío de paquetes:** la opción `net.ipv4.ip_forward` permite reenviar tráfico entre la interfaz interna y la interfaz de salida.
- **NAT:** la regla `masquerade` permite que los equipos de la red interna accedan a Internet utilizando la dirección de la interfaz de salida de Ubuntu.
- **Filtrado:** se ha comprobado que una regla de `nftables` puede bloquear un tipo concreto de tráfico.
- **Registro de eventos:** se han localizado 4 registros generados por la regla temporal de bloqueo.
- **Recuperación:** después de eliminar la regla mediante su *handle*, Debian recuperó la conectividad.

Estas pruebas demuestran que Ubuntu Server está realizando correctamente las funciones de encaminamiento y filtrado previstas para esta parte del laboratorio.

## 19. Tareas pendientes

Aunque el funcionamiento básico del cortafuegos ya está comprobado, todavía quedan algunas tareas por realizar para completar la configuración y documentar la práctica.

### 19.1. Comprobar la persistencia de la configuración

Se debe verificar que las reglas de `nftables` continúan activas después de reiniciar Ubuntu Server.

También habrá que comprobar que el servicio se encuentra habilitado para iniciarse automáticamente:

```bash
sudo systemctl is-enabled nftables
```

Y consultar su estado:

```bash
sudo systemctl status nftables
```

### 19.2. Realizar una copia de seguridad de la configuración

Se debe guardar una copia de la configuración definitiva del cortafuegos para poder recuperarla en caso de modificación incorrecta o pérdida de las reglas.

El archivo principal de configuración es:

```bash
/etc/nftables.conf
```

La copia de seguridad permitirá restaurar las reglas sin tener que configurarlas nuevamente desde cero.

### 19.3. Realizar una prueba controlada de fallo y recuperación

Se realizará una prueba controlada para comprobar qué sucede cuando se interrumpe temporalmente alguna de las comunicaciones o reglas necesarias para el funcionamiento de la red.

Después se restaurará la configuración original y se comprobará que Debian vuelve a tener conectividad con Ubuntu Server y con Internet.

Esta prueba permitirá documentar el procedimiento de detección del problema y su recuperación.

### 19.4. Hacer persistente la configuración de red de Debian

Actualmente, la dirección IP, la ruta predeterminada y los servidores DNS de Debian se han configurado durante las pruebas.

Queda pendiente comprobar y configurar su persistencia para que Debian conserve los parámetros de red después de reiniciar la máquina virtual.

Los parámetros que se deben mantener son:

| Parámetro | Configuración |
|---|---|
| Dirección IP | `192.168.34.4/24` |
| Puerta de enlace | `192.168.34.3` |
| DNS principal | `8.8.8.8` |
| DNS secundario | `1.1.1.1` |
| Interfaz de red | `enp0s8` |

Una vez configurados, se reiniciará Debian y se comprobará que sigue teniendo conectividad con Ubuntu Server y con Internet.

## MikroTik CHR: Instalación y configuración inicial

### 1. Instalación de MikroTik CHR

Se instaló MikroTik CHR (Cloud Hosted Router) en una máquina virtual de VirtualBox.

Una vez finalizada la instalación, se retiró la imagen ISO para que la máquina arrancase directamente desde el disco virtual.

Se accedió al sistema mediante el usuario `admin` y se estableció la contraseña correspondiente.

Posteriormente, se modificó el nombre del dispositivo para identificarlo dentro del laboratorio:

- **Nombre:** `MikroTik-ThinkLab`

### 2. Configuración de los adaptadores de red

Se configuraron dos interfaces de red en VirtualBox:

| Interfaz MikroTik | Adaptador VirtualBox | Función |
|---|---|---|
| `ether1` | Adaptador puente | Conexión WAN hacia la red doméstica |
| `ether2` | Red interna `asir_lab` | Conexión LAN con Debian |

Se utilizó el modo puente en el primer adaptador para poder acceder a WebFig desde el ordenador anfitrión.

### 3. Configuración de las direcciones IP

Se asignaron las siguientes direcciones:

| Dispositivo | Interfaz | Dirección IP |
|---|---|---|
| MikroTik | `ether1` | `192.168.30.193` |
| MikroTik | `ether2` | `192.168.34.3/24` |
| Debian | Interfaz LAN | `192.168.34.4/24` |

La interfaz WAN obtuvo su configuración mediante DHCP, mientras que la interfaz LAN se configuró con una dirección estática.

### 4. Configuración de DNS

Desde WebFig, en `IP → DNS`, se configuraron los siguientes servidores DNS:

- `8.8.8.8`
- `1.1.1.1`

También se activó la opción **Allow Remote Requests**.

### 5. Configuración del cliente DHCP

En `IP → DHCP Client` se creó una entrada asociada a `ether1`.

El estado obtenido fue:

- **Status:** `bound`

Esto confirmó que MikroTik recibió correctamente la configuración de red de la red doméstica.

### 6. Configuración de la ruta predeterminada

En `IP → Routes` se comprobó la existencia de una ruta predeterminada:

- **Dst. Address:** `0.0.0.0/0`
- **Gateway:** dirección del router doméstico.
- **Routing Table:** `main`.

Esta ruta permite enviar hacia el router doméstico el tráfico destinado a redes externas.

### 7. Configuración de NAT

Se creó una regla en `IP → Firewall → NAT` para permitir que los dispositivos de la red interna pudieran salir a Internet utilizando la dirección WAN de MikroTik.

Configuración:

| Parámetro | Valor |
|---|---|
| Chain | `srcnat` |
| Action | `masquerade` |
| Out. Interface | `ether1` |

La acción `masquerade` permite traducir las direcciones IP privadas de la red interna a la dirección IP de salida del router.

### 8. Problema encontrado: error en la regla NAT

Durante las pruebas de conectividad se comprobó que Debian podía comunicarse con MikroTik, pero no tenía acceso a Internet.

Se revisaron los siguientes elementos:

- Estado del cliente DHCP.
- Dirección IP de WAN y LAN.
- Gateway doméstico.
- Ruta predeterminada.
- Servidores DNS.
- Tabla ARP.
- Reglas del firewall.
- Tabla de conexiones.

Aunque la configuración parecía correcta, los contadores de la regla NAT permanecían a cero.

Finalmente, se utilizó el terminal de RouterOS para consultar la configuración detallada:

```routeros
/ip firewall nat print detail
```

El resultado mostró:

```routeros
chain=srcnat action=masquerade out-interface=!ether1
```

El símbolo `!` indica una negación. Por tanto, la regla estaba aplicando NAT a las conexiones que salían por cualquier interfaz excepto `ether1`.

Esto era incorrecto porque `ether1` es la interfaz WAN.

### 9. Solución del problema

Se corrigió la regla existente mediante el siguiente comando:

```routeros
/ip firewall nat set 0 out-interface=ether1
```

Después se volvió a consultar la configuración:

```routeros
/ip firewall nat print
```

La regla quedó correctamente configurada:

```routeros
chain=srcnat action=masquerade out-interface=ether1
```

### 10. Pruebas de conectividad

Una vez corregida la regla NAT, se realizaron pruebas desde Debian:

```bash
ping -c 4 1.1.1.1
```

Esta prueba permitió comprobar la conectividad con una dirección IP externa.

Posteriormente:

```bash
ping -c 4 google.com
```

Esta segunda prueba permitió comprobar tanto la resolución DNS como la conectividad hacia Internet.

**Resultado:** ambas pruebas funcionaron correctamente y Debian consiguió acceder a Internet a través de MikroTik.

### 11. Estado actual

La configuración básica de MikroTik CHR y la conexión entre la red interna y la red doméstica funcionan correctamente.

Queda pendiente guardar una copia de seguridad de la configuración y hacer una prueba.
### 12. Prueba de fallo y recuperación

Una vez completada la configuración de MikroTik, se realizó una prueba para comprobar el comportamiento de la red ante un fallo controlado.

**Objetivo:** verificar que la regla NAT es necesaria para proporcionar acceso a Internet a los equipos de la red interna.

#### Procedimiento

1. Se accedió al terminal de RouterOS desde WebFig.
2. Se deshabilitó temporalmente la regla NAT:

```routeros
/ip firewall nat disable 0
```

3. Desde Debian se comprobó la conectividad:

```bash
ping -c 4 1.1.1.1
```

El equipo perdió la salida a Internet, tal como se esperaba.

4. Se volvió a habilitar la regla NAT:

```routeros
/ip firewall nat enable 0
```

5. Se repitió la prueba de conectividad desde Debian.

#### Resultado

La conexión a Internet se recuperó correctamente después de habilitar de nuevo la regla `masquerade`.

La prueba permitió comprobar que la traducción NAT es necesaria para que Debian pueda acceder a redes externas a través de MikroTik.

La regla quedó habilitada al finalizar la prueba.

# OPNsense: instalación y configuración inicial

## 1. Instalación de OPNsense

Se instaló OPNsense como una de las soluciones de router y firewall del laboratorio ASIR.

Para su instalación se creó una máquina virtual en VirtualBox con las siguientes características:

- Sistema operativo: FreeBSD 64-bit.
- Memoria RAM: 5 GB.
- Procesadores: 2.
- Disco virtual: 20 GB.
- Adaptadores de red: 2.

Se utilizaron dos adaptadores de red Intel PRO/1000 MT Desktop para asegurar la compatibilidad y la detección de las interfaces de red.

## 2. Configuración de los adaptadores de red

Se configuraron los adaptadores de VirtualBox de la siguiente manera:

| Adaptador | Conexión | Función |
|---|---|---|
| Adaptador 1 | Adaptador puente | WAN: conexión con la red doméstica |
| Adaptador 2 | Red interna `asir_lab` | LAN: conexión con la red del laboratorio |

De esta forma, OPNsense dispone de una interfaz para comunicarse con la red exterior y otra para gestionar el tráfico de la red interna.

## 3. Asignación de interfaces

Durante la configuración inicial, OPNsense no detectaba correctamente las interfaces de red.

Se revisó la configuración de VirtualBox y se modificó el tipo de adaptador de red para utilizar Intel PRO/1000 MT Desktop en ambas tarjetas.

Después de este cambio, OPNsense consiguió detectar las dos interfaces:

- `em0`: WAN.
- `em1`: LAN.

Se asignaron las interfaces correspondientes desde el menú de consola de OPNsense.

## 4. Configuración del direccionamiento IP

Se estableció el siguiente direccionamiento:

| Interfaz | Dirección IP | Configuración |
|---|---|---|
| WAN (`em0`) | Automática | DHCP |
| LAN (`em1`) | `192.168.34.2/24` | Estática |

La dirección LAN pertenece a la red interna `192.168.34.0/24`, utilizada por los equipos del laboratorio.

La dirección WAN se obtiene automáticamente mediante DHCP desde el router de la red doméstica.

## 5. Comprobación de conectividad

Se realizaron pruebas de conectividad para comprobar el funcionamiento de OPNsense:

- Se comprobó la comunicación entre Debian y la interfaz LAN de OPNsense.
- Se comprobó la salida a Internet desde el laboratorio.
- Se verificó la resolución de nombres mediante DNS.

Posteriormente, tras un reinicio, OPNsense dejó de detectar temporalmente las interfaces de red y perdió la configuración operativa de la WAN.

Se revisaron los adaptadores virtuales y se reinició la máquina. Después se recuperó la detección de las interfaces, se volvió a configurar la dirección LAN y se restableció la obtención automática de la dirección WAN mediante DHCP.

## 6. Estado actual

La instalación y configuración inicial de OPNsense están realizadas.

Queda pendiente completar las pruebas específicas del firewall, comprobar las reglas de filtrado y documentar el comportamiento del tráfico permitido y bloqueado.
