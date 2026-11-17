# 01. Necesidades y requisitos

## 1. Objetivo
Definir qué necesita demostrar el laboratorio antes de elegir e instalar todos los sistemas. Las cantidades y necesidades aún no decididas se marcarán como pendientes.

## 2. Necesidades del entorno

| Área | Necesidad | Estado |
|---|---|---|
| Comunicaciones | Conectar VM y comprobar conectividad | En preparación |
| Virtualización | Ejecutar sistemas de prueba en VirtualBox usando dos equipos anfitriones | En uso |
| Clientes | Acceder a servicios desde un sistema cliente | Pendiente |
| Servidores | Probar servicios de red y administración | Debian Server instalado; servicios futuros pendientes |
| Identidades | Investigar usuarios y permisos | Pendiente |
| Datos y almacenamiento | Comparar sistemas de archivos y redundancia | Pendiente |
| Recuperación | Diseñar y probar un procedimiento de recuperación | Pendiente |
| Supervisión | Medir recursos y revisar registros | Pendiente |

## 3. Recursos y restricciones conocidas

El laboratorio se ejecutará en dos equipos personales:

- **PC doméstico:** AMD Ryzen 5 3400G (4 núcleos/8 hilos), 16 GB de RAM, Linux Mint, VirtualBox y SSD con aproximadamente 700 GB según la estimación actual. Falta confirmar el espacio libre exacto.
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

## 5. Decisiones pendientes
- [ ] Definir el sistema cliente.
- [ ] Definir qué servicios se probarán en Debian Server.
- [ ] Decidir si se añadirá una VM de cortafuegos.
- [ ] Confirmar capacidad y espacio libre exactos del SSD del PC doméstico.
- [ ] Comprobar interfaces de red y conectividad de ambos anfitriones.
- [ ] Estimar mediante pruebas cuántas VM pueden ejecutarse simultáneamente en cada equipo.
