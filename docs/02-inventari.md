# 02. Inventario y diagnóstico del equipo

## 1. Equipo anfitrión

| Elemento | Dato | Estado |
|---|---|---|
| Procesador | AMD Ryzen 5 3400G | Dato conocido |
| RAM | 16 GB | Dato conocido |
| Almacenamiento | SSD | Capacidad/modelo pendientes |
| Espacio libre | Pendiente | No registrar una cifra sin medirla |
| Sistema operativo anfitrión | Pendiente | Anotar distribución y versión |
| Virtualizador | VirtualBox | Dato conocido |

## 2. Datos por recopilar

En el anfitrión Linux, si corresponde, ejecutar:

```bash
lscpu
free -h
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
df -h
ip -br address
```

Revisar las salidas antes de publicarlas y ocultar datos privados si los hubiera.

## 3. Diagnóstico

| Recurso | Resultado | Posible límite | Acción |
|---|---|---|---|
| CPU | Pendiente | Pendiente | Pendiente |
| RAM | 16 GB en anfitrión; consumo actual pendiente | Pendiente | Evitar ejecutar demasiadas VM a la vez |
| Disco | Capacidad y espacio libre pendientes | Pendiente | Comprobar antes de crear más discos |
| Red | Pendiente de inventario completo | Pendiente | Comprobar interfaces y conectividad |

## 4. Evidencias
Guardar capturas o salidas de comandos seleccionadas en `evidencies/`. No incluir contraseñas ni información sensible.
