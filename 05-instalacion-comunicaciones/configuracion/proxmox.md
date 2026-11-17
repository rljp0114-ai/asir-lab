# Proxmox VE: clúster de tres nodos

**Estado:** teoría redactada; instalación, clúster y migración **pendientes** (apartado 6). Las tres VM de los nodos están creadas y no se ha completado la instalación.

## 1. Objetivo

Montar un clúster de tres nodos Proxmox VE, crear un contenedor y una máquina virtual, migrarlos entre nodos midiendo tiempo y espacio, y decidir qué se guarda en el servidor de copias.

## 2. Diseño

| Elemento | Valor |
|---|---|
| Nodos | `pve1`, `pve2`, `pve3` |
| IP de gestión (prevista) | `192.168.34.32`, `.33` y `.34` (`/24`), puerta de enlace en el router activo |
| Red | Red interna `asir_lab` (LAN) |
| Equipo anfitrión | PC doméstico (16 GB), el equipo más limitado: se dimensiona para que quepa aquí y así funciona también en el portátil (32 GB). Con el clúster solo se enciende además el router y, si hace falta, TrueNAS |
| Quórum | Tres nodos: el clúster mantiene el quórum si falla uno (con dos nodos haría falta un dispositivo de quórum externo) |
| Almacenamiento | Local en cada nodo; la migración copia el disco entre nodos |
| Máquinas de prueba | Una VM Debian sin entorno gráfico (la rúbrica exige Ubuntu Server o Debian sin escritorio) y un contenedor Linux |

Gestión conjunta, migración y alta disponibilidad son cosas distintas: la **gestión conjunta** administra los tres nodos desde una sola interfaz; la **migración** mueve una VM o contenedor de un nodo a otro bajo demanda; la **alta disponibilidad** reinicia automáticamente un servicio en otro nodo si el suyo cae, y exige almacenamiento compartido y servicios configurados para ello. En este laboratorio se hace gestión conjunta y migración manual.

## 3. Ventajas e inconvenientes de virtualizar servidores

| Ventajas | Inconvenientes |
|---|---|
| Se aprovecha mejor el hardware: varios servidores en una máquina | Si el equipo físico falla, caen todos los servidores que aloja (punto único de fallo) |
| Aislamiento entre servidores | El hipervisor consume recursos y añade una capa que gestionar |
| Copias, instantáneas y restauración sencillas | Los servidores compiten por CPU, memoria y disco; uno puede degradar a los demás |
| Crear, clonar o mover un servidor lleva minutos | Más complejidad: red virtual, almacenamiento y actualizaciones del hipervisor |
| Migración entre nodos y alta disponibilidad | La alta disponibilidad exige almacenamiento compartido y más nodos |
| Entornos de prueba baratos y repetibles | Algunos servicios con requisitos de hardware especial o de rendimiento no se virtualizan bien |

## 4. Contenedores frente a máquinas virtuales

| | Contenedor (LXC) | Máquina virtual (KVM) |
|---|---|---|
| Núcleo | Comparte el del anfitrión | Tiene el suyo |
| Sistema invitado | Solo Linux, con el núcleo del anfitrión | Cualquiera (Linux, Windows...) |
| Arranque | Segundos | Más lento (arranca un sistema completo) |
| Consumo | Muy bajo (decenas de MB de RAM, disco pequeño) | Mayor (RAM reservada y disco completo) |
| Aislamiento | Menor | Mayor |

**Cuándo usar cada uno:** un contenedor para servicios Linux ligeros y numerosos (DNS, servidor web, base de datos pequeña), donde importa ahorrar recursos y arrancar rápido. Una máquina virtual cuando se necesita otro sistema operativo (por ejemplo, Windows Server), un núcleo distinto o un aislamiento fuerte por seguridad. Por esto, en este laboratorio Windows Server 2025 es una VM y los servicios Linux ligeros podrían ser contenedores.

## 5. Qué se copia al servidor de copias y qué no

| Se copia | Motivo |
|---|---|
| Configuración de red de cada nodo (`/etc/network/interfaces`, `/etc/hosts`) | Pequeña y necesaria para reconstruir un nodo |
| Configuración del clúster (base `config.db` de `/var/lib/pve-cluster/`, que es el origen de `/etc/pve`) | Contiene la definición del clúster, VM y contenedores |
| Copias (`vzdump`) de las VM y contenedores de prueba, que son pequeños | Permiten restaurarlos en otro nodo |

| No se copia | Motivo |
|---|---|
| La imagen completa de cada nodo (discos de 40-64 GB) | Se reinstala desde la ISO y se reconfigura con lo anterior |
| Contraseñas y claves privadas del clúster | Los secretos no deben almacenarse sin cifrar; se custodian fuera del repositorio |
| Discos grandes de VM de usuario sin valor | Ocupan espacio de TrueNAS sin aportar |

## 6. Pendiente de realizar

| Paso | Estado |
|---|---|
| Instalar Proxmox VE en los tres nodos (versión, usuario `root`, red) | ⬜ |
| Crear el clúster y comprobar el quórum | ⬜ |
| Crear una VM Debian sin entorno gráfico y un contenedor | ⬜ |
| Migrar el contenedor y la VM entre nodos; medir tiempo y espacio en disco; valorar mejoras | ⬜ |
| Copiar configuraciones al servidor de copias | ⬜ |

**Limitación esperada:** los nodos son VM de VirtualBox; sin virtualización anidada, la VM de prueba se ejecutará sin aceleración (KVM desactivado en sus opciones), más lenta. Los tiempos medidos no serán los de un servidor real y así se hará constar.
