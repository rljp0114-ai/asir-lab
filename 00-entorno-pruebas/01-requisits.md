# 01. Necesidades y requisitos

## 1. Objetivo
Definir qué necesita demostrar el laboratorio antes de elegir e instalar todos los sistemas. Las cantidades y necesidades aún no decididas se marcarán como pendientes.

## 2. Necesidades del entorno

| Área | Necesidad | Estado |
|---|---|---|
| Comunicaciones | Conectar VM y comprobar conectividad | ✅ Redes internas, routers MikroTik y OPNsense, pruebas de conectividad |
| Virtualización | Ejecutar sistemas de prueba en VirtualBox y un clúster Proxmox de tres nodos | ✅ En uso |
| Clientes | Acceder a servicios desde un sistema cliente | ✅ Windows 11 y Debian |
| Servidores | Probar servicios de red y administración | ✅ Debian Server, Linux-Servicios, Linux-Datos, Windows Server 2025 |
| Identidades | Investigar usuarios y permisos | ✅ Cuentas de usuario de administración en cada sistema; sin dominio |
| Datos y almacenamiento | Comparar sistemas de archivos y redundancia | ✅ Tarea 6 (RAID) |
| Recuperación | Diseñar y probar un procedimiento de recuperación | ✅ Tarea 6 y copias en TrueNAS |
| Supervisión | Medir recursos y revisar registros | ✅ Tarea 7 y registros de nftables |

## 3. Recursos y restricciones conocidas

El laboratorio se ejecutará en dos equipos personales:

- **PC doméstico:** AMD Ryzen 5 3400G (4 núcleos/8 hilos), 16 GB de RAM, Linux Mint, VirtualBox y SanDisk Portable SSD de 931,5 GB compartido con el portátil (559 GB libres en `/home`).
- **Portátil ASUS ExpertBook B3605CCA:** Intel Core Ultra 5 125H (14 núcleos/18 hilos), 32 GB de RAM, Linux Mint 22.3 y VirtualBox. El sistema se ejecuta desde un SanDisk Portable SSD de 931,5 GB conectado por USB 3.2; dispone de unos 89 GB libres en `/` y 613 GB en `/home`.
- El SSD Samsung interno de 1 TB del portátil queda excluido y no se utilizará para el laboratorio.
- Los recursos deben repartirse entre los sistemas anfitriones y las máquinas virtuales. No se deben asignar todos los núcleos o toda la memoria RAM a las VM.
- Se utilizarán los dos equipos para distribuir la carga y reducir las limitaciones de ejecutar todas las VM en un único anfitrión.

## 4. Criterios para elegir sistemas
Para cada opción, registrar:
- Función, arquitectura y versión.
- Fuente oficial de descarga y fecha de consulta.
- Requisitos mínimos oficiales.
- Recursos asignados a la VM de prueba.
- Licencia y soporte.
- Administración y actualizaciones.
- Compatibilidad.
- Ventajas, limitaciones y motivo de elección.

Los requisitos oficiales y los recursos asignados a la VM deben anotarse por separado.

## 5. Decisiones tomadas
- [x] Sistemas cliente: Windows 11 y Debian.
- [x] Cortafuegos y routers: MikroTik (activo), OPNsense y Ubuntu Server con nftables.
- [x] Almacenamiento y SSD: un único SanDisk Portable SSD de 931,5 GB con 559 GB libres en `/home`.
- [x] Interfaces de red: `enp8s0` (PC) y `eno1` (portátil).
- [x] Capacidad en el PC: 5 VM del proyecto a la vez, medido en [`../07-rendimiento-diagnostico/informe-rendimiento.md`](../07-rendimiento-diagnostico/informe-rendimiento.md). El portátil de 32 GB no se midió.
