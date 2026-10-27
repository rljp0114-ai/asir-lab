# 05. Diseño y pruebas de red

## 1. Objetivo
Documentar los adaptadores virtuales, el direccionamiento y las pruebas de comunicación del laboratorio.

## 2. Diseño conocido
- La VM Debian Server tiene un adaptador NAT.
- Se configuró un segundo adaptador como red interna de VirtualBox.
- Nombre de la red interna: `asir_lab`.
- La IP de la red interna está pendiente de confirmar.

NAT y red interna son modos distintos; se documentarán por separado.

## 3. Plan de direccionamiento

| Máquina/interfaz | Red/modo | IP | Máscara/prefijo | Puerta de enlace | Estado |
|---|---|---|---|---|---|
| Debian Server, `enp0s3` | NAT | `10.0.2.15` observada | `/24` | Pendiente de verificar | Observado anteriormente |
| Debian Server, segundo adaptador | Interna `asir_lab` | Pendiente | Pendiente | Según diseño final | Pendiente |
| VM cliente | `asir_lab` prevista | Pendiente | Pendiente | Según diseño final | Pendiente |

## 4. Comprobaciones en Debian

```bash
ip -br address
ip route
ping -c 4 10.0.2.2
```

`10.0.2.2` suele ser la puerta de enlace de una configuración NAT habitual de VirtualBox, pero comprueba la ruta real antes de sacar conclusiones. Si el ping falla, registra el resultado; por sí solo no demuestra que toda la red esté caída.

Cuando exista una segunda VM en `asir_lab`, probar la conectividad entre ambas con sus IP reales.

## 5. Registro de pruebas

| Fecha | Origen | Destino | Comando/prueba | Resultado | Conclusión |
|---|---|---|---|---|---|
| Pendiente | Debian Server | Interfaces | `ip -br address` | En una comprobación anterior se observó `enp0s3` con `10.0.2.15/24` | Falta comprobar el segundo adaptador |

## 6. Diagrama
Añadir el diagrama en `diagramas/`. Diferenciar NAT y red interna; marcar como pendientes los equipos que todavía no estén instalados.
