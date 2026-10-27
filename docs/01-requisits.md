# 01. Necesidades y requisitos

## 1. Objetivo
Definir qué necesita demostrar el laboratorio antes de elegir e instalar todos los sistemas. Las cantidades y necesidades aún no decididas se marcarán como pendientes.

## 2. Necesidades del entorno

| Área | Necesidad | Estado |
|---|---|---|
| Comunicaciones | Conectar VM y comprobar conectividad | En preparación |
| Virtualización | Ejecutar sistemas de prueba en VirtualBox | En uso |
| Clientes | Acceder a servicios desde un sistema cliente | Pendiente |
| Servidores | Probar servicios de red y administración | Debian Server instalado; servicios futuros pendientes |
| Identidades | Investigar usuarios y permisos | Pendiente |
| Datos y almacenamiento | Comparar sistemas de archivos y redundancia | Pendiente |
| Recuperación | Diseñar y probar un procedimiento de recuperación | Pendiente |
| Supervisión | Medir recursos y revisar registros | Pendiente |

## 3. Restricciones conocidas
- El laboratorio se ejecuta en un equipo personal.
- El anfitrión tiene un AMD Ryzen 5 3400G y 16 GB de RAM.
- Se utiliza VirtualBox.
- La VM inicial es Debian 13 Server sin entorno gráfico.
- Los recursos deben repartirse entre anfitrión y máquinas virtuales.
- El espacio libre del SSD y los recursos exactos asignados a la VM están pendientes de comprobar.

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
- [ ] Comprobar el espacio libre del SSD.
- [ ] Estimar cuántas VM pueden ejecutarse simultáneamente.
