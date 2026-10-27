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
