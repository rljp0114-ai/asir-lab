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
